import SwiftUI

/// A selectable pill used for feed filters and search facets.
struct FilterChip: View {
    let title: String
    var systemImage: String?
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button {
            Haptics.selection()
            action()
        } label: {
            HStack(spacing: LokaSpacing.xs) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: LokaSize.iconSmall, weight: .semibold))
                }
                Text(title)
                    .font(LokaFont.captionEmphasized)
            }
            .foregroundStyle(isSelected ? LokaColor.onBrand : LokaColor.textSecondary)
            .padding(.horizontal, LokaSpacing.md)
            .padding(.vertical, LokaSpacing.sm)
            .background {
                if isSelected {
                    Capsule().fill(LokaColor.brand)
                } else {
                    Capsule().fill(LokaColor.surface)
                        .overlay(Capsule().strokeBorder(LokaColor.border, lineWidth: 1))
                }
            }
        }
        .buttonStyle(PressableButtonStyle(scale: 0.94))
        .animation(LokaAnimation.snappy, value: isSelected)
    }
}
