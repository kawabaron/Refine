import SwiftUI

/// 保存完了画面
struct ExportResultView: View {
    let savedImage: UIImage?
    let originalImage: UIImage
    let onSaveComparison: () -> Void
    let onDismiss: () -> Void

    @StateObject private var viewModel = ExportViewModel()

    var body: some View {
        VStack(spacing: 20) {
            // 成功アイコン
            VStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(Constants.Colors.success)

                Text("保存しました")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(Constants.Colors.primaryNavy)
            }
            .padding(.top, 24)

            // アクションボタン
            VStack(spacing: 10) {
                SecondaryButton(title: "比較画像も保存", icon: "rectangle.split.2x1") {
                    onSaveComparison()
                }

                if let savedImage {
                    SecondaryButton(title: "共有", icon: "square.and.arrow.up") {
                        viewModel.showShareSheet = true
                    }
                    .sheet(isPresented: $viewModel.showShareSheet) {
                        ShareSheet(items: viewModel.shareItems(image: savedImage))
                    }
                }

                PrimaryButton(title: "編集に戻る") {
                    onDismiss()
                }
            }
            .padding(.horizontal, 24)

            Spacer()
        }
    }
}
