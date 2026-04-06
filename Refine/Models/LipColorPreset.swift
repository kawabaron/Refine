import SwiftUI

/// 口紅カラープリセット
enum LipColorPreset: String, Codable, CaseIterable {
    case naturalPink
    case coral
    case mutedRose

    var displayName: String {
        switch self {
        case .naturalPink: return "ナチュラルピンク"
        case .coral: return "コーラル"
        case .mutedRose: return "モーヴローズ"
        }
    }

    var color: Color {
        switch self {
        case .naturalPink: return Color(red: 0.85, green: 0.55, blue: 0.58)
        case .coral: return Color(red: 0.88, green: 0.52, blue: 0.43)
        case .mutedRose: return Color(red: 0.75, green: 0.48, blue: 0.52)
        }
    }

    var cgColor: CGColor {
        switch self {
        case .naturalPink: return CGColor(red: 0.85, green: 0.55, blue: 0.58, alpha: 1.0)
        case .coral: return CGColor(red: 0.88, green: 0.52, blue: 0.43, alpha: 1.0)
        case .mutedRose: return CGColor(red: 0.75, green: 0.48, blue: 0.52, alpha: 1.0)
        }
    }
}
