import Foundation

// MARK: - Auth

struct TokenResponseDTO: Decodable {
    let accessToken: String
    let refreshToken: String
    let tokenType: String?
}

struct MessageResponseDTO: Decodable {
    let message: String
}

// MARK: - District

struct DistrictDTO: Decodable {
    let id: String
    let name: String
    let state: String
    let country: String?

    func toModel() -> District {
        District(id: id, name: name, state: state, country: country ?? "India")
    }
}

struct DistrictListResponseDTO: Decodable {
    let items: [DistrictDTO]
}

// MARK: - Issue

struct IssueDTO: Decodable {
    let id: String
    let title: String
    let description: String
    let desiredOutcome: String
    let category: IssueCategory
    let area: String?
    let city: String
    let district: DistrictDTO?
    let status: IssueStatus
    let supportCount: Int
    let opposeCount: Int
    let evidenceCount: Int
    let creatorDisplayName: String?
    let createdAt: Date
    let updatedAt: Date

    func toModel() -> Issue {
        let resolvedDistrict = district?.toModel()
            ?? District(id: "", name: "Unknown district", state: "", country: "India")
        return Issue(
            id: id,
            title: title,
            description: description,
            desiredOutcome: desiredOutcome,
            category: category,
            location: IssueLocation(area: area, city: city, district: resolvedDistrict),
            status: status,
            supportCount: supportCount,
            opposeCount: opposeCount,
            evidenceCount: evidenceCount,
            createdAt: createdAt,
            updatedAt: updatedAt,
            creatorDisplayName: creatorDisplayName ?? "Anonymous"
        )
    }
}

struct IssueListResponseDTO: Decodable {
    let items: [IssueDTO]
}

// MARK: - Comment

struct CommentDTO: Decodable {
    let id: String
    let citizenId: String?
    let citizenDisplayName: String?
    let issueId: String
    let text: String
    let createdAt: Date

    func toModel() -> LokaComment {
        LokaComment(
            id: id,
            citizenId: citizenId ?? "",
            citizenDisplayName: citizenDisplayName ?? "Citizen",
            issueId: issueId,
            text: text,
            createdAt: createdAt
        )
    }
}

struct CommentListResponseDTO: Decodable {
    let items: [CommentDTO]
    let total: Int
}

// MARK: - Notification

struct NotificationListResponseDTO: Decodable {
    let items: [LokaNotification]
    let unreadCount: Int
}

// MARK: - Citizen / Profile

struct CitizenMeDTO: Decodable {
    let id: String
    let phoneNumber: String?
    let displayName: String?
    let verificationStatus: VerificationStatus
    let homeDistrict: DistrictDTO?
    let livingInDistrict: DistrictDTO?
    let createdAt: Date?
    let lastActiveAt: Date?

    func toModel() -> Citizen {
        let created = createdAt ?? Date()
        return Citizen(
            id: id,
            displayName: displayName ?? "",
            phoneNumber: phoneNumber,
            verificationStatus: verificationStatus,
            homeDistrict: homeDistrict?.toModel(),
            livingInDistrict: livingInDistrict?.toModel(),
            createdAt: created,
            lastActiveAt: lastActiveAt ?? created
        )
    }
}

// MARK: - Participation

struct ParticipationStatusDTO: Decodable {
    let issueId: String
    let hasParticipated: Bool
    let participationType: String?
}
