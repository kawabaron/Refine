import UIKit

/// ビフォーアフター比較画像生成サービス
struct ComparisonImageService {

    /// 左右並びの比較画像を生成
    func generateSideBySide(before: UIImage, after: UIImage) -> UIImage? {
        let maxHeight = max(before.size.height, after.size.height)
        let beforeAspect = before.size.width / before.size.height
        let afterAspect = after.size.width / after.size.height

        let beforeSize = CGSize(width: maxHeight * beforeAspect, height: maxHeight)
        let afterSize = CGSize(width: maxHeight * afterAspect, height: maxHeight)

        let gap: CGFloat = 20
        let labelHeight: CGFloat = 40
        let totalWidth = beforeSize.width + afterSize.width + gap
        let totalHeight = maxHeight + labelHeight

        let renderer = UIGraphicsImageRenderer(size: CGSize(width: totalWidth, height: totalHeight))

        return renderer.image { ctx in
            let context = ctx.cgContext

            // 背景
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: CGSize(width: totalWidth, height: totalHeight)))

            // Before画像
            before.draw(in: CGRect(origin: CGPoint(x: 0, y: labelHeight), size: beforeSize))

            // After画像
            after.draw(in: CGRect(
                origin: CGPoint(x: beforeSize.width + gap, y: labelHeight),
                size: afterSize
            ))

            // ラベル
            let labelFont = UIFont.systemFont(ofSize: 18, weight: .semibold)
            let labelColor = UIColor.darkGray

            let beforeLabel = NSAttributedString(
                string: "Before",
                attributes: [.font: labelFont, .foregroundColor: labelColor]
            )
            let afterLabel = NSAttributedString(
                string: "After",
                attributes: [.font: labelFont, .foregroundColor: labelColor]
            )

            let beforeLabelSize = beforeLabel.size()
            beforeLabel.draw(at: CGPoint(
                x: (beforeSize.width - beforeLabelSize.width) / 2,
                y: (labelHeight - beforeLabelSize.height) / 2
            ))

            let afterLabelSize = afterLabel.size()
            afterLabel.draw(at: CGPoint(
                x: beforeSize.width + gap + (afterSize.width - afterLabelSize.width) / 2,
                y: (labelHeight - afterLabelSize.height) / 2
            ))
        }
    }
}
