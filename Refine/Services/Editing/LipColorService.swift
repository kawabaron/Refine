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

        // outerLips からスプライン補間されたマスクを生成
        guard let lipMask = LandmarkPathHelper.gradientMask(
            from: landmarks.outerLips,
            closed: true,
            imageSize: imageSize,
            blurSigma: 3.0,
            expandRatio: -0.05 // 少し内側に縮小して色漏れ防止
        ) else {
            return inputImage
        }

        // innerLips で中心部を少し強調（唇の立体感）
        let innerMask = LandmarkPathHelper.gradientMask(
            from: landmarks.innerLips,
            closed: true,
            imageSize: imageSize,
            blurSigma: 4.0,
            expandRatio: 0.0
        )

        // プリセットカラー
        let components = colorPreset.cgColor.components ?? [0.8, 0.5, 0.5, 1.0]
        let r = components.count > 0 ? components[0] : 0.8
        let g = components.count > 1 ? components[1] : 0.5
        let b = components.count > 2 ? components[2] : 0.5

        // ソフトライトで自然な発色（控えめに）
        let lipColor = CIColor(red: r, green: g, blue: b, alpha: intensity * 0.3)
        let colorImage = CIImage(color: lipColor).cropped(to: inputImage.extent)

        let blend = CIFilter(name: "CISoftLightBlendMode")!
        blend.setValue(colorImage, forKey: kCIInputImageKey)
        blend.setValue(inputImage, forKey: kCIInputBackgroundImageKey)

        guard let blended = blend.outputImage else { return inputImage }

        // 外側マスクでベースの色付け
        var result = inputImage.blended(with: blended, mask: lipMask)

        // 内側マスクでわずかに追加（立体感）
        if let innerMask {
            let innerColor = CIColor(red: r * 0.95, green: g * 0.9, blue: b * 0.9, alpha: intensity * 0.1)
            let innerColorImage = CIImage(color: innerColor).cropped(to: inputImage.extent)

            let innerBlend = CIFilter(name: "CISoftLightBlendMode")!
            innerBlend.setValue(innerColorImage, forKey: kCIInputImageKey)
            innerBlend.setValue(result, forKey: kCIInputBackgroundImageKey)

            if let innerBlended = innerBlend.outputImage {
                result = result.blended(with: innerBlended, mask: innerMask)
            }
        }

        return result
    }
}
