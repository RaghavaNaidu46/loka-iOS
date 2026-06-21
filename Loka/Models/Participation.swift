import Foundation

enum ParticipationType: String, Codable, Hashable {
    case support
    case oppose
}

struct ParticipationRecord: Identifiable, Codable, Hashable {
    let id: String
    let citizenId: String
    let issueId: String
    let type: ParticipationType
    let opposeExplanation: String?
    let createdAt: Date
}
