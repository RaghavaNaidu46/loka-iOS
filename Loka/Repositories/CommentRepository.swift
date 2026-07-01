import Foundation

protocol CommentRepository {
    func list(issueId: String) async throws -> [LokaComment]
    func add(issueId: String, text: String) async throws -> LokaComment
}

final class HTTPCommentRepository: CommentRepository {
    private let client: any APIClient

    init(client: any APIClient = ServiceLocator.shared.client) {
        self.client = client
    }

    func list(issueId: String) async throws -> [LokaComment] {
        let response = try await client.send(
            Endpoints.comments(issueId: issueId),
            decode: CommentListResponseDTO.self
        )
        return response.items.map { $0.toModel() }
    }

    func add(issueId: String, text: String) async throws -> LokaComment {
        let dto = try await client.send(
            Endpoints.addComment(issueId: issueId, text: text),
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
