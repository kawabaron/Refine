import CoreImage
import UIKit

/// アイシャドウシミュレーションサービス - 目元上部に軽い色味
struct EyeShadowService {

    /// アイシャドウを適用
    func apply(
        to inputImage: CIImage,
        landmarks: FaceLandmarks,
        intensity: Double,
        colorPreset: EyeShadowPreset,
        imageSize: CGSize
    ) -> CIImage {
        guard intensity > 0.01 else { return inputImage }

        guard let eyeShadowMask = generateEyeShadowMask(
            landmarks: landmarks,
            imageSize: imageSize
        ) else {
            return inputImage
        }

        // プリセットカラーでオーバーレイ（かなり控えめ）
        let components = colorPreset.cgColor.components ?? [0.7, 0.6, 0.5, 1.0]
        let r = components.count > 0 ? components[0] : 0.7
        let g = components.count > 1 ? components[1] : 0.6
        let b = components.count > 2 ? components[2] : 0.5

        let shadowColor = CIColor(red: r, green: g, blue: b, alpha: intensity * 0.2)
        let colorImage = CIImage(color: shadowColor).cropped(to: inputImage.extent)

        let blend = CIFilter(name: "CIMultiplyBlendMode")!
        blend.setValue(colorImage, forKey: kCIInputImageKey)
        blend.setValue(inputImage, forKey: kCIInputBackgroundImageKey)

        guard let blended = blend.outputImage else { return inputImage }

        let softMask = eyeShadowMask.applyingGaussianBlur(sigma: 4.0)
        return inputImage.blended(with: blended, mask: softMask)
    }

    /// 目元上部のマスクを生成（まぶた領域）
    private func generateEyeShadowMask(landmarks: FaceLandmarks, imageSize: CGSize) -> CIImage? {
        UIGraphicsBeginImageContext(imageSize)
        guard let ctx = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return nil
        }

        ctx.setFillColor(CGColor(gray: 0.0, alpha: 1.0))
        ctx.fill(CGRect(origin: .zero, size: imageSize))
        ctx.setFillColor(CGColor(gray: 1.0, alpha: 1.0))

        // 左目の上部
        drawEyelidRegion(ctx: ctx, eyePoints: landmarks.leftEye, eyebrowPoints: landmarks.leftEyebrow)
        // 右目の上部
        drawEyelidRegion(ctx: ctx, eyePoints: landmarks.rightEye, eyebrowPoints: landmarks.rightEyebrow)

        guard let img = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        UIGraphicsEndImageContext()
        return img.toCIImage()
    }

    private func drawEyelidRegion(ctx: CGContext, eyePoints: [CGPoint], eyebrowPoints: [CGPoint]) {
        guard eyePoints.count >= 4, eyebrowPoints.count >= 3 else { return }

        let eyeTop = eyePoints.map(\.y).min() ?? 0
        let eyeCenter = CGPoint(
            x: eyePoints.map(\.x).reduce(0, +) / CGFloat(eyePoints.count),
            y: eyePoints.map(\.y).reduce(0, +) / CGFloat(eyePoints.count)
        )
        let eyeWidth = (eyePoints.map(\.x).max() ?? 0) - (eyePoints.map(\.x).min() ?? 0)

        let eyebrowBottom = eyebrowPoints.map(\.y).max() ?? eyeTop
        // まぶた領域: 目の上端〜眉の下端の中間
        let lidCenter = (eyeTop + eyebrowBottom) / 2
        let lidHeight = abs(eyeTop - eyebrowBottom) * 0.6

        let lidRect = CGRect(
            x: eyeCenter.x - eyeWidth * 0.55,
            y: lidCenter - lidHeight * 0.5,
            width: eyeWidth * 1.1,
            height: lidHeight
        )
        ctx.fillEllipse(in: lidRect)
    }
}
