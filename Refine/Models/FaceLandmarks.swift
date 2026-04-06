import CoreGraphics

/// 顔ランドマークモデル - UIImage座標系に変換済みの点群
struct FaceLandmarks {
    let faceContour: [CGPoint]
    let leftEye: [CGPoint]
    let rightEye: [CGPoint]
    let leftEyebrow: [CGPoint]
    let rightEyebrow: [CGPoint]
    let nose: [CGPoint]
    let outerLips: [CGPoint]
    let innerLips: [CGPoint]
}
