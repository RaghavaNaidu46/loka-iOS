import SwiftUI

enum AppTab: Hashable {
    case home
    case map
    case create
    case notifications
    case profile
}

@MainActor
final class AppRouter: ObservableObject {
    @Published var selectedTab: AppTab = .home
    @Published var feedPath = NavigationPath()
    @Published var mapPath = NavigationPath()
    @Published var searchPath = NavigationPath()   // used by the search sheet
    @Published var notificationsPath = NavigationPath()
    @Published var profilePath = NavigationPath()

    func openIssue(_ id: String, in tab: AppTab = .home) {
        switch tab {
        case .map:
            selectedTab = .map
            mapPath.append(IssueRoute.detail(id: id))
        case .profile:
            selectedTab = .profile
            profilePath.append(IssueRoute.detail(id: id))
        default:
            selectedTab = .home
            feedPath.append(IssueRoute.detail(id: id))
        }
    }
}

enum IssueRoute: Hashable {
    case detail(id: String)
}
