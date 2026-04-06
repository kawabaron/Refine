import Foundation

/// プリセットリポジトリ - 固定プリセット一覧を提供
struct PresetRepository {

    static let presets: [EditPreset] = [
        EditPreset(
            name: "清潔感アップ",
            description: "肌をなめらかに整え、血色を少しプラス",
            parameters: EditParameters(
                skinSmooth: 0.3,
                skinTone: 0.2,
                darkCircleReduction: 0.2,
                complexion: 0.2,
                eyebrowIntensity: 0.15,
                eyebrowShapeCorrection: 0.1,
                beardReduction: 0.3,
                lipColorIntensity: 0.0,
                lipColorPreset: .naturalPink,
                eyeShadowIntensity: 0.0,
                eyeShadowPreset: .beige,
                naturalModeEnabled: true
            )
        ),
        EditPreset(
            name: "就活 / 証明写真",
            description: "清潔感を重視した控えめな補正",
            parameters: EditParameters(
                skinSmooth: 0.25,
                skinTone: 0.15,
                darkCircleReduction: 0.3,
                complexion: 0.15,
                eyebrowIntensity: 0.2,
                eyebrowShapeCorrection: 0.15,
                beardReduction: 0.4,
                lipColorIntensity: 0.0,
                lipColorPreset: .naturalPink,
                eyeShadowIntensity: 0.0,
                eyeShadowPreset: .beige,
                naturalModeEnabled: true
            )
        ),
        EditPreset(
            name: "デート前",
            description: "自然な血色感と肌のトーンアップ",
            parameters: EditParameters(
                skinSmooth: 0.3,
                skinTone: 0.25,
                darkCircleReduction: 0.25,
                complexion: 0.3,
                eyebrowIntensity: 0.2,
                eyebrowShapeCorrection: 0.1,
                beardReduction: 0.35,
                lipColorIntensity: 0.1,
                lipColorPreset: .naturalPink,
                eyeShadowIntensity: 0.0,
                eyeShadowPreset: .beige,
                naturalModeEnabled: true
            )
        ),
        EditPreset(
            name: "SNSアイコン",
            description: "印象的で映えるプロフィール用",
            parameters: EditParameters(
                skinSmooth: 0.35,
                skinTone: 0.3,
                darkCircleReduction: 0.3,
                complexion: 0.25,
                eyebrowIntensity: 0.25,
                eyebrowShapeCorrection: 0.15,
                beardReduction: 0.3,
                lipColorIntensity: 0.05,
                lipColorPreset: .coral,
                eyeShadowIntensity: 0.05,
                eyeShadowPreset: .lightBrown,
                naturalModeEnabled: true
            )
        ),
        EditPreset(
            name: "婚活プロフィール",
            description: "誠実さと清潔感を両立した印象",
            parameters: EditParameters(
                skinSmooth: 0.3,
                skinTone: 0.2,
                darkCircleReduction: 0.35,
                complexion: 0.2,
                eyebrowIntensity: 0.25,
                eyebrowShapeCorrection: 0.2,
                beardReduction: 0.45,
                lipColorIntensity: 0.05,
                lipColorPreset: .naturalPink,
                eyeShadowIntensity: 0.0,
                eyeShadowPreset: .beige,
                naturalModeEnabled: true
            )
        )
    ]
}
