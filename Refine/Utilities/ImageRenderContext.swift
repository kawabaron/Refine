import CoreImage
import UIKit

/// 画像レンダリング用の共有 CIContext
final class ImageRenderContext {
    static let shared = ImageRenderContext()

    let ciContext: CIContext

    private init() {
        ciContext = CIContext(options: [
            .useSoftwareRenderer: false,
            .highQualityDownsample: true
        ])
    }

    /// CIImage を UIImage に変換
    func render(_ ciImage: CIImage) -> UIImage? {
        guard let cgImage = ciContext.createCGImage(ciImage, from: ciImage.extent) else {
            return nil
        }
        return UIImage(cgImage: cgImage)
    }
}
