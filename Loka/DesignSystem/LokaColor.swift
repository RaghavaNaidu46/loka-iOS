import SwiftUI

enum LokaColor {
    static let accent = Color(red: 0.137, green: 0.380, blue: 0.529)
    static let civicGreen = Color(red: 0.180, green: 0.470, blue: 0.380)
    static let warning = Color(red: 0.780, green: 0.510, blue: 0.110)
    static let danger = Color(red: 0.700, green: 0.290, blue: 0.290)

    static let background = Color(.systemBackground)
    static let surface = Color(.secondarySystemBackground)
    static let surfaceElevated = Color(.tertiarySystemBackground)

    static let textPrimary = Color(.label)
    static let textSecondary = Color(.secondaryLabel)
    static let textTertiary = Color(.tertiaryLabel)

    static let divider = Color(.separator)

    static func statusColor(_ status: IssueStatus) -> Color {
        switch status {
        case .draft, .submitted, .underReview: return warning
        case .published, .active: return accent
        case .resolved: return civicGreen
        case .archived, .merged: return textTertiary
        case .rejected: return danger
        }
    }
}
