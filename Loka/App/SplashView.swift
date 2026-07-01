import SwiftUI

/// Animated launch screen: the brand mark scales/fades in over the gradient.
struct SplashView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appeared = false

    var body: some View {
        ZStack {
            LokaColor.brandGradient
                .ignoresSafeArea()

            VStack(spacing: LokaSpacing.lg) {
                BrandMark(size: 96)
                    .scaleEffect(appeared || reduceMotion ? 1 : 0.6)
                    .opacity(appeared || reduceMotion ? 1 : 0)

                VStack(spacing: LokaSpacing.xs) {
                    Text("Loka")
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text("One Citizen. One Voice.")
                        .font(LokaFont.callout)
                        .foregroundStyle(.white.opacity(0.85))
                }
                .opacity(appeared || reduceMotion ? 1 : 0)
                .offset(y: appeared || reduceMotion ? 0 : 12)
            }
        }
        .onAppear {
            withAnimation(LokaAnimation.bouncy) { appeared = true }
        }
    }
}

/// The Loka logo mark: a stylized location pin inside a rounded tile.
struct BrandMark: View {
    var size: CGFloat = 64
    var onGradient: Bool = true

    var body: some View {
        RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
            .fill(onGradient ? AnyShapeStyle(.white.opacity(0.16)) : AnyShapeStyle(LokaColor.brandGradient))
            .frame(width: size, height: size)
            .overlay(
                Image(systemName: "mappin.and.ellipse")
                    .font(.system(size: size * 0.5, weight: .bold))
                    .foregroundStyle(.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
                    .strokeBorder(.white.opacity(onGradient ? 0.25 : 0), lineWidth: 1)
            )
    }
}

#Preview {
    SplashView()
}
