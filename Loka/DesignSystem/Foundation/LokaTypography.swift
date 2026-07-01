import SwiftUI

/// Type scale for Loka.
///
/// Headings use a rounded design for brand warmth; body text uses the default
/// system face for legibility. Sizes are relative to a Dynamic Type text style
/// so the whole app scales with the user's accessibility settings.
enum LokaFont {
    static let displayLarge = Font.system(.largeTitle, design: .rounded).weight(.bold)
    static let displayMedium = Font.system(.title, design: .rounded).weight(.bold)
    static let headingLarge = Font.system(.title2, design: .rounded).weight(.semibold)
    static let headingMedium = Font.system(.title3, design: .rounded).weight(.semibold)
    static let headingSmall = Font.system(.headline, design: .rounded).weight(.semibold)

    static let body = Font.system(.body)
    static let bodyEmphasized = Font.system(.body).weight(.semibold)
    static let callout = Font.system(.callout)
    static let calloutEmphasized = Font.system(.callout).weight(.semibold)

    static let caption = Font.system(.footnote)
    static let captionEmphasized = Font.system(.footnote).weight(.semibold)
    static let statusLabel = Font.system(.caption2, design: .rounded).weight(.bold)

    /// Tabular figures for count/stat displays so numbers don't jitter.
    static func number(_ style: Font.TextStyle = .title3) -> Font {
        Font.system(style, design: .rounded).weight(.bold)
    }
}
