import Foundation

struct Citizen: Identifiable, Codable, Hashable {
    let id: String
    var displayName: String
    var phoneNumber: String?
    var verificationStatus: VerificationStatus
    var homeDistrict: District?
    var livingInDistrict: District?
    var createdAt: Date
    var lastActiveAt: Date

    var isVerified: Bool { verificationStatus == .verified }
}

enum VerificationStatus: String, Codable, Hashable {
    case unverified
    case pending
    case verified
    case rejected
}
