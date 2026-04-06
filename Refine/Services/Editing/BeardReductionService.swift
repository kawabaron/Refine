import CoreImage
import UIKit

/// 青ひげ軽減サービス - 口元・あご周辺の色補正
struct BeardReductionService {

    /// 青ひげ軽減を適用
    func apply(
        to inputImage: CIImage,
        landmarks: FaceLandmarks,
        intensity: Double,
        imageSize: CGSize
    ) -> CIImage {
        guard intensity > 0.01 else { return inputImage }

        guard let beardMask = generateBeardMask(landmarks: landmarks, imageSize: imageSize) else {
            return inputImage
        }

        // 青み（色相の青〜紫成分）を軽減するために彩度を下げ、明度を少し上げる
        let colorAdjust = CIFilter(name: "CIColorControls")!
        colorAdjust.setValue(inputImage, forKey: kCIInputImageKey)
        colorAdjust.setValue(1.0 - intensity * 0.25, forKey: kCIInputSaturationKey)
        colorAdjust.setValue(intensity * 0.04, forKey: kCIInputBrightnessKey)

        guard let adjusted = colorAdjust.outputImage else { return inputImage }

        // 肌色寄りの暖色をわずかに加える
        let warmColor = CIColor(red: 0.92, green: 0.82, blue: 0.75, alpha: intensity * 0.08)
        let warmOverlay = CIImage(color: warmColor).cropped(to: inputImage.extent)

        let blend = CIFilter(name: "CISoftLightBlendMode")!
        blend.setValue(warmOverlay, forKey: kCIInputImageKey)
        blend.setValue(adjusted, forKey: kCIInputBackgroundImageKey)

        let blended = blend.outputImage ?? adjusted

        // マスクで適用範囲を制限
        let softMask = beardMask.applyingGaussianBlur(sigma: 8.0)
        return inputImage.blended(with: blended, mask: softMask)
    }

    /// ひげ領域マスク（口〜あご周辺）
    private func generateBeardMask(landmarks: FaceLandmarks, imageSize: CGSize) -> CIImage? {
        UIGraphicsBeginImageContext(imageSize)
        guard let ctx = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return nil
        }

        ctx.setFillColor(CGColor(gray: 0.0, alpha: 1.0))
        ctx.fill(CGRect(origin: .zero, size: imageSize))
        ctx.setFillColor(CGColor(gray: 1.0, alpha: 1.0))

        let outerLips = landmarks.outerLips
        let faceContour = landmarks.faceContour
        let nose = landmarks.nose

        guard !outerLips.isEmpty, !faceContour.isEmpty else {
            UIGraphicsEndImageContext()
            return nil
        }

        // 唇の下〜あご先の領域を推定
        let lipBottom = outerLips.map(\.y).max() ?? 0
        let lipCenter = CGPoint(
            x: outerLips.map(\.x).reduce(0, +) / CGFloat(outerLips.count),
            y: outerLips.map(\.y).reduce(0, +) / CGFloat(outerLips.count)
        )
        let noseBottom = nose.map(\.y).max() ?? lipCenter.y
        let lipWidth = (outerLips.map(\.x).max() ?? 0) - (outerLips.map(\.x).min() ?? 0)

        // あご先を推定（顔輪郭の最下部）
        let chinBottom = faceContour.map(\.y).max() ?? (lipBottom + lipWidth)

        // ひげ領域: 鼻下〜あご、唇幅より少し広め
        let beardRect = CGRect(
            x: lipCenter.x - lipWidth * 0.8,
            y: noseBottom,
            width: lipWidth * 1.6,
            height: chinBottom - noseBottom + lipWidth * 0.2
        )
        ctx.fillEllipse(in: beardRect)

        guard let img = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        UIGraphicsEndImageContext()
        return img.toCIImage()
    }
}
