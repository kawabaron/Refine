import CoreImage
import UIKit

/// 血色補正サービス - 頬中心に自然な赤みを追加
struct ComplexionAdjustmentService {

    /// 血色補正を適用
    func apply(
        to inputImage: CIImage,
        landmarks: FaceLandmarks,
        intensity: Double,
        imageSize: CGSize
    ) -> CIImage {
        guard intensity > 0.01 else { return inputImage }

        // 頬マスクを生成
        guard let cheekMask = generateCheekMask(landmarks: landmarks, imageSize: imageSize) else {
            return inputImage
        }

        // 赤みのオーバーレイカラー画像を生成
        let warmColor = CIColor(red: 0.85, green: 0.45, blue: 0.4, alpha: intensity * 0.18)
        let colorImage = CIImage(color: warmColor).cropped(to: inputImage.extent)

        // ソフトライトブレンドで血色感を追加
        let blend = CIFilter(name: "CISoftLightBlendMode")!
        blend.setValue(colorImage, forKey: kCIInputImageKey)
        blend.setValue(inputImage, forKey: kCIInputBackgroundImageKey)

        guard let blended = blend.outputImage else { return inputImage }

        // 頬マスクで適用範囲を限定
        let softMask = cheekMask.applyingGaussianBlur(sigma: 12.0)
        return inputImage.blended(with: blended, mask: softMask)
    }

    /// 頬領域マスクを生成
    private func generateCheekMask(landmarks: FaceLandmarks, imageSize: CGSize) -> CIImage? {
        UIGraphicsBeginImageContext(imageSize)
        guard let ctx = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return nil
        }

        ctx.setFillColor(CGColor(gray: 0.0, alpha: 1.0))
        ctx.fill(CGRect(origin: .zero, size: imageSize))
        ctx.setFillColor(CGColor(gray: 1.0, alpha: 1.0))

        // 鼻と目の位置から頬の領域を推定
        let nose = landmarks.nose
        let leftEye = landmarks.leftEye
        let rightEye = landmarks.rightEye

        guard !nose.isEmpty, !leftEye.isEmpty, !rightEye.isEmpty else {
            UIGraphicsEndImageContext()
            return nil
        }

        let noseCenter = CGPoint(
            x: nose.map(\.x).reduce(0, +) / CGFloat(nose.count),
            y: nose.map(\.y).reduce(0, +) / CGFloat(nose.count)
        )
        let leftEyeCenter = CGPoint(
            x: leftEye.map(\.x).reduce(0, +) / CGFloat(leftEye.count),
            y: leftEye.map(\.y).reduce(0, +) / CGFloat(leftEye.count)
        )
        let rightEyeCenter = CGPoint(
            x: rightEye.map(\.x).reduce(0, +) / CGFloat(rightEye.count),
            y: rightEye.map(\.y).reduce(0, +) / CGFloat(rightEye.count)
        )

        let eyeDistance = leftEyeCenter.distance(to: rightEyeCenter)
        let cheekRadius = eyeDistance * 0.3

        // 左頬
        let leftCheek = CGPoint(
            x: leftEyeCenter.x,
            y: noseCenter.y + cheekRadius * 0.3
        )
        ctx.fillEllipse(in: CGRect(
            x: leftCheek.x - cheekRadius,
            y: leftCheek.y - cheekRadius * 0.7,
            width: cheekRadius * 2,
            height: cheekRadius * 1.4
        ))

        // 右頬
        let rightCheek = CGPoint(
            x: rightEyeCenter.x,
            y: noseCenter.y + cheekRadius * 0.3
        )
        ctx.fillEllipse(in: CGRect(
            x: rightCheek.x - cheekRadius,
            y: rightCheek.y - cheekRadius * 0.7,
            width: cheekRadius * 2,
            height: cheekRadius * 1.4
        ))

        guard let maskUIImage = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        UIGraphicsEndImageContext()

        return maskUIImage.toCIImage()
    }
}
