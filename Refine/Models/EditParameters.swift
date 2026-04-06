import Foundation

/// 編集パラメータモデル - すべての補正値を 0.0...1.0 で管理
struct EditParameters: Codable, Equatable {
    var skinSmooth: Double
    var skinTone: Double
    var darkCircleReduction: Double
    var complexion: Double
    var eyebrowIntensity: Double
    var eyebrowShapeCorrection: Double
    var beardReduction: Double
    var lipColorIntensity: Double
    var lipColorPreset: LipColorPreset
    var eyeShadowIntensity: Double
    var eyeShadowPreset: EyeShadowPreset
    var naturalModeEnabled: Bool

    static let `default` = EditParameters(
        skinSmooth: 0.15,
        skinTone: 0.1,
        darkCircleReduction: 0.1,
        complexion: 0.1,
        eyebrowIntensity: 0.1,
        eyebrowShapeCorrection: 0.0,
        beardReduction: 0.0,
        lipColorIntensity: 0.0,
        lipColorPreset: .naturalPink,
        eyeShadowIntensity: 0.0,
        eyeShadowPreset: .beige,
        naturalModeEnabled: true
    )
}
