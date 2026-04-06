import CoreImage
import UIKit

extension CIImage {
    /// CIImage を UIImage に変換
    func toUIImage(context: CIContext = CIContext()) -> UIImage? {
        guard let cgImage = context.createCGImage(self, from: self.extent) else {
            return nil
        }
        return UIImage(cgImage: cgImage)
    }

    /// 指定領域にブレンドするフィルタを適用
    func blended(with overlay: CIImage, mask: CIImage) -> CIImage {
        let filter = CIFilter(name: "CIBlendWithMask")!
        filter.setValue(overlay, forKey: kCIInputImageKey)
        filter.setValue(self, forKey: kCIInputBackgroundImageKey)
        filter.setValue(mask, forKey: kCIInputMaskImageKey)
        return filter.outputImage ?? self
    }
}
