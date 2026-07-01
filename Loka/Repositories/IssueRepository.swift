import Foundation

protocol IssueRepository {
    func feedNearby() async throws -> [Issue]
    func feedNew() async throws -> [Issue]
    func feedCommunityPriority() async throws -> [Issue]
    func feedResolved() async throws -> [Issue]
    func detail(id: String) async throws -> Issue
    func relatedIssues(to id: String) async throws -> [Issue]
    func search(query: String, district: District?, category: IssueCategory?) async throws -> [Issue]
}

final class HTTPIssueRepository: IssueRepository {
    private let client: any APIClient

    init(client: any APIClient = ServiceLocator.shared.client) {
        self.client = client
    }

    func feedNearby() async throws -> [Issue] {
        try await fetchFeed(Endpoints.feedNearby())
    }

    func feedNew() async throws -> [Issue] {
        try await fetchFeed(Endpoints.feedNew())
    }

    func feedCommunityPriority() async throws -> [Issue] {
        try await fetchFeed(Endpoints.feedPriority())
    }

    func feedResolved() async throws -> [Issue] {
        try await fetchFeed(Endpoints.feedResolved())
    }

    func detail(id: String) async throws -> Issue {
        let dto = try await client.send(Endpoints.issueDetail(id: id), decode: IssueDTO.self)
        return dto.toModel()
    }

    func relatedIssues(to id: String) async throws -> [Issue] {
        let response = try await client.send(Endpoints.relatedIssues(id: id), decode: IssueListResponseDTO.self)
        return response.items.map { $0.toModel() }
    }

    func search(query: String, district: District?, category: IssueCategory?) async throws -> [Issue] {
        let response = try await client.send(
            Endpoints.searchIssues(query: query, districtId: district?.id, category: category?.rawValue),
            decode: IssueListResponseDTO.self
        )
        return response.items.map { $0.toModel() }
    }

    private func fetchFeed(_ request: APIRequest) async throws -> [Issue] {
        let response = try await client.send(request, decode: IssueListResponseDTO.self)
        return response.items.map { $0.toModel() }
    }
}

final class MockIssueRepository: IssueRepository {
    private let issues: [Issue] = MockData.issues

    func feedNearby() async throws -> [Issue] {
        try await delay()
        return Array(issues.prefix(4))
    }

    func feedNew() async throws -> [Issue] {
        try await delay()
        return issues.sorted { $0.createdAt > $1.createdAt }
    }

    func feedCommunityPriority() async throws -> [Issue] {
        try await delay()
        return issues.sorted { $0.participationTotal > $1.participationTotal }
    }

    func feedResolved() async throws -> [Issue] {
        try await delay()
        return issues.filter { $0.status == .resolved }
    }

    func detail(id: String) async throws -> Issue {
        try await delay()
        guard let issue = issues.first(where: { $0.id == id }) else {
            throw APIError.status(404)
        }
        return issue
    }

    func relatedIssues(to id: String) async throws -> [Issue] {
        try await delay()
        guard let source = try? await detail(id: id) else { return [] }
        return issues.filter { $0.id != id && $0.category == source.category }.prefix(3).map { $0 }
    }

    func search(query: String, district: District?, category: IssueCategory?) async throws -> [Issue] {
        try await delay()
        return issues.filter { issue in
            let matchesQuery = query.isEmpty || issue.title.localizedCaseInsensitiveContains(query) || issue.description.localizedCaseInsensitiveContains(query)
            let matchesDistrict = district == nil || issue.location.district.id == district?.id
            let matchesCategory = category == nil || issue.category == category
            return matchesQuery && matchesDistrict && matchesCategory
        }
    }

    private func delay() async throws {
        try await Task.sleep(nanoseconds: 200_000_000)
    }
}
