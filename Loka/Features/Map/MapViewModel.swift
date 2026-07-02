import Foundation
import CoreLocation

/// A single issue plotted on the map.
struct IssueAnnotation: Identifiable {
    let id: String
    let issue: Issue
    let coordinate: CLLocationCoordinate2D
}

/// A per-area issue count, shown as a floating "beak" badge above the pins.
struct AreaCount: Identifiable {
    let id: String
    let coordinate: CLLocationCoordinate2D
    let count: Int
}

@MainActor
final class MapViewModel: ObservableObject {
    /// Issues that have a resolvable location, ready to drop as pins. Computed
    /// once when `issues` changes (not per render).
    @Published private(set) var annotations: [IssueAnnotation] = []
    @Published var isLoading = false

    @Published private(set) var issues: [Issue] = [] {
        didSet {
            annotations = issues.compactMap { issue in
                guard let c = issue.mapCoordinate else { return nil }
                return IssueAnnotation(id: issue.id, issue: issue, coordinate: c.clCoordinate)
            }
        }
    }

    private let repository: IssueRepository

    init(repository: IssueRepository = HTTPIssueRepository()) {
        self.repository = repository
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }

        #if DEBUG
        if DebugSettings.shared.useSampleData {
            issues = SampleFeed.issues
            return
        }
        #endif

        // Merge the feed sections so the map reflects all current issues.
        async let nearby = try? repository.feedNearby()
        async let fresh = try? repository.feedNew()
        async let priority = try? repository.feedCommunityPriority()
        async let resolved = try? repository.feedResolved()
        let all = (await nearby ?? []) + (await fresh ?? []) + (await priority ?? []) + (await resolved ?? [])

        var seen = Set<String>()
        issues = all.filter { seen.insert($0.id).inserted }
    }
}
