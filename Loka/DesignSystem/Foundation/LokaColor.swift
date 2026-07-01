import SwiftUI

/// Adaptive color tokens for Loka.
///
/// Every token is defined with a dynamic `UIColor` provider so light and dark
/// appearances are first-class. Views should reference these semantic tokens
/// rather than raw `Color` literals so the whole app themes consistently.
enum LokaColor {

    // MARK: - Brand

    /// Primary brand color — a confident civic indigo/blue.
    static let brand = adaptive(
        light: hex(0x2B4EFF),
        dark: hex(0x6E86FF)
    )

    /// A deeper brand shade for gradients and pressed states.
    static let brandDeep = adaptive(
        light: hex(0x1B2FB8),
        dark: hex(0x4B63E6)
    )

    /// Soft brand tint for chips, selection backgrounds, and highlights.
    static let brandSoft = adaptive(
        light: hex(0x2B4EFF, alpha: 0.10),
        dark: hex(0x6E86FF, alpha: 0.18)
    )

    /// Brand gradient reserved for hero surfaces and primary CTAs.
    static var brandGradient: LinearGradient {
        LinearGradient(
            colors: [brand, brandDeep],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: - Semantic

    /// Support / positive civic action.
    static let support = adaptive(light: hex(0x1F9D5B), dark: hex(0x38C97F))
    /// Oppose / caution — amber, never aggressive red.
    static let oppose = adaptive(light: hex(0xC7871B), dark: hex(0xE5A93C))
    /// Destructive / error.
    static let danger = adaptive(light: hex(0xC4453F), dark: hex(0xE06B65))
    /// Informational accent.
    static let info = adaptive(light: hex(0x2E7BC4), dark: hex(0x5AA6E8))

    // MARK: - Layered surfaces

    /// The window background — the lowest layer.
    static let base = adaptive(light: hex(0xF5F6FA), dark: hex(0x0C0D12))
    /// Cards and primary content containers.
    static let surface = adaptive(light: hex(0xFFFFFF), dark: hex(0x16181F))
    /// Content raised above a surface (nested chips, inset fields).
    static let surfaceElevated = adaptive(light: hex(0xF0F2F8), dark: hex(0x21242E))
    /// Frosted bar / floating tab bar fill.
    static let barMaterial = adaptive(light: hex(0xFFFFFF, alpha: 0.86), dark: hex(0x16181F, alpha: 0.86))

    // MARK: - Text

    static let textPrimary = adaptive(light: hex(0x11131A), dark: hex(0xF4F5FA))
    static let textSecondary = adaptive(light: hex(0x5C6070), dark: hex(0xA2A7B8))
    static let textTertiary = adaptive(light: hex(0x9AA0B0), dark: hex(0x6C7183))
    /// Text/icon rendered on top of the brand fill.
    static let onBrand = Color.white

    // MARK: - Lines

    static let border = adaptive(light: hex(0x11131A, alpha: 0.08), dark: hex(0xFFFFFF, alpha: 0.10))
    static let divider = adaptive(light: hex(0x11131A, alpha: 0.06), dark: hex(0xFFFFFF, alpha: 0.07))

    // MARK: - Status mapping

    static func statusColor(_ status: IssueStatus) -> Color {
        switch status {
        case .draft, .submitted, .underReview: return oppose
        case .published, .active: return brand
        case .resolved: return support
        case .archived, .merged: return textTertiary
        case .rejected: return danger
        }
    }

    // MARK: - Dynamic helpers

    /// Builds a `Color` that resolves differently per interface style.
    static func adaptive(light: UIColor, dark: UIColor) -> Color {
        Color(UIColor { traits in
            traits.userInterfaceStyle == .dark ? dark : light
        })
    }

    private static func hex(_ value: UInt32, alpha: CGFloat = 1) -> UIColor {
        UIColor(
            red: CGFloat((value >> 16) & 0xFF) / 255,
            green: CGFloat((value >> 8) & 0xFF) / 255,
            blue: CGFloat(value & 0xFF) / 255,
            alpha: alpha
        )
    }
}
