import SwiftUI

struct RootView: View {
    @EnvironmentObject private var session: AppSessionManager
    @State private var showSplash = true

    var body: some View {
        ZStack {
            if showSplash {
                SplashView()
                    .transition(.opacity)
            } else {
                switch session.authState {
                case .anonymous:
                    NavigationStack {
                        AuthView(onComplete: {
                            Task {
                                await session.bootstrap()
                            }
                        })
                    }
                    .transition(.opacity)
                case .authenticated:
                    MainTabView()
                        .transition(.opacity)
                }
            }
        }
        .task {
            try? await Task.sleep(nanoseconds: 900_000_000)
            await session.bootstrap()
            withAnimation(.easeOut(duration: 0.25)) {
                showSplash = false
            }
        }
    }
}

#Preview {
    RootView()
        .environmentObject(AppSessionManager())
        .environmentObject(AppRouter())
}
