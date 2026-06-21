import SwiftUI

enum LokaFont {
    static let displayLarge = Font.system(size: 40, weight: .bold, design: .default)
    static let headingLarge = Font.system(size: 28, weight: .semibold, design: .default)
    static let headingMedium = Font.system(size: 22, weight: .semibold, design: .default)
    static let headingSmall = Font.system(size: 18, weight: .semibold, design: .default)
    static let body = Font.system(size: 16, weight: .regular, design: .default)
    static let bodyEmphasized = Font.system(size: 16, weight: .semibold, design: .default)
    static let caption = Font.system(size: 13, weight: .regular, design: .default)
    static let statusLabel = Font.system(size: 12, weight: .semibold, design: .default)
}

enum LokaSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
}

enum LokaCorner {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
}
