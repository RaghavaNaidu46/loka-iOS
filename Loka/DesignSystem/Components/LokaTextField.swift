import SwiftUI

/// A styled input field with an optional leading icon and a focus ring.
/// Supports plain text and secure entry.
struct LokaTextField: View {
    let placeholder: String
    @Binding var text: String
    var systemImage: String?
    var isSecure: Bool = false
    var keyboard: UIKeyboardType = .default
    var textContentType: UITextContentType?
    var autocapitalization: TextInputAutocapitalization = .never
    var submitLabel: SubmitLabel = .done
    var onSubmit: (() -> Void)?

    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: LokaSpacing.sm) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.system(size: LokaSize.iconMedium))
                    .foregroundStyle(isFocused ? LokaColor.brand : LokaColor.textTertiary)
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
        .padding(.horizontal, LokaSpacing.md)
        .frame(height: LokaSize.controlHeight)
        .background(LokaColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: LokaCorner.md, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: LokaCorner.md, style: .continuous)
                .strokeBorder(isFocused ? LokaColor.brand : LokaColor.border, lineWidth: isFocused ? 1.5 : 1)
        )
        .animation(LokaAnimation.snappy, value: isFocused)
    }
}
