import SwiftUI

/// Adds a spring scale-down and optional haptic while a view is pressed.
/// Respects Reduce Motion by dropping the scale effect.
struct PressableModifier: ViewModifier {
    var scale: CGFloat = 0.97
    var haptic: Bool = true

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isPressed = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(reduceMotion ? 1 : (isPressed ? scale : 1))
            .animation(LokaAnimation.snappy, value: isPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isPressed {
                            isPressed = true
                            if haptic { Haptics.tap() }
                        }
                    }
                    .onEnded { _ in isPressed = false }
            )
    }
}

extension View {
    /// Applies a pressable (scale + haptic) interaction. Use on custom tappable
    /// surfaces such as cards and chips.
    func pressable(scale: CGFloat = 0.97, haptic: Bool = true) -> some View {
        modifier(PressableModifier(scale: scale, haptic: haptic))
    }
}

/// A `ButtonStyle` that applies the same pressable feel to standard `Button`s.
struct PressableButtonStyle: ButtonStyle {
    var scale: CGFloat = 0.97
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(reduceMotion ? 1 : (configuration.isPressed ? scale : 1))
            .animation(LokaAnimation.snappy, value: configuration.isPressed)
    }
}
