import SwiftUI

/// アプリ全体の定数
enum Constants {

    // MARK: - Editing Limits

    /// 自然さモード ON 時の各パラメータ上限
    enum NaturalModeLimit {
        static let skinSmooth: Double = 0.45
        static let skinTone: Double = 0.4
        static let darkCircleReduction: Double = 0.5
        static let complexion: Double = 0.35
        static let eyebrowIntensity: Double = 0.5
        static let eyebrowShapeCorrection: Double = 0.3
        static let beardReduction: Double = 0.6
        static let lipColorIntensity: Double = 0.25
        static let eyeShadowIntensity: Double = 0.2
    }

    // MARK: - Face Detection

    enum FaceDetection {
        /// 顔が小さすぎる判定の閾値 (画像幅に対する比率)
        static let minimumFaceRatio: CGFloat = 0.08
    }

    // MARK: - UI

    enum UI {
        static let cornerRadius: CGFloat = 14
        static let buttonHeight: CGFloat = 54
        static let sliderDebounceInterval: TimeInterval = 0.2
        static let categoryTabHeight: CGFloat = 44
    }

    // MARK: - Colors

    enum Colors {
        static let primaryNavy = Color(red: 0.15, green: 0.22, blue: 0.35)
        static let secondaryGray = Color(red: 0.55, green: 0.58, blue: 0.62)
        static let backgroundPrimary = Color(red: 0.97, green: 0.97, blue: 0.98)
        static let backgroundSecondary = Color.white
        static let accent = Color(red: 0.25, green: 0.42, blue: 0.65)
        static let destructive = Color(red: 0.85, green: 0.3, blue: 0.3)
        static let success = Color(red: 0.3, green: 0.72, blue: 0.55)
    }
}
