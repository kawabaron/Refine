import CoreImage
import CoreImage.CIFilterBuiltins
import UIKit

/// 肌補正サービス - なめらかさ、トーン、クマ軽減
struct SkinAdjustmentService {

    /// 肌補正を適用
    func apply(
        to inputImage: CIImage,
        landmarks: FaceLandmarks,
        smoothness: Double,
        tone: Double,
        darkCircleReduction: Double,
        imageSize: CGSize
    ) -> CIImage {
        guard smoothness > 0.01 || tone > 0.01 || darkCircleReduction > 0.01 else {
            return inputImage
        }

        var result = inputImage

        // 肌なめらかさ
        if smoothness > 0.01 {
            let radius = smoothness * 8.0
            let blurred = result.applyingGaussianBlur(sigma: radius)

            if let maskImage = generateFaceMaskImage(landmarks: landmarks, imageSize: imageSize) {
                result = result.blended(with: blurred, mask: maskImage)
            }
        }

        // トーン補正
        if tone > 0.01 {
            let filter = CIFilter(name: "CIColorControls")!
            filter.setValue(result, forKey: kCIInputImageKey)
            filter.setValue(tone * 0.06, forKey: kCIInputBrightnessKey)
            filter.setValue(1.0 + tone * 0.05, forKey: kCIInputContrastKey)

            if let output = filter.outputImage,
               let maskImage = generateFaceMaskImage(landmarks: landmarks, imageSize: imageSize) {
                result = result.blended(with: output, mask: maskImage)
            }
        }

        // クマ軽減
        if darkCircleReduction > 0.01 {
            let brighten = CIFilter(name: "CIColorControls")!
            brighten.setValue(result, forKey: kCIInputImageKey)
            brighten.setValue(darkCircleReduction * 0.08, forKey: kCIInputBrightnessKey)
            brighten.setValue(1.0 - darkCircleReduction * 0.05, forKey: kCIInputSaturationKey)

            if let brightened = brighten.outputImage,
               let underEyeMask = generateUnderEyeMask(landmarks: landmarks, imageSize: imageSize) {
                result = result.blended(with: brightened, mask: underEyeMask)
            }
        }

        return result
    }

    /// 顔マスク - スプライン補間した輪郭＋目・眉・唇を除外
    private func generateFaceMaskImage(landmarks: FaceLandmarks, imageSize: CGSize) -> CIImage? {
        let contour = landmarks.faceContour
        guard contour.count > 4 else { return nil }

        UIGraphicsBeginImageContext(imageSize)
        guard let ctx = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return nil
        }

        ctx.setFillColor(CGColor(gray: 0.0, alpha: 1.0))
        ctx.fill(CGRect(origin: .zero, size: imageSize))

        // 顔輪郭をスプライン補間で描画
        let facePath = LandmarkPathHelper.smoothPath(from: contour, closed: true, tension: 0.4)
        ctx.setFillColor(CGColor(gray: 1.0, alpha: 1.0))
        ctx.addPath(facePath.cgPath)
        ctx.fillPath()

        // 目・眉・唇を除外（少し大きめに）
        ctx.setBlendMode(.clear)
        let excludeRegions: [(points: [CGPoint], expand: CGFloat)] = [
            (landmarks.leftEye, 0.4),
            (landmarks.rightEye, 0.4),
            (landmarks.leftEyebrow, 0.3),
            (landmarks.rightEyebrow, 0.3),
            (landmarks.outerLips, 0.2),
        ]

        for (points, expand) in excludeRegions {
            guard points.count >= 3 else { continue }
            let center = CGPoint(
                x: points.map(\.x).reduce(0, +) / CGFloat(points.count),
                y: points.map(\.y).reduce(0, +) / CGFloat(points.count)
            )
            let expanded = points.map { p in
                CGPoint(
                    x: center.x + (p.x - center.x) * (1.0 + expand),
                    y: center.y + (p.y - center.y) * (1.0 + expand)
                )
            }
            let excludePath = LandmarkPathHelper.smoothPath(from: expanded, closed: true, tension: 0.5)
            ctx.addPath(excludePath.cgPath)
            ctx.fillPath()
        }

        ctx.setBlendMode(.normal)

        guard let img = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        UIGraphicsEndImageContext()

        guard let ciImage = img.toCIImage() else { return nil }
        // エッジを十分にぼかして自然に
        return ciImage.applyingGaussianBlur(sigma: 6.0)
    }

    /// 目の下エリアのグラデーションマスク
    private func generateUnderEyeMask(landmarks: FaceLandmarks, imageSize: CGSize) -> CIImage? {
        let leftEye = landmarks.leftEye
        let rightEye = landmarks.rightEye
        guard leftEye.count >= 4, rightEye.count >= 4 else { return nil }

        UIGraphicsBeginImageContext(imageSize)
        guard let ctx = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return nil
        }

        ctx.setFillColor(CGColor(gray: 0.0, alpha: 1.0))
        ctx.fill(CGRect(origin: .zero, size: imageSize))

        let colorSpace = CGColorSpaceCreateDeviceGray()
        let colors = [
            CGColor(gray: 1.0, alpha: 1.0),
            CGColor(gray: 0.0, alpha: 1.0)
        ] as CFArray

        for eyePoints in [leftEye, rightEye] {
            let eyeBottom = eyePoints.map(\.y).max() ?? 0
            let center = CGPoint(
                x: eyePoints.map(\.x).reduce(0, +) / CGFloat(eyePoints.count),
                y: eyePoints.map(\.y).reduce(0, +) / CGFloat(eyePoints.count)
            )
            let width = (eyePoints.map(\.x).max() ?? 0) - (eyePoints.map(\.x).min() ?? 0)
            let radius = width * 0.45

            let underEyeCenter = CGPoint(x: center.x, y: eyeBottom + radius * 0.3)

            if let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: [0.0, 1.0]) {
                ctx.saveGState()
                ctx.translateBy(x: underEyeCenter.x, y: underEyeCenter.y)
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
        }

        guard let img = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        UIGraphicsEndImageContext()

        guard let ciImage = img.toCIImage() else { return nil }
        return ciImage.applyingGaussianBlur(sigma: 8.0)
    }
}
