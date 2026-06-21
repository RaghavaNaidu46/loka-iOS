import SwiftUI

struct NotificationsView: View {
    @EnvironmentObject private var router: AppRouter
    @StateObject private var viewModel = NotificationsViewModel()

    var body: some View {
        NavigationStack(path: $router.notificationsPath) {
            Group {
                if viewModel.isLoading && viewModel.notifications.isEmpty {
                    ProgressView()
                } else if viewModel.notifications.isEmpty {
                    EmptyStateView(
                        systemImage: "bell",
                        title: "No notifications",
                        message: "Updates about your issues and participation will appear here."
                    )
                } else {
                    List {
                        ForEach(viewModel.notifications) { notification in
                            row(notification)
                                .onTapGesture {
                                    Task { await viewModel.markRead(notification.id) }
                                    if let ref = notification.referenceId {
                                        router.notificationsPath.append(IssueRoute.detail(id: ref))
                                    }
                                }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .background(LokaColor.background)
            .navigationTitle("Notifications")
            .navigationDestination(for: IssueRoute.self) { route in
                switch route {
                case .detail(let id): IssueDetailView(issueId: id)
                }
            }
            .task { await viewModel.load() }
            .refreshable { await viewModel.load() }
        }
    }

    private func row(_ notification: LokaNotification) -> some View {
        HStack(alignment: .top, spacing: LokaSpacing.md) {
            Circle()
                .fill(notification.isRead ? Color.clear : LokaColor.accent)
                .frame(width: 8, height: 8)
                .padding(.top, 6)
            VStack(alignment: .leading, spacing: LokaSpacing.xs) {
                Text(notification.title)
                    .font(LokaFont.bodyEmphasized)
                Text(notification.body)
                    .font(LokaFont.body)
                    .foregroundStyle(LokaColor.textSecondary)
                Text(notification.createdAt, style: .relative)
                    .font(LokaFont.caption)
                    .foregroundStyle(LokaColor.textTertiary)
            }
        }
        .padding(.vertical, LokaSpacing.xs)
    }
}
