import SwiftUI

/// A shimmering placeholder shape used while content loads.
struct SkeletonBlock: View {
    var cornerRadius: CGFloat = LokaCorner.sm

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(LokaColor.surfaceElevated)
            .shimmer()
    }
}

/// A moving highlight sweep. Disabled under Reduce Motion.
struct ShimmerModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var phase: CGFloat = -1

    func body(content: Content) -> some View {
        if reduceMotion {
            content
        } else {
            content
                .overlay(
                    GeometryReader { geo in
                        LinearGradient(
                            colors: [.clear, LokaColor.onBrand.opacity(0.18), .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: geo.size.width * 1.5)
                        .offset(x: phase * geo.size.width * 1.5)
                    }
                    .mask(content)
                )
                .onAppear {
                    withAnimation(.linear(duration: 1.3).repeatForever(autoreverses: false)) {
                        phase = 1.2
                    }
                }
        }
    }
}

extension View {
    func shimmer() -> some View { modifier(ShimmerModifier()) }
}

/// Placeholder matching the shape of a feed card, shown during first load.
struct IssueCardSkeleton: View {
    var body: some View {
        LokaCard {
            VStack(alignment: .leading, spacing: LokaSpacing.md) {
                HStack(spacing: LokaSpacing.sm) {
                    Circle().fill(LokaColor.surfaceElevated).frame(width: LokaSize.avatarMedium, height: LokaSize.avatarMedium).shimmer()
                    VStack(alignment: .leading, spacing: LokaSpacing.xs) {
                        SkeletonBlock().frame(width: 120, height: 12)
                        SkeletonBlock().frame(width: 80, height: 10)
                    }
                    Spacer()
                }
                SkeletonBlock().frame(height: 18)
                SkeletonBlock().frame(width: 220, height: 18)
                SkeletonBlock(cornerRadius: LokaCorner.pill).frame(height: 8)
            }
        }
    }
}
