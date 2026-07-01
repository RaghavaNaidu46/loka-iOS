import SwiftUI

/// An elevated content container with consistent padding, rounding, and shadow.
struct LokaCard<Content: View>: View {
    var padding: CGFloat = LokaSpacing.lg
    var cornerRadius: CGFloat = LokaCorner.lg
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(LokaColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(LokaColor.border, lineWidth: 0.5)
            )
            .lokaShadow(.card)
    }
}
