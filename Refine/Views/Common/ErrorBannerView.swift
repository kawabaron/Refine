import SwiftUI

/// エラーバナー - 画面上部に表示される統一エラーUI
struct ErrorBannerView: View {
    let error: AppError
    var onDismiss: (() -> Void)?
    var onRetry: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)
                Text(error.displayMessage)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                if onDismiss != nil {
                    Button {
                        onDismiss?()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            if let suggestion = error.recoverySuggestion {
                Text(suggestion)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if let onRetry {
                Button("もう一度試す") {
                    onRetry()
                }
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(Constants.Colors.accent)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.08), radius: 8, y: 2)
        .padding(.horizontal)
    }
}
