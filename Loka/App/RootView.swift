import SwiftUI

struct RootView: View {
    @EnvironmentObject private var session: AppSessionManager
    @State private var showSplash = true

    var body: some View {
        ZStack {
            LokaColor.base.ignoresSafeArea()

            // The destination is always mounted; the splash sits on top and
            // dissolves away, so there's no hard cut from blue to white.
            destination
                .transition(.opacity)

            if showSplash {
                SplashView()
                    .transition(.splashExit)
                    .zIndex(1)
            }
        }
        // Animate the top-level route changes: splash dissolve, and the
        // sign-in → dashboard and sign-out → auth transitions (authState).
        .animation(LokaAnimation.smooth, value: showSplash)
        .animation(LokaAnimation.smooth, value: session.authState)
        .task {
            try? await Task.sleep(nanoseconds: 700_000_000)
            await session.bootstrap()
            showSplash = false
        }
    }

    @ViewBuilder private var destination: some View {
        switch session.authState {
        case .anonymous:
            NavigationStack {
                AuthView(onComplete: {
                    Task { await session.bootstrap() }
                })
            }
        case .authenticated:
            MainTabView()
        }
    }
}

#Preview {
    RootView()
        .environmentObject(AppSessionManager())
        .environmentObject(AppRouter())
}
