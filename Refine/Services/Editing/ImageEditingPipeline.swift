import CoreImage
import UIKit

/// 画像編集パイプライン - 元画像から全補正を順番に適用して最終画像を生成
final class ImageEditingPipeline {

    private let skinService = SkinAdjustmentService()
    private let complexionService = ComplexionAdjustmentService()
    private let eyebrowService = EyebrowAdjustmentService()
    private let beardService = BeardReductionService()
    private let lipService = LipColorService()
    private let eyeShadowService = EyeShadowService()
    private let renderContext = ImageRenderContext.shared

    /// 編集パラメータを元画像に適用し、最終画像を生成
    /// - 毎回 originalImage から再描画する
    func process(
        originalImage: UIImage,
        faceResult: FaceDetectionResult,
        parameters: EditParameters
    ) async -> UIImage? {
        // 自然さモード適用
        let params = NaturalModeLimiter.apply(to: parameters)
        let landmarks = faceResult.landmarks
        let imageSize = originalImage.size

        guard let inputCIImage = originalImage.toCIImage() else { return nil }

        var current = inputCIImage

        // 1. 肌補正
        current = skinService.apply(
            to: current,
            landmarks: landmarks,
            smoothness: params.skinSmooth,
            tone: params.skinTone,
            darkCircleReduction: params.darkCircleReduction,
            imageSize: imageSize
        )

        // 2. 血色補正
        current = complexionService.apply(
            to: current,
            landmarks: landmarks,
            intensity: params.complexion,
            imageSize: imageSize
        )

        // 3. 眉補正
        current = eyebrowService.apply(
            to: current,
            landmarks: landmarks,
            intensity: params.eyebrowIntensity,
            shapeCorrection: params.eyebrowShapeCorrection,
            imageSize: imageSize
        )

        // 4. 青ひげ軽減
        current = beardService.apply(
            to: current,
            landmarks: landmarks,
            intensity: params.beardReduction,
            imageSize: imageSize
        )

        // 5. 口紅
        current = lipService.apply(
            to: current,
            landmarks: landmarks,
            intensity: params.lipColorIntensity,
            colorPreset: params.lipColorPreset,
            imageSize: imageSize
        )

        // 6. アイシャドウ
        current = eyeShadowService.apply(
            to: current,
            landmarks: landmarks,
            intensity: params.eyeShadowIntensity,
            colorPreset: params.eyeShadowPreset,
            imageSize: imageSize
        )

        // CIImage → UIImage
        return renderContext.render(current)
    }
}
