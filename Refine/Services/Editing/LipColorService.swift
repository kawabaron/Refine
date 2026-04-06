import CoreImage
import UIKit

/// 口紅シミュレーションサービス
struct LipColorService {

    /// 口紅を適用
    func apply(
        to inputImage: CIImage,
        landmarks: FaceLandmarks,
        intensity: Double,
        colorPreset: LipColorPreset,
        imageSize: CGSize
    ) -> CIImage {
        guard intensity > 0.01 else { return inputImage }

        guard let lipMask = generateLipMask(landmarks: landmarks, imageSize: imageSize) else {
            return inputImage
        }

        // プリセットカラーでオーバーレイ
        let components = colorPreset.cgColor.components ?? [0.8, 0.5, 0.5, 1.0]
        let r = components.count > 0 ? components[0] : 0.8
        let g = components.count > 1 ? components[1] : 0.5
        let b = components.count > 2 ? components[2] : 0.5

        let lipColor = CIColor(red: r, green: g, blue: b, alpha: intensity * 0.35)
        let colorImage = CIImage(color: lipColor).cropped(to: inputImage.extent)

        // ソフトライトブレンドで自然な発色
        let blend = CIFilter(name: "CISoftLightBlendMode")!
        blend.setValue(colorImage, forKey: kCIInputImageKey)
        blend.setValue(inputImage, forKey: kCIInputBackgroundImageKey)

        guard let blended = blend.outputImage else { return inputImage }

        // マスクで唇領域のみに適用（色漏れ防止のためブラー小さめ）
        let softMask = lipMask.applyingGaussianBlur(sigma: 2.0)
        return inputImage.blended(with: blended, mask: softMask)
    }

    /// 唇マスク生成
    private func generateLipMask(landmarks: FaceLandmarks, imageSize: CGSize) -> CIImage? {
        let outerLips = landmarks.outerLips
        guard outerLips.count >= 4 else { return nil }

        UIGraphicsBeginImageContext(imageSize)
        guard let ctx = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return nil
        }

        ctx.setFillColor(CGColor(gray: 0.0, alpha: 1.0))
        ctx.fill(CGRect(origin: .zero, size: imageSize))
        ctx.setFillColor(CGColor(gray: 1.0, alpha: 1.0))

        // 外側唇パスを描画
        ctx.beginPath()
        ctx.move(to: outerLips[0])
        for point in outerLips.dropFirst() {
            ctx.addLine(to: point)
        }
        ctx.closePath()
        ctx.fillPath()

        guard let img = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        UIGraphicsEndImageContext()
        return img.toCIImage()
    }
}
