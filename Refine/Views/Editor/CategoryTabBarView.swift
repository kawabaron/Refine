import SwiftUI

/// カテゴリ切替タブバー
struct CategoryTabBarView: View {
    @Binding var selectedCategory: EditorCategory
    let onSelect: (EditorCategory) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(EditorCategory.allCases) { category in
                    CategoryTab(
                        category: category,
                        isSelected: selectedCategory == category
                    ) {
                        selectedCategory = category
                        onSelect(category)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .frame(height: Constants.UI.categoryTabHeight)
    }
}

private struct CategoryTab: View {
    let category: EditorCategory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: category.iconName)
                    .font(.caption)
                Text(category.displayName)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? Constants.Colors.accent : Color.gray.opacity(0.1))
            .foregroundStyle(isSelected ? .white : Constants.Colors.primaryNavy)
            .clipShape(Capsule())
        }
    }
}
