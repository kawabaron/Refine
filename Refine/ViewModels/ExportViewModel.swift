import SwiftUI

/// 保存結果画面の状態管理
@MainActor
final class ExportViewModel: ObservableObject {
    @Published var showShareSheet = false
    @Published var isSavingComparison = false

    private let shareService = ShareService()

    func shareItems(image: UIImage) -> [Any] {
        shareService.shareItems(image: image, text: "Refine で整えました")
    }
}
