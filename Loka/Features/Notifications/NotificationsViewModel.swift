import Foundation

@MainActor
final class NotificationsViewModel: ObservableObject {
    @Published var notifications: [LokaNotification] = []
    @Published var isLoading = false

    private let repository: NotificationRepository

    init(repository: NotificationRepository = HTTPNotificationRepository()) {
        self.repository = repository
    }

    func load() async {
        isLoading = true
        notifications = (try? await repository.list()) ?? []
        isLoading = false
    }

    func markRead(_ id: String) async {
        try? await repository.markRead(id: id)
        if let idx = notifications.firstIndex(where: { $0.id == id }) {
            notifications[idx].isRead = true
        }
    }
}
