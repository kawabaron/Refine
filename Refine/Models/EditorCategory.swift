import Foundation

/// 編集カテゴリ
enum EditorCategory: String, CaseIterable, Identifiable {
    case skin
    case complexion
    case eyebrow
    case beard
    case lips
    case eyes

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .skin: return "肌"
        case .complexion: return "血色"
        case .eyebrow: return "眉"
        case .beard: return "ひげ"
        case .lips: return "口元"
        case .eyes: return "目元"
        }
    }

    var iconName: String {
        switch self {
        case .skin: return "face.smiling"
        case .complexion: return "heart.fill"
        case .eyebrow: return "eyebrow"
        case .beard: return "mustache.fill"
        case .lips: return "mouth.fill"
        case .eyes: return "eye.fill"
        }
    }
}
