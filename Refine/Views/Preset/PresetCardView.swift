import SwiftUI

/// プリセット1件の表示カード
struct PresetCardView: View {
    let preset: EditPreset
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(preset.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(Constants.Colors.primaryNavy)

                    Text(preset.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Constants.Colors.accent)
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Constants.Colors.accent.opacity(0.08) : Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(
                        isSelected ? Constants.Colors.accent : Color.gray.opacity(0.15),
                        lineWidth: isSelected ? 1.5 : 1
                    )
            )
        }
    }
}
