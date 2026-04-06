import CoreGraphics

/// 顔検出結果モデル
struct FaceDetectionResult {
    let boundingBox: CGRect
    let landmarks: FaceLandmarks
}
