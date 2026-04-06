import Foundation

/// アプリ共通エラー
enum AppError: Error, Equatable, Identifiable {
    case imageLoadFailed
    case faceNotFound
    case multipleFacesDetected
    case faceTooSmall
    case permissionDenied
    case saveFailed
    case processingFailed(String)

    var id: String { displayMessage }

    var displayMessage: String {
        switch self {
        case .imageLoadFailed:
            return "写真の読み込みに失敗しました"
        case .faceNotFound:
            return "顔がうまく見つかりませんでした"
        case .multipleFacesDetected:
            return "1人だけ写っている写真を選んでください"
        case .faceTooSmall:
            return "顔が小さすぎるため編集できません"
        case .permissionDenied:
            return "写真へのアクセスが許可されていません"
        case .saveFailed:
            return "保存に失敗しました"
        case .processingFailed(let detail):
            return "編集に失敗しました: \(detail)"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .faceNotFound:
            return "正面を向いた写真を選んでください"
        case .multipleFacesDetected:
            return "1人だけ写っている写真を選び直してください"
        case .faceTooSmall:
            return "顔が大きく写っている写真を選んでください"
        case .permissionDenied:
            return "設定アプリから写真へのアクセスを許可してください"
        default:
            return nil
        }
    }
}
