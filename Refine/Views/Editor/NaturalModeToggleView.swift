import SwiftUI

/// 自然さ固定モードのトグルUI
struct NaturalModeToggleView: View {
    @Binding var isEnabled: Bool
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: isEnabled ? "leaf.fill" : "leaf")
                .font(.caption)
                .foregroundStyle(isEnabled ? Constants.Colors.success : .secondary)

            Text("自然さ固定")
                .font(.caption)
                .foregroundStyle(Constants.Colors.primaryNavy)

            Toggle("", isOn: $isEnabled)
                .labelsHidden()
                .scaleEffect(0.8)
                .onChange(of: isEnabled) { _, _ in
                    onToggle()
                }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.gray.opacity(0.08))
        .clipShape(Capsule())
    }
}
