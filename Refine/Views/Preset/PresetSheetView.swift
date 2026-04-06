import SwiftUI

/// プリセット一覧シート
struct PresetSheetView: View {
    @StateObject private var viewModel = PresetViewModel()
    @Environment(\.dismiss) private var dismiss
    let onApply: (EditPreset) -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(viewModel.presets) { preset in
                        PresetCardView(
                            preset: preset,
                            isSelected: viewModel.isSelected(preset)
                        ) {
                            viewModel.selectPreset(preset)
                            onApply(preset)
                            dismiss()
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            .navigationTitle("プリセット")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("閉じる") {
                        dismiss()
                    }
                    .foregroundStyle(Constants.Colors.accent)
                }
            }
        }
    }
}
