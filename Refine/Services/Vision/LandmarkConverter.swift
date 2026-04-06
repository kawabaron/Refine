import Vision
import UIKit

/// Vision 座標系を UIImage / CIImage ピクセル座標系に変換
struct LandmarkConverter {

    /// Vision の正規化座標点群を画像ピクセル座標に変換
    /// - Vision: 左下原点、0〜1 正規化
    /// - UIImage/CIImage: 左上原点、ピクセル単位
    static func convertPoints(
        _ points: [CGPoint]?,
        imageSize: CGSize,
        boundingBox: CGRect
    ) -> [CGPoint] {
        guard let points else { return [] }
        return points.map { point in
            let x = boundingBox.origin.x + point.x * boundingBox.width
            let y = boundingBox.origin.y + point.y * boundingBox.height
            return CGPoint(
                x: x * imageSize.width,
                y: (1.0 - y) * imageSize.height
            )
        }
    }

    /// VNFaceObservation から FaceLandmarks を生成
    static func extractLandmarks(
        from observation: VNFaceObservation,
        imageSize: CGSize
    ) -> FaceLandmarks? {
        guard let landmarks = observation.landmarks else { return nil }
        let box = observation.boundingBox

        return FaceLandmarks(
            faceContour: convertPoints(
                landmarks.faceContour?.normalizedPoints.map { CGPoint(x: $0.x, y: $0.y) },
                imageSize: imageSize,
                boundingBox: box
            ),
            leftEye: convertPoints(
                landmarks.leftEye?.normalizedPoints.map { CGPoint(x: $0.x, y: $0.y) },
                imageSize: imageSize,
                boundingBox: box
            ),
            rightEye: convertPoints(
                landmarks.rightEye?.normalizedPoints.map { CGPoint(x: $0.x, y: $0.y) },
                imageSize: imageSize,
                boundingBox: box
            ),
            leftEyebrow: convertPoints(
                landmarks.leftEyebrow?.normalizedPoints.map { CGPoint(x: $0.x, y: $0.y) },
                imageSize: imageSize,
                boundingBox: box
            ),
            rightEyebrow: convertPoints(
                landmarks.rightEyebrow?.normalizedPoints.map { CGPoint(x: $0.x, y: $0.y) },
                imageSize: imageSize,
                boundingBox: box
            ),
            nose: convertPoints(
                landmarks.nose?.normalizedPoints.map { CGPoint(x: $0.x, y: $0.y) },
                imageSize: imageSize,
                boundingBox: box
            ),
            outerLips: convertPoints(
                landmarks.outerLips?.normalizedPoints.map { CGPoint(x: $0.x, y: $0.y) },
                imageSize: imageSize,
                boundingBox: box
            ),
            innerLips: convertPoints(
                landmarks.innerLips?.normalizedPoints.map { CGPoint(x: $0.x, y: $0.y) },
                imageSize: imageSize,
                boundingBox: box
            )
        )
    }
}
