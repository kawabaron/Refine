import SwiftUI

/// アイシャドウカラープリセット
enum EyeShadowPreset: String, Codable, CaseIterable {
    case beige
    case lightBrown
    case mutedPeach

    var displayName: String {
        switch self {
        case .beige: return "ベージュ"
        case .lightBrown: return "ライトブラウン"
        case .mutedPeach: return "ピーチ"
        }
    }

    var color: Color {
        switch self {
        case .beige: return Color(red: 0.82, green: 0.72, blue: 0.62)
        case .lightBrown: return Color(red: 0.72, green: 0.56, blue: 0.44)
        case .mutedPeach: return Color(red: 0.85, green: 0.68, blue: 0.58)
        }
    }

    var cgColor: CGColor {
        switch self {
        case .beige: return CGColor(red: 0.82, green: 0.72, blue: 0.62, alpha: 1.0)
        case .lightBrown: return CGColor(red: 0.72, green: 0.56, blue: 0.44, alpha: 1.0)
        case .mutedPeach: return CGColor(red: 0.85, green: 0.68, blue: 0.58, alpha: 1.0)
        }
    }
}
