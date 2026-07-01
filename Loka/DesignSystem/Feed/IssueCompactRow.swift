import SwiftUI

/// A dense one-line-ish issue row for search results and "related issues".
struct IssueCompactRow: View {
    let issue: Issue

    var body: some View {
        HStack(spacing: LokaSpacing.md) {
            RoundedRectangle(cornerRadius: LokaCorner.md, style: .continuous)
                .fill(issue.category.tint.opacity(0.14))
                .frame(width: 48, height: 48)
                .overlay(
                    Image(systemName: issue.category.systemImage)
                        .font(.system(size: LokaSize.iconMedium, weight: .semibold))
                        .foregroundStyle(issue.category.tint)
                )

            VStack(alignment: .leading, spacing: 3) {
                Text(issue.title)
                    .font(LokaFont.calloutEmphasized)
                    .foregroundStyle(LokaColor.textPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                HStack(spacing: LokaSpacing.xs) {
                    Text(issue.location.displayText)
                        .lineLimit(1)
                    Text("·")
                    Image(systemName: "hand.thumbsup.fill")
                    Text("\(issue.supportCount)")
                }
                .font(LokaFont.caption)
                .foregroundStyle(LokaColor.textSecondary)
            }

            Spacer(minLength: LokaSpacing.sm)
            StatusPill(status: issue.status)
        }
        .padding(LokaSpacing.md)
        .background(LokaColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: LokaCorner.lg, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: LokaCorner.lg, style: .continuous)
                .strokeBorder(LokaColor.border, lineWidth: 0.5)
        )
    }
}
