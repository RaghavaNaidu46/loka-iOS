import CoreGraphics

/// Spacing scale (4pt grid).
enum LokaSpacing {
    static let xxs: CGFloat = 2
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
    static let xxxl: CGFloat = 48
}

/// Corner radii. Loka leans on generous, soft rounding.
enum LokaCorner {
    static let sm: CGFloat = 10
    static let md: CGFloat = 14
    static let lg: CGFloat = 20
    static let xl: CGFloat = 28
    static let pill: CGFloat = 999
}

/// Icon sizing and touch-target guidance.
enum LokaSize {
    static let iconSmall: CGFloat = 14
    static let iconMedium: CGFloat = 18
    static let iconLarge: CGFloat = 24
    static let avatarSmall: CGFloat = 32
    static let avatarMedium: CGFloat = 44
    static let avatarLarge: CGFloat = 72
    static let minTapTarget: CGFloat = 44
    static let controlHeight: CGFloat = 52
    /// Bottom padding scroll content needs to clear the floating tab bar.
    static let tabBarClearance: CGFloat = 96
}
