import SwiftUI

struct EmptyStateView: View {
    let systemImage: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: LokaSpacing.md) {
            Image(systemName: systemImage)
                .font(.system(size: 36, weight: .regular))
                .foregroundStyle(LokaColor.textTertiary)
            Text(title)
                .font(LokaFont.headingSmall)
                .foregroundStyle(LokaColor.textPrimary)
            Text(message)
                .font(LokaFont.body)
                .foregroundStyle(LokaColor.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(LokaSpacing.xl)
        .frame(maxWidth: .infinity)
    }
}

struct SectionHeader: View {
    let title: String
    var subtitle: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(LokaFont.headingMedium)
                .foregroundStyle(LokaColor.textPrimary)
            if let subtitle {
                Text(subtitle)
                    .font(LokaFont.caption)
                    .foregroundStyle(LokaColor.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
