import Foundation

protocol NotificationRepository {
    func list() async throws -> [LokaNotification]
    func markRead(id: String) async throws
}

final class HTTPNotificationRepository: NotificationRepository {
    private let client: any APIClient

    init(client: any APIClient = ServiceLocator.shared.client) {
        self.client = client
    }

    func list() async throws -> [LokaNotification] {
        let response = try await client.send(Endpoints.notifications(), decode: NotificationListResponseDTO.self)
        return response.items
    }

    func markRead(id: String) async throws {
        try await client.send(Endpoints.markNotificationRead(id: id))
    }
}

final class MockNotificationRepository: NotificationRepository {
    private var notifications: [LokaNotification] = MockData.notifications

    func list() async throws -> [LokaNotification] {
        try await Task.sleep(nanoseconds: 150_000_000)
        return notifications.sorted { $0.createdAt > $1.createdAt }
    }

    func markRead(id: String) async throws {
        if let idx = notifications.firstIndex(where: { $0.id == id }) {
            notifications[idx].isRead = true
        }
    }
}
