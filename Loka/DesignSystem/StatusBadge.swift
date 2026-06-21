import SwiftUI

struct StatusBadge: View {
    let status: IssueStatus

    var body: some View {
        Text(status.displayName.uppercased())
            .font(LokaFont.statusLabel)
            .foregroundStyle(LokaColor.statusColor(status))
            .padding(.horizontal, LokaSpacing.sm)
            .padding(.vertical, LokaSpacing.xs)
            .background(LokaColor.statusColor(status).opacity(0.12))
            .clipShape(Capsule())
    }
}

struct CategoryChip: View {
    let category: IssueCategory

    var body: some View {
        HStack(spacing: LokaSpacing.xs) {
            Image(systemName: category.systemImage)
            Text(category.displayName)
        }
        .font(LokaFont.caption)
        .foregroundStyle(LokaColor.textSecondary)
    }
}
