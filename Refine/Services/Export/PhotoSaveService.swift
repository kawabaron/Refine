import Photos
import UIKit

/// フォトライブラリ保存サービス
struct PhotoSaveService {

    /// 画像をフォトライブラリに保存
    func save(_ image: UIImage) async throws {
        let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)

        guard status == .authorized || status == .limited else {
            throw AppError.permissionDenied
        }

        return try await withCheckedThrowingContinuation { continuation in
            PHPhotoLibrary.shared().performChanges {
                guard let data = image.jpegData(compressionQuality: 0.95) else {
                    return
                }
                let request = PHAssetCreationRequest.forAsset()
                request.addResource(with: .photo, data: data, options: nil)
            } completionHandler: { success, error in
                if success {
                    continuation.resume()
                } else {
                    continuation.resume(throwing: AppError.saveFailed)
                }
            }
        }
    }
}
