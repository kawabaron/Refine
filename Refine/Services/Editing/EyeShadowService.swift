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

        guard let leftMask = generateEyelidMask(
            eyePoints: landmarks.leftEye,
            eyebrowPoints: landmarks.leftEyebrow,
            imageSize: imageSize
        ),
        let rightMask = generateEyelidMask(
            eyePoints: landmarks.rightEye,
            eyebrowPoints: landmarks.rightEyebrow,
            imageSize: imageSize
        ) else {
            return inputImage
        }

        let components = colorPreset.cgColor.components ?? [0.7, 0.6, 0.5, 1.0]
        let r = components.count > 0 ? components[0] : 0.7
        let g = components.count > 1 ? components[1] : 0.6
        let b = components.count > 2 ? components[2] : 0.5

        // かなり控えめな色付け
        let shadowColor = CIColor(red: r, green: g, blue: b, alpha: intensity * 0.18)
        let colorImage = CIImage(color: shadowColor).cropped(to: inputImage.extent)

        let blend = CIFilter(name: "CIMultiplyBlendMode")!
        blend.setValue(colorImage, forKey: kCIInputImageKey)
        blend.setValue(inputImage, forKey: kCIInputBackgroundImageKey)

        guard let blended = blend.outputImage else { return inputImage }

        var result = inputImage.blended(with: blended, mask: leftMask)
        result = result.blended(with: blended, mask: rightMask)

        return result
    }

    /// まぶた領域のグラデーションマスクを生成
    private func generateEyelidMask(
        eyePoints: [CGPoint],
        eyebrowPoints: [CGPoint],
        imageSize: CGSize
    ) -> CIImage? {
        guard eyePoints.count >= 4, eyebrowPoints.count >= 3 else { return nil }

        let eyeTop = eyePoints.map(\.y).min() ?? 0
        let eyeCenter = CGPoint(
            x: eyePoints.map(\.x).reduce(0, +) / CGFloat(eyePoints.count),
            y: eyePoints.map(\.y).reduce(0, +) / CGFloat(eyePoints.count)
        )
        let eyeWidth = (eyePoints.map(\.x).max() ?? 0) - (eyePoints.map(\.x).min() ?? 0)
        let eyebrowBottom = eyebrowPoints.map(\.y).max() ?? eyeTop

        // まぶたの中心と高さ
        let lidCenterY = (eyeTop + eyebrowBottom) / 2
        let lidHeight = abs(eyeTop - eyebrowBottom) * 0.55

        UIGraphicsBeginImageContext(imageSize)
        guard let ctx = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return nil
        }

        ctx.setFillColor(CGColor(gray: 0.0, alpha: 1.0))
        ctx.fill(CGRect(origin: .zero, size: imageSize))

        // ラジアルグラデーションで中心が濃く周辺が薄いマスク
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let colors = [
            CGColor(gray: 1.0, alpha: 1.0),
            CGColor(gray: 0.0, alpha: 1.0)
        ] as CFArray

        let gradientCenter = CGPoint(x: eyeCenter.x, y: lidCenterY)
        let radius = max(eyeWidth * 0.55, lidHeight)

        if let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: [0.0, 1.0]) {
            ctx.saveGState()
            ctx.translateBy(x: gradientCenter.x, y: gradientCenter.y)
            // 横長の楕円
            ctx.scaleBy(x: 1.3, y: 0.6)
            ctx.drawRadialGradient(
                gradient,
                startCenter: .zero,
                startRadius: 0,
                endCenter: .zero,
                endRadius: radius,
                options: []
            )
            ctx.restoreGState()
        }

        guard let img = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        UIGraphicsEndImageContext()

        guard let ciImage = img.toCIImage() else { return nil }
        return ciImage.applyingGaussianBlur(sigma: 5.0)
    }
}
