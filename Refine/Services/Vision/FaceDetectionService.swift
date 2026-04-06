import Vision
import UIKit

/// 顔検出サービス - 1人分の顔検出とランドマーク取得
struct FaceDetectionService {

    /// 画像から顔を検出し、ランドマーク付きの結果を返す
    func detectFace(in image: UIImage) async throws -> FaceDetectionResult {
        let normalizedImage = image.normalizedOrientation()
        guard let cgImage = normalizedImage.cgImage else {
            throw AppError.imageLoadFailed
        }

        let imageSize = CGSize(
            width: cgImage.width,
            height: cgImage.height
        )

        let request = VNDetectFaceLandmarksRequest()
        request.revision = VNDetectFaceLandmarksRequestRevision3

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        return try await withCheckedThrowingContinuation { continuation in
            do {
                try handler.perform([request])

                guard let results = request.results, !results.isEmpty else {
                    continuation.resume(throwing: AppError.faceNotFound)
                    return
                }

                if results.count > 1 {
                    continuation.resume(throwing: AppError.multipleFacesDetected)
                    return
                }

                let observation = results[0]

                // 顔が小さすぎるかチェック
                let faceWidth = observation.boundingBox.width
                if faceWidth < Constants.FaceDetection.minimumFaceRatio {
                    continuation.resume(throwing: AppError.faceTooSmall)
                    return
                }

                guard let landmarks = LandmarkConverter.extractLandmarks(
                    from: observation,
                    imageSize: imageSize
                ) else {
                    continuation.resume(throwing: AppError.faceNotFound)
                    return
                }

                // boundingBox をピクセル座標に変換
                let box = observation.boundingBox
                let pixelBox = CGRect(
                    x: box.origin.x * imageSize.width,
                    y: (1.0 - box.origin.y - box.height) * imageSize.height,
                    width: box.width * imageSize.width,
                    height: box.height * imageSize.height
                )

                let result = FaceDetectionResult(
                    boundingBox: pixelBox,
                    landmarks: landmarks
                )
                continuation.resume(returning: result)

            } catch let error as AppError {
                continuation.resume(throwing: error)
            } catch {
                continuation.resume(throwing: AppError.faceNotFound)
            }
        }
    }
}
