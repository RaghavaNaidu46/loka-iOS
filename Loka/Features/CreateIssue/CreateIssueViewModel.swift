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
    )
    @Published var duplicates: [Issue] = []
    @Published var isSubmitting = false
    @Published var submittedIssue: Issue?
    @Published var errorMessage: String?

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

    func detectDuplicates() async {
        guard let districtId = draft.district?.id, !draft.title.isEmpty else {
            duplicates = []
            return
        }
        duplicates = (try? await service.detectDuplicates(title: draft.title, districtId: districtId)) ?? []
    }

    func submit() async {
        guard canSubmit else { return }
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
