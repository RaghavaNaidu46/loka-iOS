import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        ZStack(alignment: .bottom) {
            LokaColor.base.ignoresSafeArea()

            // All screens stay alive so switching tabs preserves their state and
            // navigation stacks instead of rebuilding (which caused flicker).
            ZStack {
                screen(.home) { FeedView() }
                screen(.search) { SearchView() }
                screen(.create) { CreateIssueView() }
                screen(.notifications) { NotificationsView() }
                screen(.profile) { ProfileView() }
            }
            .animation(LokaAnimation.fade, value: router.selectedTab)

            if !isNavigating {
                CustomTabBar(selection: $router.selectedTab)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .ignoresSafeArea(.keyboard)
        .animation(LokaAnimation.snappy, value: isNavigating)
    }

    /// Renders a tab's screen, keeping it in the hierarchy but only visible and
    /// interactive when selected — a cross-fade handles the transition.
    @ViewBuilder
    private func screen<Content: View>(_ tab: AppTab, @ViewBuilder content: () -> Content) -> some View {
        let isActive = router.selectedTab == tab
        content()
            .opacity(isActive ? 1 : 0)
            .allowsHitTesting(isActive)
            .zIndex(isActive ? 1 : 0)
    }

    /// Hide the floating tab bar while a detail screen is pushed on the active tab.
    private var isNavigating: Bool {
        switch router.selectedTab {
        case .home:          return !router.feedPath.isEmpty
        case .search:        return !router.searchPath.isEmpty
        case .notifications: return !router.notificationsPath.isEmpty
        case .profile:       return !router.profilePath.isEmpty
        case .create:        return false
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AppSessionManager())
        .environmentObject(AppRouter())
}
