import SwiftUI

@main
struct LokaApp: App {
    @StateObject private var session = AppSessionManager()
    @StateObject private var router = AppRouter()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(session)
                .environmentObject(router)
                .tint(LokaColor.brand)
        }
    }
}
