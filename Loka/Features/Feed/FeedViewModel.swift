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

    /// A merged, de-duplicated view across all sections, newest first.
    /// Presentation-only convenience for the unified feed — does not touch networking.
    var all: [Issue] {
        var seen = Set<String>()
        return (nearby + fresh + priority + resolved)
            .filter { seen.insert($0.id).inserted }
            .sorted { $0.updatedAt > $1.updatedAt }
    }

    /// Returns the issues that back a given feed filter.
    func issues(for filter: FeedFilter) -> [Issue] {
        switch filter {
        case .all: return all
        case .nearby: return nearby
        case .fresh: return fresh
        case .priority: return priority
        case .resolved: return resolved
        }
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
