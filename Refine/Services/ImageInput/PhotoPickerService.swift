import PhotosUI
import SwiftUI

/// PhotosPickerItem から UIImage への変換サービス
struct PhotoPickerService {
    /// PhotosPickerItem を UIImage に変換
    func loadImage(from item: PhotosPickerItem) async throws -> UIImage {
        guard let data = try? await item.loadTransferable(type: Data.self),
              let image = UIImage(data: data) else {
            throw AppError.imageLoadFailed
        }
        return image.normalizedOrientation()
    }
}
