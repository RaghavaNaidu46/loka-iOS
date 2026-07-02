import Foundation

struct Issue: Identifiable, Codable, Hashable {
    let id: String
    var title: String
    var description: String
    var desiredOutcome: String
    var category: IssueCategory
    var location: IssueLocation
    var status: IssueStatus
    var supportCount: Int
    var opposeCount: Int
    var evidenceCount: Int
    var createdAt: Date
    var updatedAt: Date
    var creatorDisplayName: String

    /// Optional rich content. Defaulted so decoding from `IssueDTO` and every
    /// existing initializer keep working; the backend has no media yet.
    var media: [PostMedia] = []
    var link: LinkPreview? = nil
    var poll: PostPoll? = nil

    /// Best available map coordinate: the issue's own point, else its district
    /// center (directly or by matching a known district id).
    var mapCoordinate: Coordinate? {
        location.coordinate ?? location.district.coordinate ?? LokaRegion.coordinate(forDistrictId: location.district.id)
    }

    var participationTotal: Int { supportCount + opposeCount }
    var supportRatio: Double {
        guard participationTotal > 0 else { return 0 }
        return Double(supportCount) / Double(participationTotal)
    }
}

struct IssueLocation: Codable, Hashable {
    var area: String?
    var city: String
    var district: District
    var coordinate: Coordinate? = nil

    var displayText: String {
        if let area, !area.isEmpty {
            return "\(area), \(city)"
        }
        return city
    }
}

enum IssueCategory: String, Codable, Hashable, CaseIterable, Identifiable {
    case roads
    case water
    case electricity
    case health
    case education
    case environment
    case publicSafety = "public_safety"
    case governance

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .roads: return "Roads"
        case .water: return "Water"
        case .electricity: return "Electricity"
        case .health: return "Health"
        case .education: return "Education"
        case .environment: return "Environment"
        case .publicSafety: return "Public Safety"
        case .governance: return "Governance"
        }
    }

    var systemImage: String {
        switch self {
        case .roads: return "road.lanes"
        case .water: return "drop"
        case .electricity: return "bolt"
        case .health: return "cross.case"
        case .education: return "book"
        case .environment: return "leaf"
        case .publicSafety: return "shield"
        case .governance: return "building.columns"
        }
    }
}

enum IssueStatus: String, Codable, Hashable {
    case draft
    case submitted
    case underReview = "under_review"
    case published
    case active
    case resolved
    case archived
    case rejected
    case merged

    var displayName: String {
        switch self {
        case .draft: return "Draft"
        case .submitted: return "Submitted"
        case .underReview: return "Under Review"
        case .published: return "Published"
        case .active: return "Active"
        case .resolved: return "Resolved"
        case .archived: return "Archived"
        case .rejected: return "Rejected"
        case .merged: return "Merged"
        }
    }
}
