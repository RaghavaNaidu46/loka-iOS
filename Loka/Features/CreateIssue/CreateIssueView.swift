import SwiftUI

struct CreateIssueView: View {
    @EnvironmentObject private var session: AppSessionManager
    @StateObject private var viewModel = CreateIssueViewModel()

    var body: some View {
        NavigationStack {
            if session.citizenState != .verified {
                gatedView
            } else if let submitted = viewModel.submittedIssue {
                submittedView(submitted)
            } else {
                formView
            }
        }
    }

    private var gatedView: some View {
        VStack(spacing: LokaSpacing.lg) {
            Image(systemName: "lock.shield")
                .font(.system(size: 48))
                .foregroundStyle(LokaColor.accent)
            Text("Verification required")
                .font(LokaFont.headingMedium)
            Text("Only verified citizens can create civic issues. Verify with Aadhaar Offline XML to participate.")
                .font(LokaFont.body)
                .foregroundStyle(LokaColor.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, LokaSpacing.xl)
            NavigationLink {
                BecomeCitizenView()
            } label: {
                Text("Become a Citizen")
                    .font(LokaFont.bodyEmphasized)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, minHeight: 48)
                    .background(LokaColor.accent)
                    .clipShape(RoundedRectangle(cornerRadius: LokaCorner.md))
                    .padding(.horizontal, LokaSpacing.lg)
            }
            Spacer()
        }
        .padding(.top, LokaSpacing.xxl)
        .navigationTitle("Create Issue")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func submittedView(_ issue: Issue) -> some View {
        VStack(spacing: LokaSpacing.lg) {
            Image(systemName: "checkmark.seal")
                .font(.system(size: 48))
                .foregroundStyle(LokaColor.civicGreen)
            Text("Submitted for review")
                .font(LokaFont.headingMedium)
            Text("Your issue \"\(issue.title)\" was submitted. A moderator will review it shortly.")
                .font(LokaFont.body)
                .foregroundStyle(LokaColor.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, LokaSpacing.xl)
            PrimaryButton(title: "Submit another") {
                viewModel.submittedIssue = nil
                viewModel.draft.title = ""
                viewModel.draft.description = ""
                viewModel.draft.desiredOutcome = ""
            }
            .padding(.horizontal, LokaSpacing.lg)
            Spacer()
        }
        .padding(.top, LokaSpacing.xxl)
        .navigationTitle("Create Issue")
    }

    private var formView: some View {
        Form {
            Section("Title") {
                TextField("Short, specific description", text: $viewModel.draft.title, axis: .vertical)
                    .lineLimit(2)
            }
            Section("Category") {
                Picker("Category", selection: $viewModel.draft.category) {
                    ForEach(IssueCategory.allCases) { Text($0.displayName).tag($0) }
                }
            }
            Section("Location") {
                Picker("District", selection: $viewModel.draft.district) {
                    ForEach(LokaRegion.sampleDistricts) { Text($0.name).tag(Optional($0)) }
                }
                TextField("City", text: $viewModel.draft.city)
                TextField("Area / ward (optional)", text: $viewModel.draft.area)
            }
            Section("Problem description") {
                TextField("What is happening?", text: $viewModel.draft.description, axis: .vertical)
                    .lineLimit(4...8)
            }
            Section("Desired outcome") {
                TextField("What resolution do you expect?", text: $viewModel.draft.desiredOutcome, axis: .vertical)
                    .lineLimit(3...6)
            }
            if !viewModel.duplicates.isEmpty {
                Section("Possible duplicates") {
                    ForEach(viewModel.duplicates) { duplicate in
                        VStack(alignment: .leading) {
                            Text(duplicate.title).font(LokaFont.bodyEmphasized)
                            Text(duplicate.location.displayText).font(LokaFont.caption).foregroundStyle(LokaColor.textSecondary)
                        }
                    }
                }
            }
            Section {
                PrimaryButton(title: "Submit for review", isLoading: viewModel.isSubmitting) {
                    Task { await viewModel.submit() }
                }
                .disabled(!viewModel.canSubmit)
            }
        }
        .navigationTitle("Create Issue")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: viewModel.draft.title) { _, _ in
            Task { await viewModel.detectDuplicates() }
        }
    }
}
