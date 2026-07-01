import SwiftUI

/// Shared motion presets so animation feels consistent app-wide.
enum LokaAnimation {
    /// Snappy spring for taps, selection, and small state changes.
    static let snappy = Animation.spring(response: 0.32, dampingFraction: 0.72)
    /// Bouncier spring for playful, attention-drawing transitions.
    static let bouncy = Animation.spring(response: 0.45, dampingFraction: 0.66)
    /// Gentle spring for layout / content changes.
    static let smooth = Animation.spring(response: 0.5, dampingFraction: 0.86)
    /// Simple opacity cross-fades.
    static let fade = Animation.easeInOut(duration: 0.25)
}

extension AnyTransition {
    /// Splash → app: the splash gently scales up and fades, dissolving away to
    /// reveal the destination underneath (no hard blue→white cut).
    static var splashExit: AnyTransition {
        .asymmetric(
            insertion: .opacity,
            removal: .scale(scale: 1.12).combined(with: .opacity)
        )
    }
}
