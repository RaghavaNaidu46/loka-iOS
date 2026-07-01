import SwiftUI

struct CreateIssueView: View {
    @EnvironmentObject private var session: AppSessionManager
    @StateObject private var viewModel = CreateIssueViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if session.citizenState != .verified {
                    gatedView.transition(.opacity)
                } else if let submitted = viewModel.submittedIssue {
                    submittedView(submitted)
                        .transition(.scale(scale: 0.92).combined(with: .opacity))
                } else {
                    formView.transition(.opacity)
                }
            }
            .animation(LokaAnimation.smooth, value: viewModel.submittedIssue?.id)
            .animation(LokaAnimation.smooth, value: session.citizenState)
            .background(LokaColor.base)
            .navigationTitle("Raise an issue")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: - Gated

    private var gatedView: some View {
        ScrollView {
            VStack(spacing: LokaSpacing.lg) {
                EmptyStateView(
                    systemImage: "lock.shield.fill",
                    title: "Verification required",
                    message: "Only verified citizens can raise civic issues. Verify once with Aadhaar Offline XML to participate."
                )
                NavigationLink {
                    BecomeCitizenView()
                } label: {
                    Label("Become a Citizen", systemImage: "checkmark.seal.fill")
                        .font(LokaFont.calloutEmphasized)
                        .foregroundStyle(LokaColor.onBrand)
                        .frame(maxWidth: .infinity)
                        .frame(height: LokaSize.controlHeight)
                        .background(LokaColor.brandGradient, in: RoundedRectangle(cornerRadius: LokaCorner.md, style: .continuous))
                }
                .buttonStyle(PressableButtonStyle())
                .padding(.horizontal, LokaSpacing.lg)
            }
            .padding(.top, LokaSpacing.xxl)
            .padding(.bottom, LokaSize.tabBarClearance)
        }
    }

    // MARK: - Success

    private func submittedView(_ issue: Issue) -> some View {
        ScrollView {
            VStack(spacing: LokaSpacing.lg) {
                ZStack {
                    Circle().fill(LokaColor.support.opacity(0.14)).frame(width: 96, height: 96)
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(LokaColor.support)
                }
                Text("Submitted for review")
                    .font(LokaFont.headingLarge)
                    .foregroundStyle(LokaColor.textPrimary)
                Text("Your issue \u{201C}\(issue.title)\u{201D} was submitted. A moderator will review it shortly.")
                    .font(LokaFont.callout)
                    .foregroundStyle(LokaColor.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, LokaSpacing.xl)
                LokaButton(title: "Raise another", systemImage: "plus", style: .secondary, fullWidth: false) {
                    resetDraft()
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.top, LokaSpacing.xxl)
            .padding(.bottom, LokaSize.tabBarClearance)
        }
        .onAppear { Haptics.success() }
    }

    private func resetDraft() {
        viewModel.submittedIssue = nil
        viewModel.draft.title = ""
        viewModel.draft.description = ""
        viewModel.draft.desiredOutcome = ""
    }

    // MARK: - Form

    private var formView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: LokaSpacing.xl) {
                fieldGroup(title: "Title", hint: "Short, specific description") {
                    LokaTextField(placeholder: "e.g. Streetlights out on MG Road", text: $viewModel.draft.title, autocapitalization: .sentences, error: viewModel.titleError)
                        .onChange(of: viewModel.draft.title) { _, _ in
                            Task { await viewModel.detectDuplicates() }
                        }
                }

                duplicatesGroup

                fieldGroup(title: "Category") { categoryGrid }

                fieldGroup(title: "Location") {
                    VStack(spacing: LokaSpacing.sm) {
                        VStack(alignment: .leading, spacing: LokaSpacing.xs) {
                            districtMenu
                            FieldError(message: viewModel.districtError)
                        }
                        .animation(LokaAnimation.snappy, value: viewModel.districtError)
                        LokaTextField(placeholder: "City", text: $viewModel.draft.city, systemImage: "building.2", autocapitalization: .words)
                        LokaTextField(placeholder: "Area / ward (optional)", text: $viewModel.draft.area, systemImage: "map", autocapitalization: .words)
                    }
                }

                fieldGroup(title: "Problem description", hint: "Minimum 20 characters") {
                    editor(text: $viewModel.draft.description, placeholder: "What is happening, and who does it affect?", minHeight: 120, error: viewModel.descriptionError)
                }

                fieldGroup(title: "Desired outcome", hint: "Minimum 10 characters") {
                    editor(text: $viewModel.draft.desiredOutcome, placeholder: "What resolution do you expect?", minHeight: 90, error: viewModel.outcomeError)
                }

                if let error = viewModel.errorMessage {
                    Label(error, systemImage: "exclamationmark.triangle.fill")
                        .font(LokaFont.caption)
                        .foregroundStyle(LokaColor.danger)
                }

                LokaButton(title: "Submit for review", systemImage: "paperplane.fill", style: .primary, isLoading: viewModel.isSubmitting) {
                    Task { await viewModel.submit() }
                }
            }
            .padding(LokaSpacing.lg)
            .padding(.bottom, LokaSize.tabBarClearance)
        }
        .scrollIndicators(.hidden)
        .scrollDismissesKeyboard(.interactively)
    }

    // MARK: - Form pieces

    private func fieldGroup<Content: View>(title: String, hint: String? = nil, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: LokaSpacing.sm) {
            HStack(alignment: .firstTextBaseline) {
                Text(title)
                    .font(LokaFont.captionEmphasized)
                    .foregroundStyle(LokaColor.textPrimary)
                Spacer()
                if let hint {
                    Text(hint)
                        .font(LokaFont.caption)
                        .foregroundStyle(LokaColor.textTertiary)
                }
            }
            content()
        }
    }

    private var categoryGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 110), spacing: LokaSpacing.sm)], spacing: LokaSpacing.sm) {
            ForEach(IssueCategory.allCases) { category in
                let selected = viewModel.draft.category == category
                Button {
                    Haptics.selection()
                    withAnimation(LokaAnimation.snappy) { viewModel.draft.category = category }
                } label: {
                    HStack(spacing: LokaSpacing.xs) {
                        Image(systemName: category.systemImage)
                        Text(category.displayName)
                            .font(LokaFont.caption)
                        Spacer(minLength: 0)
                    }
                    .foregroundStyle(selected ? category.tint : LokaColor.textSecondary)
                    .padding(.horizontal, LokaSpacing.md)
                    .frame(height: 44)
                    .background(selected ? category.tint.opacity(0.14) : LokaColor.surface, in: RoundedRectangle(cornerRadius: LokaCorner.md, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: LokaCorner.md, style: .continuous)
                            .strokeBorder(selected ? category.tint : LokaColor.border, lineWidth: selected ? 1.5 : 1)
                    )
                }
                .buttonStyle(PressableButtonStyle(scale: 0.95))
            }
        }
    }

    private var districtMenu: some View {
        Menu {
            ForEach(LokaRegion.sampleDistricts) { district in
                Button("\(district.name), \(district.state)") { viewModel.draft.district = district }
            }
        } label: {
            HStack(spacing: LokaSpacing.sm) {
                Image(systemName: "mappin.and.ellipse").foregroundStyle(LokaColor.textTertiary)
                Text(viewModel.draft.district?.name ?? "Select district")
                    .font(LokaFont.body)
                    .foregroundStyle(viewModel.draft.district == nil ? LokaColor.textTertiary : LokaColor.textPrimary)
                Spacer()
                Image(systemName: "chevron.up.chevron.down").font(.system(size: 12)).foregroundStyle(LokaColor.textTertiary)
            }
            .padding(.horizontal, LokaSpacing.md)
            .frame(height: LokaSize.controlHeight)
            .background(LokaColor.surface, in: RoundedRectangle(cornerRadius: LokaCorner.md, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: LokaCorner.md, style: .continuous).strokeBorder(LokaColor.border, lineWidth: 1))
        }
    }

    private func editor(text: Binding<String>, placeholder: String, minHeight: CGFloat, error: String? = nil) -> some View {
        VStack(alignment: .leading, spacing: LokaSpacing.xs) {
            ZStack(alignment: .topLeading) {
                if text.wrappedValue.isEmpty {
                    Text(placeholder)
                        .font(LokaFont.body)
                        .foregroundStyle(LokaColor.textTertiary)
                        .padding(LokaSpacing.md)
                }
                TextEditor(text: text)
                    .font(LokaFont.body)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: minHeight)
                    .padding(LokaSpacing.sm)
            }
            .background(LokaColor.surface, in: RoundedRectangle(cornerRadius: LokaCorner.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: LokaCorner.md, style: .continuous)
                    .strokeBorder(error != nil ? LokaColor.danger : LokaColor.border, lineWidth: error != nil ? 1.5 : 1)
            )
            FieldError(message: error)
        }
        .animation(LokaAnimation.snappy, value: error)
    }

    @ViewBuilder
    private var duplicatesGroup: some View {
        if !viewModel.duplicates.isEmpty {
            VStack(alignment: .leading, spacing: LokaSpacing.sm) {
                Label("Possible duplicates", systemImage: "doc.on.doc.fill")
                    .font(LokaFont.captionEmphasized)
                    .foregroundStyle(LokaColor.oppose)
                ForEach(viewModel.duplicates) { duplicate in
                    IssueCompactRow(issue: duplicate)
                }
            }
            .padding(LokaSpacing.md)
            .background(LokaColor.oppose.opacity(0.08), in: RoundedRectangle(cornerRadius: LokaCorner.md, style: .continuous))
        }
    }
}

#Preview {
    CreateIssueView()
        .environmentObject(AppSessionManager())
}
