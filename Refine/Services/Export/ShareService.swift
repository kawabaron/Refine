import UIKit

/// 共有アイテム生成サービス
struct ShareService {
    /// 共有用のアイテムリストを生成
    func shareItems(image: UIImage, text: String? = nil) -> [Any] {
        var items: [Any] = [image]
        if let text {
            items.append(text)
        }
        return items
    }
}
