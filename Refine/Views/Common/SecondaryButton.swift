import SwiftUI

/// セカンダリボタン - サブアクション用
struct SecondaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void

    init(title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                }
                Text(title)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .frame(height: Constants.UI.buttonHeight)
            .background(Constants.Colors.backgroundSecondary)
            .foregroundStyle(Constants.Colors.primaryNavy)
            .clipShape(RoundedRectangle(cornerRadius: Constants.UI.cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: Constants.UI.cornerRadius)
                    .strokeBorder(Color.gray.opacity(0.25), lineWidth: 1)
            )
        }
    }
}
