import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        TabView(selection: $router.selectedTab) {
            FeedView()
                .tabItem { Label("Home", systemImage: "house") }
                .tag(AppTab.home)

            SearchView()
                .tabItem { Label("Search", systemImage: "magnifyingglass") }
                .tag(AppTab.search)

            CreateIssueView()
                .tabItem { Label("Create", systemImage: "plus.circle") }
                .tag(AppTab.create)

            NotificationsView()
                .tabItem { Label("Notifications", systemImage: "bell") }
                .tag(AppTab.notifications)

            ProfileView()
                .tabItem { Label("Profile", systemImage: "person") }
                .tag(AppTab.profile)
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AppSessionManager())
        .environmentObject(AppRouter())
}
