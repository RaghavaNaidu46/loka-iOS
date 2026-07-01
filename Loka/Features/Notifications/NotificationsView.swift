import SwiftUI

struct NotificationsView: View {
    @EnvironmentObject private var router: AppRouter
    @StateObject private var viewModel = NotificationsViewModel()

    var body: some View {
        NavigationStack(path: $router.notificationsPath) {
            Group {
                if viewModel.isLoading && viewModel.notifications.isEmpty {
                    loadingState
                } else if viewModel.notifications.isEmpty {
                    EmptyStateView(
                        systemImage: "bell.fill",
                        title: "You're all caught up",
                        message: "Updates about your issues and participation will appear here."
                    )
                } else {
                    list
                }
            }
            .background(LokaColor.base)
            .navigationTitle("Notifications")
            .navigationDestination(for: IssueRoute.self) { route in
                switch route {
                case .detail(let id): IssueDetailView(issueId: id)
                }
            }
            .task { await viewModel.load() }
        }
    }

    private var list: some View {
        ScrollView {
            LazyVStack(spacing: LokaSpacing.sm) {
                ForEach(viewModel.notifications) { notification in
                    Button {
                        Haptics.selection()
                        Task { await viewModel.markRead(notification.id) }
                        if let ref = notification.referenceId {
                            router.notificationsPath.append(IssueRoute.detail(id: ref))
                        }
                    } label: {
                        row(notification)
                    }
                    .buttonStyle(PressableButtonStyle())
                }
            }
            .padding(.horizontal, LokaSpacing.lg)
            .padding(.top, LokaSpacing.sm)
            .padding(.bottom, LokaSize.tabBarClearance)
        }
        .scrollIndicators(.hidden)
        .refreshable { await viewModel.load() }
    }

    private func row(_ notification: LokaNotification) -> some View {
        HStack(alignment: .top, spacing: LokaSpacing.md) {
            ZStack {
                Circle()
                    .fill(tint(notification.kind).opacity(0.14))
                    .frame(width: 44, height: 44)
                Image(systemName: icon(notification.kind))
                    .font(.system(size: LokaSize.iconMedium, weight: .semibold))
                    .foregroundStyle(tint(notification.kind))
            }

            VStack(alignment: .leading, spacing: LokaSpacing.xs) {
                Text(notification.title)
                    .font(LokaFont.calloutEmphasized)
                    .foregroundStyle(LokaColor.textPrimary)
                    .multilineTextAlignment(.leading)
                Text(notification.body)
                    .font(LokaFont.callout)
                    .foregroundStyle(LokaColor.textSecondary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                Text(notification.createdAt.relativeString())
                    .font(LokaFont.caption)
                    .foregroundStyle(LokaColor.textTertiary)
            }
            Spacer(minLength: 0)

            if !notification.isRead {
                Circle().fill(LokaColor.brand).frame(width: 9, height: 9).padding(.top, 4)
            }
        }
        .padding(LokaSpacing.md)
        .background(
            notification.isRead ? LokaColor.surface : LokaColor.brandSoft,
            in: RoundedRectangle(cornerRadius: LokaCorner.lg, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: LokaCorner.lg, style: .continuous)
                .strokeBorder(LokaColor.border, lineWidth: 0.5)
        )
    }

    private var loadingState: some View {
        ScrollView {
            VStack(spacing: LokaSpacing.sm) {
                ForEach(0..<6, id: \.self) { _ in
                    SkeletonBlock(cornerRadius: LokaCorner.lg).frame(height: 84)
                }
            }
            .padding(.horizontal, LokaSpacing.lg)
            .padding(.top, LokaSpacing.sm)
        }
    }

    // MARK: - Kind styling

    private func icon(_ kind: NotificationKind) -> String {
        switch kind {
        case .issueApproved: return "checkmark.seal.fill"
        case .issueRejected: return "xmark.seal.fill"
        case .clarificationRequested: return "questionmark.bubble.fill"
        case .participationReceived: return "hand.thumbsup.fill"
        case .appealUpdate: return "arrow.uturn.up.circle.fill"
        case .resolutionUpdate: return "flag.checkered"
        }
    }

    private func tint(_ kind: NotificationKind) -> Color {
        switch kind {
        case .issueApproved, .resolutionUpdate: return LokaColor.support
        case .issueRejected: return LokaColor.danger
        case .clarificationRequested, .appealUpdate: return LokaColor.oppose
        case .participationReceived: return LokaColor.brand
        }
    }
}

#Preview {
    NotificationsView().environmentObject(AppRouter())
}
