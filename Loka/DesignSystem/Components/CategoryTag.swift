import SwiftUI

/// A category label with its tinted icon. Two sizes: a compact inline form and
/// a filled "solid" form for emphasis.
struct CategoryTag: View {
    let category: IssueCategory
    var solid: Bool = false

    var body: some View {
        HStack(spacing: LokaSpacing.xs) {
            Image(systemName: category.systemImage)
                .font(.system(size: LokaSize.iconSmall, weight: .semibold))
            Text(category.displayName)
                .font(LokaFont.captionEmphasized)
        }
        .foregroundStyle(solid ? category.tint : category.tint)
        .padding(.horizontal, LokaSpacing.sm)
        .padding(.vertical, LokaSpacing.xs)
        .background(Capsule().fill(category.tint.opacity(solid ? 0.18 : 0.12)))
        .accessibilityLabel("Category: \(category.displayName)")
    }
}

/// Legacy alias.
struct CategoryChip: View {
    let category: IssueCategory
    var body: some View { CategoryTag(category: category) }
}
