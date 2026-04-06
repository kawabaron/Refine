import SwiftUI
import PhotosUI

/// アプリの入口画面
struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Constants.Colors.backgroundPrimary
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()

                    // ロゴ・タイトルエリア
                    VStack(spacing: 12) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 40))
                            .foregroundStyle(Constants.Colors.accent)

                        Text("自然に整える")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(Constants.Colors.primaryNavy)

                        Text("男性向けの身だしなみ補正と\n軽いメイク確認")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                    }

                    Spacer()

                    // ボタンエリア
                    VStack(spacing: 12) {
                        PhotosPicker(
                            selection: $viewModel.selectedPhotoItem,
                            matching: .images
                        ) {
                            HStack(spacing: 8) {
                                Image(systemName: "photo.on.rectangle")
                                Text("写真を選ぶ")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: Constants.UI.buttonHeight)
                            .background(Constants.Colors.accent)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: Constants.UI.cornerRadius))
                        }

                        SecondaryButton(title: "カメラで撮る", icon: "camera") {
                            viewModel.didTapOpenCamera()
                        }
                    }
                    .padding(.horizontal, 32)

                    // 補足文言
                    Text("画像は端末内で処理されます")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .padding(.top, 16)
                        .padding(.bottom, 32)
                }

                // ローディング
                if viewModel.isLoadingImage {
                    LoadingOverlayView(message: "読み込み中…")
                }
            }
            .onChange(of: viewModel.selectedPhotoItem) { _, newItem in
                Task {
                    await viewModel.handlePhotoPickerItem(newItem)
                }
            }
            .fullScreenCover(isPresented: $viewModel.showCamera) {
                CameraCaptureView(image: Binding(
                    get: { nil },
                    set: { image in
                        if let image {
                            viewModel.didReceiveSelectedImage(image)
                        }
                    }
                ))
                .ignoresSafeArea()
            }
            .navigationDestination(isPresented: $viewModel.navigateToEditor) {
                if let image = viewModel.selectedImage {
                    EditorView(originalImage: image)
                }
            }
            .overlay(alignment: .top) {
                if let error = viewModel.currentError {
                    ErrorBannerView(error: error) {
                        viewModel.dismissError()
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .padding(.top, 8)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: viewModel.currentError)
        }
    }
}
