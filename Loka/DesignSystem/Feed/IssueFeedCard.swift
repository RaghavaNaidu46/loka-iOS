import SwiftUI

/// The primary social-feed unit for an issue.
///
/// Layout: author row (avatar · name · district · time) → title + snippet →
/// category / status tags → optional evidence thumbnail strip →
/// participation bar → footer counts.
struct IssueFeedCard: View {
    let issue: Issue

    var body: some View {
        LokaCard {
            VStack(alignment: .leading, spacing: LokaSpacing.md) {
                authorRow
                content
                if !issue.media.isEmpty {
                    PostMediaView(media: issue.media, interactive: false)
                } else if issue.evidenceCount > 0 {
                    evidenceStrip
                }
                if let link = issue.link {
                    LinkPreviewCard(link: link, interactive: false)
                }
                if let poll = issue.poll {
                    PollView(poll: poll, interactive: false)
                }
                tagRow
                Divider().overlay(LokaColor.divider)
                ParticipationBar(supportCount: issue.supportCount, opposeCount: issue.opposeCount)
            }
        }
    }

    // MARK: - Sections

    private var authorRow: some View {
        HStack(spacing: LokaSpacing.sm) {
            LokaAvatar(name: issue.creatorDisplayName, size: LokaSize.avatarMedium, isVerified: true)
            VStack(alignment: .leading, spacing: 1) {
                Text(issue.creatorDisplayName)
                    .font(LokaFont.calloutEmphasized)
                    .foregroundStyle(LokaColor.textPrimary)
                HStack(spacing: LokaSpacing.xs) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 10))
                    Text(issue.location.displayText)
                        .lineLimit(1)
                    Text("·")
                    Text(issue.createdAt.relativeString())
                }
                .font(LokaFont.caption)
                .foregroundStyle(LokaColor.textSecondary)
            }
            Spacer()
            StatusPill(status: issue.status)
        }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: LokaSpacing.xs) {
            Text(issue.title)
                .font(LokaFont.headingSmall)
                .foregroundStyle(LokaColor.textPrimary)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
            Text(issue.description)
                .font(LokaFont.callout)
                .foregroundStyle(LokaColor.textSecondary)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
        }
    }

    private var tagRow: some View {
        HStack(spacing: LokaSpacing.sm) {
            CategoryTag(category: issue.category)
            Spacer()
        }
    }

    private var evidenceStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: LokaSpacing.sm) {
                ForEach(0..<min(issue.evidenceCount, 4), id: \.self) { index in
                    RoundedRectangle(cornerRadius: LokaCorner.sm, style: .continuous)
                        .fill(LokaColor.surfaceElevated)
                        .frame(width: 84, height: 84)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: LokaSize.iconLarge))
                                .foregroundStyle(LokaColor.textTertiary)
                        )
                        .overlay(alignment: .bottomTrailing) {
                            if index == 3 && issue.evidenceCount > 4 {
                                Text("+\(issue.evidenceCount - 4)")
                                    .font(LokaFont.captionEmphasized)
                                    .foregroundStyle(.white)
                                    .padding(4)
                                    .background(Circle().fill(.black.opacity(0.5)))
                                    .padding(4)
                            }
                        }
                }
            }
        }
        .accessibilityLabel("\(issue.evidenceCount) pieces of evidence")
    }
}
