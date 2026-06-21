import SwiftUI

struct IssueDetailView: View {
    let issueId: String

    @StateObject private var viewModel = IssueDetailViewModel()
    @State private var showSupportConfirm = false
    @State private var showOpposeSheet = false

    var body: some View {
        ScrollView {
            if let issue = viewModel.issue {
                VStack(alignment: .leading, spacing: LokaSpacing.xl) {
                    header(issue)
                    section(title: "Problem") { Text(issue.description).font(LokaFont.body) }
                    section(title: "Desired Outcome") { Text(issue.desiredOutcome).font(LokaFont.body) }
                    evidenceSection(issue)
                    participationSummary(issue)
                    participationActions(issue)
                    commentsSection
                    relatedSection
                }
                .padding(LokaSpacing.lg)
            } else if viewModel.isLoading {
                ProgressView().padding(LokaSpacing.xxl)
            } else if let error = viewModel.errorMessage {
                EmptyStateView(systemImage: "exclamationmark.triangle", title: "Could not load issue", message: error)
                    .padding(LokaSpacing.lg)
            }
        }
        .background(LokaColor.background)
        .navigationTitle("Issue")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.load(id: issueId) }
        .alert("Support is permanent", isPresented: $showSupportConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Support") { Task { await viewModel.support() } }
        } message: {
            Text("Support actions cannot be reversed or changed later.")
        }
        .sheet(isPresented: $showOpposeSheet) {
            OpposeSheet { explanation in
                Task { await viewModel.oppose(explanation: explanation) }
            }
        }
    }

    @ViewBuilder
    private func header(_ issue: Issue) -> some View {
        VStack(alignment: .leading, spacing: LokaSpacing.sm) {
            HStack {
                StatusBadge(status: issue.status)
                CategoryChip(category: issue.category)
                Spacer()
            }
            Text(issue.title)
                .font(LokaFont.headingLarge)
                .foregroundStyle(LokaColor.textPrimary)
            Label(issue.location.displayText, systemImage: "mappin.and.ellipse")
                .font(LokaFont.caption)
                .foregroundStyle(LokaColor.textSecondary)
        }
    }

    @ViewBuilder
    private func section<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: LokaSpacing.sm) {
            Text(title)
                .font(LokaFont.headingSmall)
                .foregroundStyle(LokaColor.textPrimary)
            content()
                .foregroundStyle(LokaColor.textSecondary)
        }
    }

    @ViewBuilder
    private func evidenceSection(_ issue: Issue) -> some View {
        VStack(alignment: .leading, spacing: LokaSpacing.sm) {
            Text("Evidence")
                .font(LokaFont.headingSmall)
                .foregroundStyle(LokaColor.textPrimary)
            if issue.evidenceCount == 0 {
                Text("No evidence uploaded.")
                    .font(LokaFont.body)
                    .foregroundStyle(LokaColor.textSecondary)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: LokaSpacing.sm) {
                        ForEach(0..<issue.evidenceCount, id: \.self) { _ in
                            RoundedRectangle(cornerRadius: LokaCorner.sm)
                                .fill(LokaColor.surface)
                                .frame(width: 96, height: 96)
                                .overlay(Image(systemName: "photo").foregroundStyle(LokaColor.textTertiary))
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func participationSummary(_ issue: Issue) -> some View {
        VStack(alignment: .leading, spacing: LokaSpacing.sm) {
            Text("Participation")
                .font(LokaFont.headingSmall)
                .foregroundStyle(LokaColor.textPrimary)
            HStack(spacing: LokaSpacing.xl) {
                VStack(alignment: .leading) {
                    Text("\(issue.supportCount)")
                        .font(LokaFont.headingMedium)
                        .foregroundStyle(LokaColor.civicGreen)
                    Text("Support")
                        .font(LokaFont.caption)
                        .foregroundStyle(LokaColor.textSecondary)
                }
                VStack(alignment: .leading) {
                    Text("\(issue.opposeCount)")
                        .font(LokaFont.headingMedium)
                        .foregroundStyle(LokaColor.warning)
                    Text("Oppose")
                        .font(LokaFont.caption)
                        .foregroundStyle(LokaColor.textSecondary)
                }
                VStack(alignment: .leading) {
                    Text("\(Int(issue.supportRatio * 100))%")
                        .font(LokaFont.headingMedium)
                        .foregroundStyle(LokaColor.accent)
                    Text("Support ratio")
                        .font(LokaFont.caption)
                        .foregroundStyle(LokaColor.textSecondary)
                }
            }
        }
    }

    @ViewBuilder
    private func participationActions(_ issue: Issue) -> some View {
        VStack(spacing: LokaSpacing.sm) {
            if let participation = viewModel.participation {
                Text(participation.type == .support ? "You have supported this issue." : "You have opposed this issue.")
                    .font(LokaFont.bodyEmphasized)
                    .foregroundStyle(LokaColor.textPrimary)
                Text("Participation is permanent and cannot be changed.")
                    .font(LokaFont.caption)
                    .foregroundStyle(LokaColor.textSecondary)
            } else {
                PrimaryButton(title: "Support") { showSupportConfirm = true }
                SecondaryButton(title: "Oppose with explanation") { showOpposeSheet = true }
            }
        }
    }

    @ViewBuilder
    private var commentsSection: some View {
        VStack(alignment: .leading, spacing: LokaSpacing.sm) {
            Text("Discussion")
                .font(LokaFont.headingSmall)
                .foregroundStyle(LokaColor.textPrimary)
            if viewModel.comments.isEmpty {
                Text("No comments yet.")
                    .font(LokaFont.body)
                    .foregroundStyle(LokaColor.textSecondary)
            } else {
                ForEach(viewModel.comments) { comment in
                    VStack(alignment: .leading, spacing: LokaSpacing.xs) {
                        Text(comment.citizenDisplayName)
                            .font(LokaFont.bodyEmphasized)
                            .foregroundStyle(LokaColor.textPrimary)
                        Text(comment.text)
                            .font(LokaFont.body)
                            .foregroundStyle(LokaColor.textSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(LokaSpacing.md)
                    .background(LokaColor.surface)
                    .clipShape(RoundedRectangle(cornerRadius: LokaCorner.sm))
                }
            }
        }
    }

    @ViewBuilder
    private var relatedSection: some View {
        if !viewModel.related.isEmpty {
            VStack(alignment: .leading, spacing: LokaSpacing.sm) {
                Text("Related issues")
                    .font(LokaFont.headingSmall)
                    .foregroundStyle(LokaColor.textPrimary)
                ForEach(viewModel.related) { related in
                    NavigationLink(value: IssueRoute.detail(id: related.id)) {
                        IssueCard(issue: related)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

private struct OpposeSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var explanation: String = ""
    @State private var showConfirm = false
    let onSubmit: (String) -> Void

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: LokaSpacing.lg) {
                Text("Opposition requires a constructive explanation. This action is permanent.")
                    .font(LokaFont.body)
                    .foregroundStyle(LokaColor.textSecondary)
                TextEditor(text: $explanation)
                    .frame(minHeight: 160)
                    .padding(LokaSpacing.sm)
                    .background(LokaColor.surface)
                    .clipShape(RoundedRectangle(cornerRadius: LokaCorner.sm))
                Text("\(explanation.count)/30 minimum")
                    .font(LokaFont.caption)
                    .foregroundStyle(explanation.count >= 30 ? LokaColor.civicGreen : LokaColor.textTertiary)
                Spacer()
                PrimaryButton(title: "Continue") {
                    if explanation.count >= 30 { showConfirm = true }
                }
            }
            .padding(LokaSpacing.lg)
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
