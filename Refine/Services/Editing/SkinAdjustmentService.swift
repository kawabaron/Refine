import CoreImage
import CoreImage.CIFilterBuiltins
import UIKit

/// 肌補正サービス - なめらかさ、トーン、クマ軽減
struct SkinAdjustmentService {

    /// 顔領域マスクを生成（目・眉・唇を除外）
    private func createFaceMask(
        landmarks: FaceLandmarks,
        imageSize: CGSize,
        context: CGContext
    ) {
        // 顔輪郭でマスクを描画
        let contour = landmarks.faceContour
        guard contour.count > 2 else { return }

        context.setFillColor(CGColor(gray: 1.0, alpha: 1.0))
        context.beginPath()
        context.move(to: contour[0])
        for point in contour.dropFirst() {
            context.addLine(to: point)
        }
        context.closePath()
        context.fillPath()

        // 目・眉・唇領域を除外（黒で塗りつぶし）
        let excludeRegions = [
            landmarks.leftEye,
            landmarks.rightEye,
            landmarks.leftEyebrow,
            landmarks.rightEyebrow,
            landmarks.outerLips
        ]

        context.setFillColor(CGColor(gray: 0.0, alpha: 1.0))
        for region in excludeRegions {
            guard region.count > 2 else { continue }
            // 少し大きめに除外
            let center = CGPoint(
                x: region.map(\.x).reduce(0, +) / CGFloat(region.count),
                y: region.map(\.y).reduce(0, +) / CGFloat(region.count)
            )
            context.beginPath()
            for point in region {
                let expanded = CGPoint(
                    x: center.x + (point.x - center.x) * 1.3,
                    y: center.y + (point.y - center.y) * 1.3
                )
                if point == region.first {
                    context.move(to: expanded)
                } else {
                    context.addLine(to: expanded)
                }
            }
            context.closePath()
            context.fillPath()
        }
    }

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

        // 肌なめらかさ: ガウシアンブラーを顔マスクでブレンド
        if smoothness > 0.01 {
            let radius = smoothness * 8.0 // 最大8ピクセル程度
            let blurred = result.applyingGaussianBlur(sigma: radius)

            // マスク画像を生成
            if let maskImage = generateFaceMaskImage(landmarks: landmarks, imageSize: imageSize) {
                // ブラー適用済み画像をマスク領域だけブレンド
                let softMask = maskImage.applyingGaussianBlur(sigma: 3.0)
                result = result.blended(with: blurred, mask: softMask)
            }
        }

        // トーン補正: 明るさを少し上げる
        if tone > 0.01 {
            let brightnessAmount = tone * 0.06
            let filter = CIFilter(name: "CIColorControls")!
            filter.setValue(result, forKey: kCIInputImageKey)
            filter.setValue(brightnessAmount, forKey: kCIInputBrightnessKey)
            filter.setValue(1.0 + tone * 0.05, forKey: kCIInputContrastKey)
            if let output = filter.outputImage {
                // 顔マスク内のみ適用
                if let maskImage = generateFaceMaskImage(landmarks: landmarks, imageSize: imageSize) {
                    let softMask = maskImage.applyingGaussianBlur(sigma: 5.0)
                    result = inputImage.blended(with: output, mask: softMask)
                } else {
                    result = output
                }
            }
        }

        // クマ軽減: 目の下エリアを明るくする
        if darkCircleReduction > 0.01 {
            let brighten = CIFilter(name: "CIColorControls")!
            brighten.setValue(result, forKey: kCIInputImageKey)
            brighten.setValue(darkCircleReduction * 0.08, forKey: kCIInputBrightnessKey)
            brighten.setValue(1.0 - darkCircleReduction * 0.05, forKey: kCIInputSaturationKey)
            if let brightened = brighten.outputImage,
               let underEyeMask = generateUnderEyeMask(landmarks: landmarks, imageSize: imageSize) {
                let softMask = underEyeMask.applyingGaussianBlur(sigma: 6.0)
                result = result.blended(with: brightened, mask: softMask)
            }
        }

        return result
    }

    /// 顔マスク CIImage を生成
    private func generateFaceMaskImage(landmarks: FaceLandmarks, imageSize: CGSize) -> CIImage? {
        let width = Int(imageSize.width)
        let height = Int(imageSize.height)
        guard width > 0, height > 0 else { return nil }

        UIGraphicsBeginImageContext(imageSize)
        guard let ctx = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return nil
        }

        ctx.setFillColor(CGColor(gray: 0.0, alpha: 1.0))
        ctx.fill(CGRect(origin: .zero, size: imageSize))

        createFaceMask(landmarks: landmarks, imageSize: imageSize, context: ctx)

        guard let maskUIImage = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        UIGraphicsEndImageContext()

        return maskUIImage.toCIImage()
    }

    /// 目の下エリアのマスクを生成
    private func generateUnderEyeMask(landmarks: FaceLandmarks, imageSize: CGSize) -> CIImage? {
        UIGraphicsBeginImageContext(imageSize)
        guard let ctx = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return nil
        }

        ctx.setFillColor(CGColor(gray: 0.0, alpha: 1.0))
        ctx.fill(CGRect(origin: .zero, size: imageSize))
        ctx.setFillColor(CGColor(gray: 1.0, alpha: 1.0))

        // 左目の下
        drawUnderEyeRegion(ctx: ctx, eyePoints: landmarks.leftEye, offset: 8)
        // 右目の下
        drawUnderEyeRegion(ctx: ctx, eyePoints: landmarks.rightEye, offset: 8)

        guard let maskUIImage = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        UIGraphicsEndImageContext()

        return maskUIImage.toCIImage()
    }

    private func drawUnderEyeRegion(ctx: CGContext, eyePoints: [CGPoint], offset: CGFloat) {
        guard eyePoints.count >= 4 else { return }
        let center = CGPoint(
            x: eyePoints.map(\.x).reduce(0, +) / CGFloat(eyePoints.count),
            y: eyePoints.map(\.y).reduce(0, +) / CGFloat(eyePoints.count)
        )
        let width = eyePoints.map(\.x).max()! - eyePoints.map(\.x).min()!
        let rect = CGRect(
            x: center.x - width * 0.5,
            y: center.y + offset,
            width: width,
            height: width * 0.35
        )
        ctx.fillEllipse(in: rect)
    }
}
