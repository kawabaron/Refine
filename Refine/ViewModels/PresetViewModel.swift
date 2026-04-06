import Foundation

/// プリセット一覧の管理
@MainActor
final class PresetViewModel: ObservableObject {
    @Published var presets: [EditPreset] = PresetRepository.presets
    @Published var selectedPresetId: UUID?

    func selectPreset(_ preset: EditPreset) {
        selectedPresetId = preset.id
    }

    func isSelected(_ preset: EditPreset) -> Bool {
        selectedPresetId == preset.id
    }
}
