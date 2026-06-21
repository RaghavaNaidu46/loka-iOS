import Foundation

protocol CommentRepository {
    func list(issueId: String) async throws -> [LokaComment]
    func add(issueId: String, text: String) async throws -> LokaComment
}

final class HTTPCommentRepository: CommentRepository {
    private let client: APIClient

    init(client: APIClient = ServiceLocator.shared.client) {
        self.client = client
    }

    func list(issueId: String) async throws -> [LokaComment] {
        let response = try await client.send(
            .get, "issues/\(issueId)/comments",
            decode: CommentListResponseDTO.self
        )
        return response.items.map { $0.toModel() }
    }

    func add(issueId: String, text: String) async throws -> LokaComment {
        struct Body: Encodable { let text: String }
        let dto = try await client.send(
            .post, "issues/\(issueId)/comments",
            body: Body(text: text),
            decode: CommentDTO.self
        )
        return dto.toModel()
    }
}

final class MockCommentRepository: CommentRepository {
    func list(issueId: String) async throws -> [LokaComment] {
        try await Task.sleep(nanoseconds: 150_000_000)
        return MockData.comments(forIssue: issueId)
    }

    func add(issueId: String, text: String) async throws -> LokaComment {
        try await Task.sleep(nanoseconds: 150_000_000)
        return LokaComment(
            id: UUID().uuidString,
            citizenId: MockData.currentCitizen.id,
            citizenDisplayName: MockData.currentCitizen.displayName,
            issueId: issueId,
            text: text,
            createdAt: Date()
        )
    }
}
