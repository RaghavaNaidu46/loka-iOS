import Foundation

struct LokaComment: Identifiable, Codable, Hashable {
    let id: String
    let citizenId: String
    let citizenDisplayName: String
    let issueId: String
    let text: String
    let createdAt: Date
}
