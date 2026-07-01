import SwiftUI

struct RootView: View {
    @EnvironmentObject private var session: AppSessionManager
    @State private var showSplash = true

    var body: some View {
        ZStack {
            LokaColor.base.ignoresSafeArea()

            if showSplash {
                SplashView()
                    .transition(.opacity)
            } else {
                switch session.authState {
                case .anonymous:
                    NavigationStack {
                        AuthView(onComplete: {
                            Task { await session.bootstrap() }
                        })
                    }
                    .transition(.opacity.combined(with: .scale(scale: 1.02)))
                case .authenticated:
                    MainTabView()
                        .transition(.opacity.combined(with: .scale(scale: 0.98)))
                }
            }
        }
        .task {
            try? await Task.sleep(nanoseconds: 1_100_000_000)
            await session.bootstrap()
            withAnimation(LokaAnimation.smooth) { showSplash = false }
        }
    }
}

#Preview {
    RootView()
        .environmentObject(AppSessionManager())
        .environmentObject(AppRouter())
}
