import Foundation

protocol ParticipationRepository {
    func support(issueId: String) async throws -> ParticipationRecord
    func oppose(issueId: String, explanation: String) async throws -> ParticipationRecord
    func status(forIssue id: String) async throws -> ParticipationRecord?
}

final class HTTPParticipationRepository: ParticipationRepository {
    private let client: APIClient

    init(client: APIClient = ServiceLocator.shared.client) {
        self.client = client
    }

    func support(issueId: String) async throws -> ParticipationRecord {
        struct Body: Encodable { let confirmed: Bool }
        try await client.send(.post, "issues/\(issueId)/support", body: Body(confirmed: true))
        return ParticipationRecord(
            id: UUID().uuidString,
            citizenId: "",
            issueId: issueId,
            type: .support,
            opposeExplanation: nil,
            createdAt: Date()
        )
    }

    func oppose(issueId: String, explanation: String) async throws -> ParticipationRecord {
        struct Body: Encodable { let explanation: String; let confirmed: Bool }
        try await client.send(.post, "issues/\(issueId)/oppose", body: Body(explanation: explanation, confirmed: true))
        return ParticipationRecord(
            id: UUID().uuidString,
            citizenId: "",
            issueId: issueId,
            type: .oppose,
            opposeExplanation: explanation,
            createdAt: Date()
        )
    }

    func status(forIssue id: String) async throws -> ParticipationRecord? {
        do {
            let dto = try await client.send(
                .get, "issues/\(id)/participation/status",
                decode: ParticipationStatusDTO.self
            )
            guard dto.hasParticipated else { return nil }
            let type = ParticipationType(rawValue: dto.participationType ?? "support") ?? .support
            return ParticipationRecord(
                id: UUID().uuidString,
                citizenId: "",
                issueId: id,
                type: type,
                opposeExplanation: nil,
                createdAt: Date()
            )
        } catch APIError.unauthorized {
            // Visitors / unverified citizens can view but not participate.
            return nil
        } catch let APIError.server(code, _) where code == 401 || code == 403 || code == 404 {
            return nil
        }
    }
}

final class MockParticipationRepository: ParticipationRepository {
    private var records: [String: ParticipationRecord] = [:]

    func support(issueId: String) async throws -> ParticipationRecord {
        try await Task.sleep(nanoseconds: 200_000_000)
        let record = ParticipationRecord(
            id: UUID().uuidString,
            citizenId: MockData.currentCitizen.id,
            issueId: issueId,
            type: .support,
            opposeExplanation: nil,
            createdAt: Date()
        )
        records[issueId] = record
        return record
    }

    func oppose(issueId: String, explanation: String) async throws -> ParticipationRecord {
        try await Task.sleep(nanoseconds: 200_000_000)
        let record = ParticipationRecord(
            id: UUID().uuidString,
            citizenId: MockData.currentCitizen.id,
            issueId: issueId,
            type: .oppose,
            opposeExplanation: explanation,
            createdAt: Date()
        )
        records[issueId] = record
        return record
    }

    func status(forIssue id: String) async throws -> ParticipationRecord? {
        records[id]
    }
}
