import Foundation

@MainActor
final class FeedViewModel: ObservableObject {
    @Published var nearby: [Issue] = []
    @Published var fresh: [Issue] = []
    @Published var priority: [Issue] = []
    @Published var resolved: [Issue] = []
    /// The merged "For You" list, computed once per load (not per render) so the
    /// dedupe + sort cost doesn't repeat on every SwiftUI update as data grows.
    @Published private(set) var merged: [Issue] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let repository: IssueRepository

    init(repository: IssueRepository = HTTPIssueRepository()) {
        self.repository = repository
    }

    /// Returns the issues that back a given feed filter.
    func issues(for filter: FeedFilter) -> [Issue] {
        switch filter {
        case .all: return merged
        case .nearby: return nearby
        case .fresh: return fresh
        case .priority: return priority
        case .resolved: return resolved
        }
    }

    /// Recompute the merged, de-duplicated "For You" list (newest first). Called
    /// once after a load rather than on every access.
    private func rebuildMerged() {
        var seen = Set<String>()
        merged = (nearby + fresh + priority + resolved)
            .filter { seen.insert($0.id).inserted }
            .sorted { $0.updatedAt > $1.updatedAt }
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
            rebuildMerged()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
