import SwiftUI

/// A friendly empty / error state: icon in a tinted circle, title, message, and
/// an optional call to action.
struct EmptyStateView: View {
    let systemImage: String
    let title: String
    let message: String
    var tint: Color = LokaColor.brand
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        VStack(spacing: LokaSpacing.md) {
            ZStack {
                Circle()
                    .fill(tint.opacity(0.12))
                    .frame(width: 88, height: 88)
                Image(systemName: systemImage)
                    .font(.system(size: 34, weight: .medium))
                    .foregroundStyle(tint)
            }
            Text(title)
                .font(LokaFont.headingSmall)
                .foregroundStyle(LokaColor.textPrimary)
            Text(message)
                .font(LokaFont.callout)
                .foregroundStyle(LokaColor.textSecondary)
                .multilineTextAlignment(.center)
            if let actionTitle, let action {
                LokaButton(title: actionTitle, style: .secondary, fullWidth: false, action: action)
                    .padding(.top, LokaSpacing.xs)
            }
        }
        .padding(LokaSpacing.xl)
        .frame(maxWidth: .infinity)
    }
}

/// Section heading with optional subtitle and a trailing action.
struct SectionHeader: View {
    let title: String
    var subtitle: String?
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
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
            Spacer()
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .font(LokaFont.captionEmphasized)
                    .foregroundStyle(LokaColor.brand)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
