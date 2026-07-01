import Foundation

@MainActor
final class CreateIssueViewModel: ObservableObject {
    @Published var draft = IssueDraft(
        title: "",
        description: "",
        desiredOutcome: "",
        category: .roads,
        district: LokaRegion.sampleDistricts.first,
        area: "",
        city: ""
    ) {
        didSet {
            // Clear a field's error as soon as that field is edited.
            if draft.title != oldValue.title { titleError = nil }
            if draft.description != oldValue.description { descriptionError = nil }
            if draft.desiredOutcome != oldValue.desiredOutcome { outcomeError = nil }
            if draft.district?.id != oldValue.district?.id { districtError = nil }
        }
    }
    @Published var duplicates: [Issue] = []
    @Published var isSubmitting = false
    @Published var submittedIssue: Issue?
    @Published var errorMessage: String?

    /// Per-field validation errors, shown beneath each field.
    @Published var titleError: String?
    @Published var descriptionError: String?
    @Published var outcomeError: String?
    @Published var districtError: String?

    private let service: IssueService

    init(service: IssueService = HTTPIssueService()) {
        self.service = service
    }

    var canSubmit: Bool {
        !draft.title.isEmpty &&
        draft.description.count >= 20 &&
        draft.desiredOutcome.count >= 10 &&
        draft.district != nil
    }

    /// Populates every field error at once; returns whether the draft is valid.
    private func validate() -> Bool {
        var valid = true
        if draft.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            titleError = "Enter a title"; valid = false
        }
        if draft.description.count < 20 {
            descriptionError = "Describe the problem (at least 20 characters)"; valid = false
        }
        if draft.desiredOutcome.count < 10 {
            outcomeError = "Describe the outcome (at least 10 characters)"; valid = false
        }
        if draft.district == nil {
            districtError = "Select a district"; valid = false
        }
        return valid
    }

    func detectDuplicates() async {
        guard let districtId = draft.district?.id, !draft.title.isEmpty else {
            duplicates = []
            return
        }
        duplicates = (try? await service.detectDuplicates(title: draft.title, districtId: districtId)) ?? []
    }

    func submit() async {
        guard validate() else { return }
        isSubmitting = true
        errorMessage = nil
        do {
            submittedIssue = try await service.submit(draft)
        } catch {
            errorMessage = error.localizedDescription
        }
        isSubmitting = false
    }
}
