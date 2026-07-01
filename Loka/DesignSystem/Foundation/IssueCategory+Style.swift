import SwiftUI

/// Presentation-only styling for issue categories. Kept in the design system as
/// an extension so the `Issue` model stays free of UI concerns.
extension IssueCategory {
    /// A distinct tint per category, used for tags and icons.
    var tint: Color {
        switch self {
        case .roads: return LokaColor.adaptive(light: uiHex(0x7A5AF8), dark: uiHex(0x9B85FF))
        case .water: return LokaColor.adaptive(light: uiHex(0x2E9BD6), dark: uiHex(0x59B8ED))
        case .electricity: return LokaColor.adaptive(light: uiHex(0xE0A320), dark: uiHex(0xF2BE44))
        case .health: return LokaColor.adaptive(light: uiHex(0xE0574F), dark: uiHex(0xF07C74))
        case .education: return LokaColor.adaptive(light: uiHex(0x2F9E68), dark: uiHex(0x49C285))
        case .environment: return LokaColor.adaptive(light: uiHex(0x3F9C3A), dark: uiHex(0x63C25C))
        case .publicSafety: return LokaColor.adaptive(light: uiHex(0xC0463D), dark: uiHex(0xE06B62))
        case .governance: return LokaColor.adaptive(light: uiHex(0x5B6472), dark: uiHex(0x99A2B2))
        }
    }

    private func uiHex(_ value: UInt32) -> UIColor {
        UIColor(
            red: CGFloat((value >> 16) & 0xFF) / 255,
            green: CGFloat((value >> 8) & 0xFF) / 255,
            blue: CGFloat(value & 0xFF) / 255,
            alpha: 1
        )
    }
}
