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

        guard let cheekMask = generateCheekMask(landmarks: landmarks, imageSize: imageSize) else {
            return inputImage
        }

        // 暖色のソフトライトブレンドで自然な血色感
        let warmColor = CIColor(red: 0.85, green: 0.45, blue: 0.4, alpha: intensity * 0.15)
        let colorImage = CIImage(color: warmColor).cropped(to: inputImage.extent)

        let blend = CIFilter(name: "CISoftLightBlendMode")!
        blend.setValue(colorImage, forKey: kCIInputImageKey)
        blend.setValue(inputImage, forKey: kCIInputBackgroundImageKey)

        guard let blended = blend.outputImage else { return inputImage }

        return inputImage.blended(with: blended, mask: cheekMask)
    }

    /// 頬領域のグラデーションマスクを生成
    private func generateCheekMask(landmarks: FaceLandmarks, imageSize: CGSize) -> CIImage? {
        let nose = landmarks.nose
        let leftEye = landmarks.leftEye
        let rightEye = landmarks.rightEye
        let faceContour = landmarks.faceContour

        guard !nose.isEmpty, !leftEye.isEmpty, !rightEye.isEmpty else {
            return nil
        }

        UIGraphicsBeginImageContext(imageSize)
        guard let ctx = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return nil
        }

        ctx.setFillColor(CGColor(gray: 0.0, alpha: 1.0))
        ctx.fill(CGRect(origin: .zero, size: imageSize))

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
        let cheekRadius = eyeDistance * 0.28

        // 顔輪郭の左右端を使って頬位置をより正確に推定
        let faceLeft = faceContour.map(\.x).min() ?? leftEyeCenter.x
        let faceRight = faceContour.map(\.x).max() ?? rightEyeCenter.x

        // 左頬: 目と輪郭の中間あたり、鼻の高さ
        let leftCheekCenter = CGPoint(
            x: (leftEyeCenter.x + faceLeft) / 2,
            y: noseCenter.y + cheekRadius * 0.15
        )
        // 右頬
        let rightCheekCenter = CGPoint(
            x: (rightEyeCenter.x + faceRight) / 2,
            y: noseCenter.y + cheekRadius * 0.15
        )

        // ラジアルグラデーションで自然な頬紅効果
        let colorSpace = CGColorSpaceCreateDeviceGray()

        for cheekCenter in [leftCheekCenter, rightCheekCenter] {
            let colors = [
                CGColor(gray: 1.0, alpha: 1.0),
                CGColor(gray: 0.0, alpha: 1.0)
            ] as CFArray
            let locations: [CGFloat] = [0.0, 1.0]

            if let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: locations) {
                ctx.saveGState()
                // 楕円形にするため縦方向をスケール
                ctx.translateBy(x: cheekCenter.x, y: cheekCenter.y)
                ctx.scaleBy(x: 1.0, y: 0.7)
                ctx.drawRadialGradient(
                    gradient,
                    startCenter: .zero,
                    startRadius: 0,
                    endCenter: .zero,
                    endRadius: cheekRadius,
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
        return ciImage.applyingGaussianBlur(sigma: 15.0)
    }
}
