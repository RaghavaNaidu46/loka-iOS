import SwiftUI

/// Visualizes an issue's support/oppose split as a single proportional bar,
/// with optional counts underneath.
struct ParticipationBar: View {
    let supportCount: Int
    let opposeCount: Int
    var showCounts: Bool = true

    private var total: Int { supportCount + opposeCount }
    private var supportRatio: Double {
        guard total > 0 else { return 0 }
        return Double(supportCount) / Double(total)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: LokaSpacing.sm) {
            GeometryReader { geo in
                HStack(spacing: 2) {
                    Capsule()
                        .fill(LokaColor.support)
                        .frame(width: max(total == 0 ? 0 : 6, geo.size.width * supportRatio))
                    Capsule()
                        .fill(LokaColor.oppose)
                    if total == 0 {
                        Capsule().fill(LokaColor.surfaceElevated)
                    }
                }
            }
            .frame(height: 8)
            .clipShape(Capsule())
            .background(Capsule().fill(LokaColor.surfaceElevated))
            .animation(LokaAnimation.smooth, value: supportRatio)

            if showCounts {
                HStack(spacing: LokaSpacing.lg) {
                    countLabel(icon: "hand.thumbsup.fill", value: supportCount, tint: LokaColor.support, label: "Support")
                    countLabel(icon: "hand.thumbsdown.fill", value: opposeCount, tint: LokaColor.oppose, label: "Oppose")
                    Spacer()
                    Text("\(Int(supportRatio * 100))% support")
                        .font(LokaFont.caption)
                        .foregroundStyle(LokaColor.textTertiary)
                }
            }
        }
    }

    private func countLabel(icon: String, value: Int, tint: Color, label: String) -> some View {
        HStack(spacing: LokaSpacing.xs) {
            Image(systemName: icon)
                .font(.system(size: LokaSize.iconSmall, weight: .semibold))
                .foregroundStyle(tint)
            Text("\(value)")
                .font(LokaFont.captionEmphasized)
                .foregroundStyle(LokaColor.textPrimary)
        }
        .accessibilityLabel("\(label): \(value)")
    }
}
