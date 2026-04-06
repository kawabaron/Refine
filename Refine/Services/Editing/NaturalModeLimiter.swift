import Foundation

/// 自然さ固定モード - パラメータ上限を制御
struct NaturalModeLimiter {

    /// naturalModeEnabled が true の場合、各パラメータを上限値にクランプ
    static func apply(to params: EditParameters) -> EditParameters {
        guard params.naturalModeEnabled else { return params }

        var limited = params
        limited.skinSmooth = min(params.skinSmooth, Constants.NaturalModeLimit.skinSmooth)
        limited.skinTone = min(params.skinTone, Constants.NaturalModeLimit.skinTone)
        limited.darkCircleReduction = min(params.darkCircleReduction, Constants.NaturalModeLimit.darkCircleReduction)
        limited.complexion = min(params.complexion, Constants.NaturalModeLimit.complexion)
        limited.eyebrowIntensity = min(params.eyebrowIntensity, Constants.NaturalModeLimit.eyebrowIntensity)
        limited.eyebrowShapeCorrection = min(params.eyebrowShapeCorrection, Constants.NaturalModeLimit.eyebrowShapeCorrection)
        limited.beardReduction = min(params.beardReduction, Constants.NaturalModeLimit.beardReduction)
        limited.lipColorIntensity = min(params.lipColorIntensity, Constants.NaturalModeLimit.lipColorIntensity)
        limited.eyeShadowIntensity = min(params.eyeShadowIntensity, Constants.NaturalModeLimit.eyeShadowIntensity)
        return limited
    }
}
