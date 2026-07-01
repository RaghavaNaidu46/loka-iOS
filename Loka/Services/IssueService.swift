import Foundation

protocol IssueService {
    func submit(_ draft: IssueDraft) async throws -> Issue
    func detectDuplicates(title: String, districtId: String) async throws -> [Issue]
}

struct IssueDraft {
    var title: String
    var description: String
    var desiredOutcome: String
    var category: IssueCategory
    var district: District?
    var area: String
    var city: String
}

final class HTTPIssueService: IssueService {
    private let client: any APIClient

    init(client: any APIClient = ServiceLocator.shared.client) {
        self.client = client
    }

    func submit(_ draft: IssueDraft) async throws -> Issue {
        guard let district = draft.district else {
            throw APIError.server(400, "Please select a district")
        }
        let created = try await client.send(
            Endpoints.createIssue(
                title: draft.title,
                description: draft.description,
                desiredOutcome: draft.desiredOutcome,
                category: draft.category,
                area: draft.area.isEmpty ? nil : draft.area,
                city: draft.city,
                districtId: district.id
            ),
            decode: IssueDTO.self
        )
        try await client.send(Endpoints.submitIssue(id: created.id))
        let detail = try await client.send(Endpoints.issueDetail(id: created.id), decode: IssueDTO.self)
        return detail.toModel()
    }

    func detectDuplicates(title: String, districtId: String) async throws -> [Issue] {
        let response = try await client.send(
            Endpoints.searchIssues(query: title, districtId: districtId, category: nil),
            decode: IssueListResponseDTO.self
        )
        return response.items.map { $0.toModel() }
    }
}

final class MockIssueService: IssueService {
    private let repository: IssueRepository

    init(repository: IssueRepository = MockIssueRepository()) {
        self.repository = repository
    }

    func submit(_ draft: IssueDraft) async throws -> Issue {
        try await Task.sleep(nanoseconds: 400_000_000)
        guard let district = draft.district else {
            throw APIError.status(400)
        }
        return Issue(
            id: UUID().uuidString,
            title: draft.title,
            description: draft.description,
            desiredOutcome: draft.desiredOutcome,
            category: draft.category,
            location: IssueLocation(area: draft.area, city: draft.city, district: district),
            status: .submitted,
            supportCount: 0,
            opposeCount: 0,
            evidenceCount: 0,
            createdAt: Date(),
            updatedAt: Date(),
            creatorDisplayName: MockData.currentCitizen.displayName
        )
    }

    func detectDuplicates(title: String, districtId: String) async throws -> [Issue] {
        let results = try await repository.search(query: title, district: nil, category: nil)
        return results.filter { $0.location.district.id == districtId }
    }
}
