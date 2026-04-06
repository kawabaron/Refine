import SwiftUI

/// 色プリセット選択UI（口紅・アイシャドウ兼用）
struct ColorPresetPickerView<T: RawRepresentable & CaseIterable & Hashable>: View
where T.RawValue == String, T.AllCases: RandomAccessCollection {
    let title: String
    @Binding var selected: T
    let colorFor: (T) -> Color
    let nameFor: (T) -> String
    let onChange: (T) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(Constants.Colors.primaryNavy)

            HStack(spacing: 12) {
                ForEach(Array(T.allCases), id: \.self) { preset in
                    VStack(spacing: 4) {
                        Circle()
                            .fill(colorFor(preset))
                            .frame(width: 36, height: 36)
                            .overlay(
                                Circle()
                                    .strokeBorder(
                                        selected == preset ? Constants.Colors.accent : Color.clear,
                                        lineWidth: 2.5
                                    )
                                    .frame(width: 42, height: 42)
                            )

                        Text(nameFor(preset))
                            .font(.caption2)
                            .foregroundStyle(
                                selected == preset ? Constants.Colors.accent : .secondary
                            )
                    }
                    .onTapGesture {
                        selected = preset
                        onChange(preset)
                    }
                }
            }
        }
    }
}
