import Foundation

@MainActor
final class FeedViewModel: ObservableObject {
    @Published var nearby: [Issue] = []
    @Published var fresh: [Issue] = []
    @Published var priority: [Issue] = []
    @Published var resolved: [Issue] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let repository: IssueRepository

    init(repository: IssueRepository = HTTPIssueRepository()) {
        self.repository = repository
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        do {
            async let nearbyTask = repository.feedNearby()
            async let freshTask = repository.feedNew()
            async let priorityTask = repository.feedCommunityPriority()
            async let resolvedTask = repository.feedResolved()
            nearby = try await nearbyTask
            fresh = try await freshTask
            priority = try await priorityTask
            resolved = try await resolvedTask
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
