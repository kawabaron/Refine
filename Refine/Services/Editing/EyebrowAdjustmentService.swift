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

        // 眉の幅から自然な太さを算出
        let browWidth = estimateBrowWidth(landmarks.leftEyebrow, landmarks.rightEyebrow)
        let baseThickness = browWidth * 0.08

        // 濃さ補正: 眉領域をなめらかに暗くする
        if intensity > 0.01 {
            guard let leftMask = LandmarkPathHelper.eyebrowMask(
                points: landmarks.leftEyebrow,
                imageSize: imageSize,
                baseThickness: baseThickness,
                blurSigma: max(3.0, baseThickness * 0.6)
            ),
            let rightMask = LandmarkPathHelper.eyebrowMask(
                points: landmarks.rightEyebrow,
                imageSize: imageSize,
                baseThickness: baseThickness,
                blurSigma: max(3.0, baseThickness * 0.6)
            ) else {
                return inputImage
            }

            // 控えめに暗くしてコントラストを上げる
            let darkenFilter = CIFilter(name: "CIColorControls")!
            darkenFilter.setValue(result, forKey: kCIInputImageKey)
            darkenFilter.setValue(-intensity * 0.12, forKey: kCIInputBrightnessKey)
            darkenFilter.setValue(1.0 + intensity * 0.08, forKey: kCIInputContrastKey)

            if let darkened = darkenFilter.outputImage {
                result = result.blended(with: darkened, mask: leftMask)
                result = result.blended(with: darkened, mask: rightMask)
            }
        }

        // 形補正: 左右対称性を改善
        if shapeCorrection > 0.01 {
            guard let leftMask = LandmarkPathHelper.eyebrowMask(
                points: landmarks.leftEyebrow,
                imageSize: imageSize,
                baseThickness: baseThickness * 0.7,
                blurSigma: max(2.0, baseThickness * 0.5)
            ),
            let rightMask = LandmarkPathHelper.eyebrowMask(
                points: landmarks.rightEyebrow,
                imageSize: imageSize,
                baseThickness: baseThickness * 0.7,
                blurSigma: max(2.0, baseThickness * 0.5)
            ) else {
                return result
            }

            let uniformFilter = CIFilter(name: "CIColorControls")!
            uniformFilter.setValue(result, forKey: kCIInputImageKey)
            uniformFilter.setValue(-shapeCorrection * 0.04, forKey: kCIInputBrightnessKey)
            uniformFilter.setValue(1.0 + shapeCorrection * 0.06, forKey: kCIInputContrastKey)

            if let uniformed = uniformFilter.outputImage {
                result = result.blended(with: uniformed, mask: leftMask)
                result = result.blended(with: uniformed, mask: rightMask)
            }
        }

        return result
    }

    private func estimateBrowWidth(_ left: [CGPoint], _ right: [CGPoint]) -> CGFloat {
        let leftW = (left.map(\.x).max() ?? 0) - (left.map(\.x).min() ?? 0)
        let rightW = (right.map(\.x).max() ?? 0) - (right.map(\.x).min() ?? 0)
        return max(leftW, rightW)
    }
}
