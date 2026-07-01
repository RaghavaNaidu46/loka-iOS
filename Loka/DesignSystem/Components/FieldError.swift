import SwiftUI

/// An inline validation message shown directly beneath a form field.
///
/// Renders nothing when `message` is nil. Place it under any input (text editor,
/// picker, etc.); it carries its own move+fade transition, so the enclosing form
/// only needs to animate on the message value (e.g. `.animation(_, value: error)`).
struct FieldError: View {
    let message: String?

    var body: some View {
        if let message {
            Label(message, systemImage: "exclamationmark.circle.fill")
                .font(LokaFont.caption)
                .foregroundStyle(LokaColor.danger)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, LokaSpacing.xs)
                .transition(.opacity.combined(with: .move(edge: .top)))
        }
    }
}
