import Foundation

/// Segments for the unified home feed.
enum FeedFilter: String, CaseIterable, Identifiable {
    case all
    case nearby
    case fresh
    case priority
    case resolved

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all: return "For You"
        case .nearby: return "Nearby"
        case .fresh: return "New"
        case .priority: return "Priority"
        case .resolved: return "Resolved"
        }
    }

    var systemImage: String {
        switch self {
        case .all: return "sparkles"
        case .nearby: return "location.fill"
        case .fresh: return "clock.fill"
        case .priority: return "flame.fill"
        case .resolved: return "checkmark.seal.fill"
        }
    }
}
