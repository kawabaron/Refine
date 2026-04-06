import SwiftUI

/// 空状態の表示コンポーネント
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundStyle(Constants.Colors.secondaryGray)

            Text(title)
                .font(.headline)
                .foregroundStyle(Constants.Colors.primaryNavy)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(Constants.Colors.accent)
                    .padding(.top, 4)
            }
        }
        .padding(32)
    }
}
