import Foundation

enum NotificationKind: String, Codable, Hashable {
    case issueApproved = "issue_approved"
    case issueRejected = "issue_rejected"
    case clarificationRequested = "clarification_requested"
    case participationReceived = "participation_received"
    case appealUpdate = "appeal_update"
    case resolutionUpdate = "resolution_update"
}

struct LokaNotification: Identifiable, Codable, Hashable {
    let id: String
    let kind: NotificationKind
    let title: String
    let body: String
    let referenceId: String?
    var isRead: Bool
    let createdAt: Date
}
