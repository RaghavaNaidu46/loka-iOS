import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            LokaColor.background.ignoresSafeArea()
            VStack(spacing: LokaSpacing.md) {
                Spacer()
                Text("Loka")
                    .font(LokaFont.displayLarge)
                    .foregroundStyle(LokaColor.textPrimary)
                Text("One Citizen. One Voice.")
                    .font(LokaFont.body)
                    .foregroundStyle(LokaColor.textSecondary)
                Spacer()
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(LokaColor.accent)
                    .padding(.bottom, LokaSpacing.xl)
            }
        }
    }
}

#Preview {
    SplashView()
}
