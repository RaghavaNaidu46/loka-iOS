import SwiftUI

struct IssueDetailView: View {
    let issueId: String

    @EnvironmentObject private var router: AppRouter
    @StateObject private var viewModel = IssueDetailViewModel()
    @State private var showSupportConfirm = false
    @State private var showOpposeSheet = false

    var body: some View {
        Group {
            if let issue = viewModel.issue {
                loaded(issue)
            } else if viewModel.isLoading {
                loadingState
            } else {
                errorState
            }
        }
        .background(LokaColor.base)
        .navigationTitle("Issue")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.load(id: issueId) }
    }

    // MARK: - Loaded

    private func loaded(_ issue: Issue) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: LokaSpacing.xl) {
                hero(issue)
                participationSummary(issue)
                textSection(title: "The problem", icon: "exclamationmark.bubble.fill", text: issue.description)
                textSection(title: "Desired outcome", icon: "target", text: issue.desiredOutcome)
                evidenceSection(issue)
                commentsSection
                relatedSection
            }
            .padding(LokaSpacing.lg)
            .padding(.bottom, LokaSpacing.xxl)
        }
        .scrollIndicators(.hidden)
        .safeAreaInset(edge: .bottom) { actionBar }
        .alert("Support is permanent", isPresented: $showSupportConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Support") { Haptics.success(); Task { await viewModel.support() } }
        } message: {
            Text("Support actions cannot be reversed or changed later.")
        }
        .sheet(isPresented: $showOpposeSheet) {
            OpposeSheet { explanation in
                Task { await viewModel.oppose(explanation: explanation) }
            }
        }
    }

    private func hero(_ issue: Issue) -> some View {
        VStack(alignment: .leading, spacing: LokaSpacing.md) {
            HStack(spacing: LokaSpacing.sm) {
                StatusPill(status: issue.status)
                CategoryTag(category: issue.category)
                Spacer()
            }
            Text(issue.title)
                .font(LokaFont.headingLarge)
                .foregroundStyle(LokaColor.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: LokaSpacing.sm) {
                LokaAvatar(name: issue.creatorDisplayName, size: LokaSize.avatarSmall, isVerified: true)
                VStack(alignment: .leading, spacing: 0) {
                    Text(issue.creatorDisplayName)
                        .font(LokaFont.captionEmphasized)
                        .foregroundStyle(LokaColor.textPrimary)
                    HStack(spacing: 3) {
                        Image(systemName: "mappin.and.ellipse").font(.system(size: 9))
                        Text(issue.location.displayText)
                        Text("·")
                        Text(issue.createdAt.relativeString())
                    }
                    .font(LokaFont.caption)
                    .foregroundStyle(LokaColor.textSecondary)
                }
            }
        }
    }

    private func participationSummary(_ issue: Issue) -> some View {
        LokaCard {
            VStack(alignment: .leading, spacing: LokaSpacing.md) {
                Text("Community response")
                    .font(LokaFont.headingSmall)
                    .foregroundStyle(LokaColor.textPrimary)
                ParticipationBar(supportCount: issue.supportCount, opposeCount: issue.opposeCount)
            }
        }
    }

    private func textSection(title: String, icon: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: LokaSpacing.sm) {
            Label(title, systemImage: icon)
                .font(LokaFont.headingSmall)
                .foregroundStyle(LokaColor.textPrimary)
            Text(text)
                .font(LokaFont.body)
                .foregroundStyle(LokaColor.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    @ViewBuilder
    private func evidenceSection(_ issue: Issue) -> some View {
        VStack(alignment: .leading, spacing: LokaSpacing.sm) {
            Label("Evidence", systemImage: "photo.stack.fill")
                .font(LokaFont.headingSmall)
                .foregroundStyle(LokaColor.textPrimary)
            if issue.evidenceCount == 0 {
                Text("No evidence uploaded.")
                    .font(LokaFont.callout)
                    .foregroundStyle(LokaColor.textSecondary)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: LokaSpacing.sm) {
                        ForEach(0..<issue.evidenceCount, id: \.self) { _ in
                            RoundedRectangle(cornerRadius: LokaCorner.md, style: .continuous)
                                .fill(LokaColor.surfaceElevated)
                                .frame(width: 120, height: 120)
                                .overlay(Image(systemName: "photo").font(.system(size: 28)).foregroundStyle(LokaColor.textTertiary))
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var commentsSection: some View {
        VStack(alignment: .leading, spacing: LokaSpacing.md) {
            Label("Discussion", systemImage: "bubble.left.and.bubble.right.fill")
                .font(LokaFont.headingSmall)
                .foregroundStyle(LokaColor.textPrimary)
            if viewModel.comments.isEmpty {
                Text("No comments yet. Be the first to add context.")
                    .font(LokaFont.callout)
                    .foregroundStyle(LokaColor.textSecondary)
            } else {
                ForEach(viewModel.comments) { comment in
                    commentRow(comment)
                }
            }
        }
    }

    private func commentRow(_ comment: LokaComment) -> some View {
        HStack(alignment: .top, spacing: LokaSpacing.sm) {
            LokaAvatar(name: comment.citizenDisplayName, size: LokaSize.avatarSmall)
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: LokaSpacing.xs) {
                    Text(comment.citizenDisplayName)
                        .font(LokaFont.captionEmphasized)
                        .foregroundStyle(LokaColor.textPrimary)
                    Text(comment.createdAt.relativeString())
                        .font(LokaFont.caption)
                        .foregroundStyle(LokaColor.textTertiary)
                }
                Text(comment.text)
                    .font(LokaFont.callout)
                    .foregroundStyle(LokaColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(LokaSpacing.md)
        .background(LokaColor.surface, in: RoundedRectangle(cornerRadius: LokaCorner.md, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: LokaCorner.md, style: .continuous).strokeBorder(LokaColor.border, lineWidth: 0.5))
    }

    @ViewBuilder
    private var relatedSection: some View {
        if !viewModel.related.isEmpty {
            VStack(alignment: .leading, spacing: LokaSpacing.md) {
                Label("Related issues", systemImage: "square.stack.3d.up.fill")
                    .font(LokaFont.headingSmall)
                    .foregroundStyle(LokaColor.textPrimary)
                ForEach(viewModel.related) { related in
                    NavigationLink(value: IssueRoute.detail(id: related.id)) {
                        IssueCompactRow(issue: related)
                    }
                    .buttonStyle(PressableButtonStyle())
                }
            }
        }
    }

    // MARK: - Sticky action bar

    @ViewBuilder
    private var actionBar: some View {
        if let participation = viewModel.participation {
            participatedBanner(participation)
        } else if viewModel.issue != nil {
            HStack(spacing: LokaSpacing.md) {
                LokaButton(title: "Support", systemImage: "hand.thumbsup.fill", style: .primary) {
                    showSupportConfirm = true
                }
                LokaButton(title: "Oppose", systemImage: "hand.thumbsdown.fill", style: .secondary) {
                    showOpposeSheet = true
                }
            }
            .padding(LokaSpacing.lg)
            .background(.ultraThinMaterial)
            .overlay(alignment: .top) { Divider().overlay(LokaColor.divider) }
        }
    }

    private func participatedBanner(_ participation: ParticipationRecord) -> some View {
        let supported = participation.type == .support
        return HStack(spacing: LokaSpacing.sm) {
            Image(systemName: supported ? "checkmark.seal.fill" : "hand.thumbsdown.fill")
                .foregroundStyle(supported ? LokaColor.support : LokaColor.oppose)
            VStack(alignment: .leading, spacing: 1) {
                Text(supported ? "You supported this issue" : "You opposed this issue")
                    .font(LokaFont.calloutEmphasized)
                    .foregroundStyle(LokaColor.textPrimary)
                Text("Participation is permanent and cannot be changed.")
                    .font(LokaFont.caption)
                    .foregroundStyle(LokaColor.textSecondary)
            }
            Spacer()
        }
        .padding(LokaSpacing.lg)
        .background(.ultraThinMaterial)
        .overlay(alignment: .top) { Divider().overlay(LokaColor.divider) }
    }

    // MARK: - Loading / error

    private var loadingState: some View {
        VStack(spacing: LokaSpacing.lg) {
            ForEach(0..<3, id: \.self) { _ in IssueCardSkeleton() }
        }
        .padding(LokaSpacing.lg)
    }

    private var errorState: some View {
        EmptyStateView(
            systemImage: "exclamationmark.triangle.fill",
            title: "Couldn't load issue",
            message: viewModel.errorMessage ?? "Please try again.",
            tint: LokaColor.danger,
            actionTitle: "Retry"
        ) { Task { await viewModel.load(id: issueId) } }
        .padding(LokaSpacing.lg)
    }
}

// MARK: - Oppose sheet

private struct OpposeSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var explanation: String = ""
    @State private var showConfirm = false
    let onSubmit: (String) -> Void

    private let minimum = 30
    private var isValid: Bool { explanation.count >= minimum }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: LokaSpacing.lg) {
                    Text("Opposition requires a constructive explanation. This action is permanent.")
                        .font(LokaFont.callout)
                        .foregroundStyle(LokaColor.textSecondary)

                    ZStack(alignment: .topLeading) {
                        if explanation.isEmpty {
                            Text("Explain your concern and what you'd change…")
                                .font(LokaFont.body)
                                .foregroundStyle(LokaColor.textTertiary)
                                .padding(LokaSpacing.md)
                        }
                        TextEditor(text: $explanation)
                            .font(LokaFont.body)
                            .scrollContentBackground(.hidden)
                            .frame(minHeight: 180)
                            .padding(LokaSpacing.sm)
                    }
                    .background(LokaColor.surface, in: RoundedRectangle(cornerRadius: LokaCorner.md, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: LokaCorner.md, style: .continuous).strokeBorder(LokaColor.border, lineWidth: 1))

                    HStack {
                        Spacer()
                        Text("\(explanation.count)/\(minimum) minimum")
                            .font(LokaFont.caption)
                            .foregroundStyle(isValid ? LokaColor.support : LokaColor.textTertiary)
                    }

                    LokaButton(title: "Continue", style: .primary) {
                        if isValid { Haptics.warning(); showConfirm = true }
                    }
                    .opacity(isValid ? 1 : 0.5)
                }
                .padding(LokaSpacing.lg)
            }
            .background(LokaColor.base)
            .navigationTitle("Oppose")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .alert("Opposition is permanent", isPresented: $showConfirm) {
                Button("Cancel", role: .cancel) {}
                Button("Oppose", role: .destructive) {
                    onSubmit(explanation)
                    dismiss()
                }
            } message: {
                Text("Your opposition cannot be reversed.")
            }
        }
    }
}
