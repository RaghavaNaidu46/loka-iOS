import SwiftUI

/// A styled input field with an optional leading icon, focus ring, and inline
/// validation error. Supports plain text and secure entry.
///
/// Pass `error` to show a message beneath the field and tint its border red;
/// set it back to `nil` to animate the message away. Show/hide is animated here,
/// so callers only need to drive the `error` value.
struct LokaTextField: View {
    let placeholder: String
    @Binding var text: String
    var systemImage: String?
    var isSecure: Bool = false
    var keyboard: UIKeyboardType = .default
    var textContentType: UITextContentType?
    var autocapitalization: TextInputAutocapitalization = .never
    var submitLabel: SubmitLabel = .done
    var error: String?
    var onSubmit: (() -> Void)?

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: LokaSpacing.xs) {
            fieldRow
                .padding(.horizontal, LokaSpacing.md)
                .frame(height: LokaSize.controlHeight)
                .background(LokaColor.surface)
                .clipShape(RoundedRectangle(cornerRadius: LokaCorner.md, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: LokaCorner.md, style: .continuous)
                        .strokeBorder(borderColor, lineWidth: borderWidth)
                )

            if let error {
                FieldError(message: error)
            }
        }
        .animation(LokaAnimation.snappy, value: isFocused)
        .animation(LokaAnimation.snappy, value: error)
    }

    private var fieldRow: some View {
        HStack(spacing: LokaSpacing.sm) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.system(size: LokaSize.iconMedium))
                    .foregroundStyle(iconColor)
                    .frame(width: 22)
            }
            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                }
            }
            .font(LokaFont.body)
            .foregroundStyle(LokaColor.textPrimary)
            .focused($isFocused)
            .keyboardType(keyboard)
            .textContentType(textContentType)
            .textInputAutocapitalization(autocapitalization)
            .autocorrectionDisabled(true)
            .submitLabel(submitLabel)
            .onSubmit { onSubmit?() }

            if !text.isEmpty && !isSecure {
                Button {
                    text = ""
                    Haptics.tap()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(LokaColor.textTertiary)
                }
            }
        }
    }

    private var iconColor: Color {
        if error != nil { return LokaColor.danger }
        return isFocused ? LokaColor.brand : LokaColor.textTertiary
    }

    private var borderColor: Color {
        if error != nil { return LokaColor.danger }
        return isFocused ? LokaColor.brand : LokaColor.border
    }

    private var borderWidth: CGFloat { (error != nil || isFocused) ? 1.5 : 1 }
}
