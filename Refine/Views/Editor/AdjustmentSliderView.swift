import SwiftUI

/// 共通スライダーUI
struct AdjustmentSliderView: View {
    let title: String
    @Binding var value: Double
    var range: ClosedRange<Double> = 0.0...1.0
    var labels: (String, String, String)? = nil
    let onChange: (Double) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(Constants.Colors.primaryNavy)
                Spacer()
                Text(String(format: "%.0f%%", value * 100))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }

            Slider(value: $value, in: range) { _ in }
                .tint(Constants.Colors.accent)
                .onChange(of: value) { _, newValue in
                    onChange(newValue)
                }

            if let labels {
                HStack {
                    Text(labels.0)
                    Spacer()
                    Text(labels.1)
                    Spacer()
                    Text(labels.2)
                }
                .font(.caption2)
                .foregroundStyle(.tertiary)
            }
        }
    }
}
