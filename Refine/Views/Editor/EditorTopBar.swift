import SwiftUI

/// エディター上部バー
struct EditorTopBar: View {
    let onBack: () -> Void
    let onReset: () -> Void

    var body: some View {
        HStack {
            Button(action: onBack) {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                    Text("戻る")
                }
                .font(.subheadline)
                .foregroundStyle(Constants.Colors.accent)
            }

            Spacer()

            Text("編集")
                .font(.headline)
                .foregroundStyle(Constants.Colors.primaryNavy)

            Spacer()

            Button(action: onReset) {
                Text("リセット")
                    .font(.subheadline)
                    .foregroundStyle(Constants.Colors.destructive)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
    }
}
