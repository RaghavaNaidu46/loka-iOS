import SwiftUI

/// Elevation tokens. Shadows are intentionally soft and, in dark mode, nearly
/// invisible (dark UIs read depth through surface lightness, not shadow).
struct LokaShadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat

    static let card = LokaShadow(
        color: LokaColor.adaptive(
            light: UIColor.black.withAlphaComponent(0.06),
            dark: UIColor.black.withAlphaComponent(0.30)
        ),
        radius: 16, x: 0, y: 8
    )

    static let floating = LokaShadow(
        color: LokaColor.adaptive(
            light: UIColor.black.withAlphaComponent(0.12),
            dark: UIColor.black.withAlphaComponent(0.45)
        ),
        radius: 24, x: 0, y: 12
    )
}

extension View {
    /// Applies a Loka elevation token.
    func lokaShadow(_ shadow: LokaShadow) -> some View {
        self.shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }
}
