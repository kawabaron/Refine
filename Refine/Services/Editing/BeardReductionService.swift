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

        // 青み軽減: 彩度を下げ明度を少し上げる
        let colorAdjust = CIFilter(name: "CIColorControls")!
        colorAdjust.setValue(inputImage, forKey: kCIInputImageKey)
        colorAdjust.setValue(1.0 - intensity * 0.2, forKey: kCIInputSaturationKey)
        colorAdjust.setValue(intensity * 0.03, forKey: kCIInputBrightnessKey)

        guard let adjusted = colorAdjust.outputImage else { return inputImage }

        // 暖色を軽く追加して肌に馴染ませる
        let warmColor = CIColor(red: 0.92, green: 0.82, blue: 0.75, alpha: intensity * 0.06)
        let warmOverlay = CIImage(color: warmColor).cropped(to: inputImage.extent)

        let blend = CIFilter(name: "CISoftLightBlendMode")!
        blend.setValue(warmOverlay, forKey: kCIInputImageKey)
        blend.setValue(adjusted, forKey: kCIInputBackgroundImageKey)

        let blended = blend.outputImage ?? adjusted

        // 大きめブラーのマスクで自然にぼかす
        return inputImage.blended(with: blended, mask: beardMask)
    }

    /// 顔輪郭に沿ったひげ領域マスクを生成
    private func generateBeardMask(landmarks: FaceLandmarks, imageSize: CGSize) -> CIImage? {
        let outerLips = landmarks.outerLips
        let faceContour = landmarks.faceContour
        let nose = landmarks.nose

        guard outerLips.count >= 4, faceContour.count >= 5, !nose.isEmpty else {
            return nil
        }

        UIGraphicsBeginImageContext(imageSize)
        guard let ctx = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return nil
        }

        ctx.setFillColor(CGColor(gray: 0.0, alpha: 1.0))
        ctx.fill(CGRect(origin: .zero, size: imageSize))

        // 鼻下の位置
        let noseBottom = nose.map(\.y).max() ?? 0
        let lipCenter = CGPoint(
            x: outerLips.map(\.x).reduce(0, +) / CGFloat(outerLips.count),
            y: outerLips.map(\.y).reduce(0, +) / CGFloat(outerLips.count)
        )

        // 顔輪郭から「鼻下より下」の点を抽出 → あご輪郭
        let chinContour = faceContour.filter { $0.y >= noseBottom - 5 }

        guard chinContour.count >= 3 else {
            UIGraphicsEndImageContext()
            return nil
        }

        // ひげ領域パスを構築:
        // 上辺: 鼻下の水平ライン（唇を少し避ける）
        // 下辺 + 左右: 顔輪郭のあご部分
        let lipWidth = (outerLips.map(\.x).max() ?? 0) - (outerLips.map(\.x).min() ?? 0)
        let leftX = lipCenter.x - lipWidth * 0.9
        let rightX = lipCenter.x + lipWidth * 0.9

        var maskPoints: [CGPoint] = []

        // 上辺: 鼻下ライン
        maskPoints.append(CGPoint(x: leftX, y: noseBottom))
        maskPoints.append(CGPoint(x: lipCenter.x, y: noseBottom))
        maskPoints.append(CGPoint(x: rightX, y: noseBottom))

        // 右側を下に → あご輪郭を左へ
        let sortedChin = chinContour.sorted { $0.x > $1.x }
        for p in sortedChin {
            if p.x >= leftX && p.x <= rightX {
                maskPoints.append(p)
            }
        }

        ctx.setFillColor(CGColor(gray: 1.0, alpha: 1.0))
        let path = LandmarkPathHelper.smoothPath(from: maskPoints, closed: true, tension: 0.3)
        ctx.addPath(path.cgPath)
        ctx.fillPath()

        // 唇部分を除外 (唇の上にひげ補正が乗らないように)
        ctx.setBlendMode(.clear)
        let lipPath = LandmarkPathHelper.smoothPath(from: outerLips, closed: true, tension: 0.5)
        ctx.addPath(lipPath.cgPath)
        ctx.fillPath()
        ctx.setBlendMode(.normal)

        guard let img = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        UIGraphicsEndImageContext()

        guard let ciImage = img.toCIImage() else { return nil }
        // 大きめのブラーで境界を完全にぼかす
        return ciImage.applyingGaussianBlur(sigma: 18.0)
    }
}
