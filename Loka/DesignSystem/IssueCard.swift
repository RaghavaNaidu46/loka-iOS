import SwiftUI

struct IssueCard: View {
    let issue: Issue

    var body: some View {
        VStack(alignment: .leading, spacing: LokaSpacing.md) {
            HStack(alignment: .top) {
                Text(issue.title)
                    .font(LokaFont.headingSmall)
                    .foregroundStyle(LokaColor.textPrimary)
                    .multilineTextAlignment(.leading)
                Spacer()
                StatusBadge(status: issue.status)
            }

            HStack(spacing: LokaSpacing.md) {
                CategoryChip(category: issue.category)
                Text("·").foregroundStyle(LokaColor.textTertiary)
                Label(issue.location.displayText, systemImage: "mappin.and.ellipse")
                    .font(LokaFont.caption)
                    .foregroundStyle(LokaColor.textSecondary)
                    .lineLimit(1)
            }

            HStack(spacing: LokaSpacing.lg) {
                ParticipationStat(label: "Support", value: issue.supportCount, tint: LokaColor.civicGreen)
                ParticipationStat(label: "Oppose", value: issue.opposeCount, tint: LokaColor.warning)
                ParticipationStat(label: "Evidence", value: issue.evidenceCount, tint: LokaColor.accent)
                Spacer()
                Text(relativeDate)
                    .font(LokaFont.caption)
                    .foregroundStyle(LokaColor.textTertiary)
            }
        }
        .padding(LokaSpacing.lg)
        .background(LokaColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: LokaCorner.lg))
    }

    private var relativeDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: issue.updatedAt, relativeTo: Date())
    }
}

private struct ParticipationStat: View {
    let label: String
    let value: Int
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("\(value)")
                .font(LokaFont.bodyEmphasized)
                .foregroundStyle(tint)
            Text(label)
                .font(LokaFont.caption)
                .foregroundStyle(LokaColor.textSecondary)
        }
    }
}
