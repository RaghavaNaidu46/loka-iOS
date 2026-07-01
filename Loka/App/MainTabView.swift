import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        ZStack(alignment: .bottom) {
            LokaColor.base.ignoresSafeArea()

            // A real TabView so tabs load lazily and only the visible tab renders
            // its list — essential once the feed holds large amounts of data.
            // The native bar is hidden; the floating CustomTabBar drives selection.
            TabView(selection: $router.selectedTab) {
                FeedView().tag(AppTab.home).hideSystemTabBar()
                SearchView().tag(AppTab.search).hideSystemTabBar()
                CreateIssueView().tag(AppTab.create).hideSystemTabBar()
                NotificationsView().tag(AppTab.notifications).hideSystemTabBar()
                ProfileView().tag(AppTab.profile).hideSystemTabBar()
            }

            if !isNavigating {
                CustomTabBar(selection: $router.selectedTab)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .ignoresSafeArea(.keyboard)
        .animation(LokaAnimation.snappy, value: isNavigating)
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

private extension View {
    /// Hides the system `TabView` bar so only the custom floating bar shows.
    func hideSystemTabBar() -> some View {
        toolbar(.hidden, for: .tabBar)
    }
}

#Preview {
    MainTabView()
        .environmentObject(AppSessionManager())
        .environmentObject(AppRouter())
}
