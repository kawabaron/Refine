import CoreImage
import UIKit

/// 眉補正サービス - 濃さ補正と形補正
struct EyebrowAdjustmentService {

    /// 眉補正を適用
    func apply(
        to inputImage: CIImage,
        landmarks: FaceLandmarks,
        intensity: Double,
        shapeCorrection: Double,
        imageSize: CGSize
    ) -> CIImage {
        guard intensity > 0.01 || shapeCorrection > 0.01 else { return inputImage }

        var result = inputImage

        // 濃さ補正: 眉領域を暗くする
        if intensity > 0.01 {
            guard let eyebrowMask = generateEyebrowMask(
                landmarks: landmarks,
                imageSize: imageSize
            ) else {
                return inputImage
            }

            // 暗めのオーバーレイ
            let darkenFilter = CIFilter(name: "CIColorControls")!
            darkenFilter.setValue(result, forKey: kCIInputImageKey)
            darkenFilter.setValue(-intensity * 0.15, forKey: kCIInputBrightnessKey)
            darkenFilter.setValue(1.0 + intensity * 0.1, forKey: kCIInputContrastKey)

            if let darkened = darkenFilter.outputImage {
                let softMask = eyebrowMask.applyingGaussianBlur(sigma: 2.0)
                result = result.blended(with: darkened, mask: softMask)
            }
        }

        // 形補正: 左右眉の対称性を改善
        if shapeCorrection > 0.01 {
            // 軽い対称性補正として、片方の眉領域にわずかに他方をブレンド
            // MVP では濃さ補正のみで対称感を出す簡易実装
            guard let leftMask = generateSingleEyebrowMask(
                points: landmarks.leftEyebrow,
                imageSize: imageSize
            ),
            let rightMask = generateSingleEyebrowMask(
                points: landmarks.rightEyebrow,
                imageSize: imageSize
            ) else {
                return result
            }

            // 両眉の平均的な濃さに近づける
            let uniformFilter = CIFilter(name: "CIColorControls")!
            uniformFilter.setValue(result, forKey: kCIInputImageKey)
            uniformFilter.setValue(-shapeCorrection * 0.05, forKey: kCIInputBrightnessKey)
            uniformFilter.setValue(1.0 + shapeCorrection * 0.08, forKey: kCIInputContrastKey)

            if let uniformed = uniformFilter.outputImage {
                let leftSoft = leftMask.applyingGaussianBlur(sigma: 1.5)
                let rightSoft = rightMask.applyingGaussianBlur(sigma: 1.5)
                result = result.blended(with: uniformed, mask: leftSoft)
                result = result.blended(with: uniformed, mask: rightSoft)
            }
        }

        return result
    }

    /// 両眉のマスクを生成
    private func generateEyebrowMask(landmarks: FaceLandmarks, imageSize: CGSize) -> CIImage? {
        UIGraphicsBeginImageContext(imageSize)
        guard let ctx = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return nil
        }

        ctx.setFillColor(CGColor(gray: 0.0, alpha: 1.0))
        ctx.fill(CGRect(origin: .zero, size: imageSize))
        ctx.setFillColor(CGColor(gray: 1.0, alpha: 1.0))

        drawEyebrowPath(ctx: ctx, points: landmarks.leftEyebrow)
        drawEyebrowPath(ctx: ctx, points: landmarks.rightEyebrow)

        guard let img = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        UIGraphicsEndImageContext()
        return img.toCIImage()
    }

    /// 片方の眉マスクを生成
    private func generateSingleEyebrowMask(points: [CGPoint], imageSize: CGSize) -> CIImage? {
        UIGraphicsBeginImageContext(imageSize)
        guard let ctx = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return nil
        }

        ctx.setFillColor(CGColor(gray: 0.0, alpha: 1.0))
        ctx.fill(CGRect(origin: .zero, size: imageSize))
        ctx.setFillColor(CGColor(gray: 1.0, alpha: 1.0))

        drawEyebrowPath(ctx: ctx, points: points)

        guard let img = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        UIGraphicsEndImageContext()
        return img.toCIImage()
    }

    private func drawEyebrowPath(ctx: CGContext, points: [CGPoint]) {
        guard points.count >= 3 else { return }

        // 眉の厚みを追加するため、点群を上下にオフセットしてパスを作成
        let center = CGPoint(
            x: points.map(\.x).reduce(0, +) / CGFloat(points.count),
            y: points.map(\.y).reduce(0, +) / CGFloat(points.count)
        )
        let width = (points.map(\.x).max() ?? 0) - (points.map(\.x).min() ?? 0)
        let thickness = width * 0.12

        ctx.beginPath()
        // 上側
        for (i, point) in points.enumerated() {
            let p = CGPoint(x: point.x, y: point.y - thickness)
            if i == 0 { ctx.move(to: p) } else { ctx.addLine(to: p) }
        }
        // 下側（逆順）
        for point in points.reversed() {
            let p = CGPoint(x: point.x, y: point.y + thickness)
            ctx.addLine(to: p)
        }
        ctx.closePath()
        ctx.fillPath()
    }
}
