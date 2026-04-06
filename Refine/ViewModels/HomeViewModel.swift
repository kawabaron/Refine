import SwiftUI
import PhotosUI

/// Home画面の状態管理
@MainActor
final class HomeViewModel: ObservableObject {
    @Published var selectedImage: UIImage?
    @Published var showPhotoPicker = false
    @Published var showCamera = false
    @Published var currentError: AppError?
    @Published var selectedPhotoItem: PhotosPickerItem?
    @Published var isLoadingImage = false
    @Published var navigateToEditor = false

    private let photoPickerService = PhotoPickerService()

    func didTapPickPhoto() {
        showPhotoPicker = true
    }

    func didTapOpenCamera() {
        showCamera = true
    }

    func didReceiveSelectedImage(_ image: UIImage) {
        selectedImage = image
        navigateToEditor = true
    }

    func didFailInput(_ error: AppError) {
        currentError = error
    }

    func dismissError() {
        currentError = nil
    }

    func handlePhotoPickerItem(_ item: PhotosPickerItem?) async {
        guard let item else { return }
        isLoadingImage = true
        do {
            let image = try await photoPickerService.loadImage(from: item)
            didReceiveSelectedImage(image)
        } catch {
            didFailInput(error as? AppError ?? .imageLoadFailed)
        }
        isLoadingImage = false
        selectedPhotoItem = nil
    }
}
