import SwiftUI

/// The canonical Loka button. Prefer this over ad-hoc styled buttons so CTAs
/// look and behave consistently (press animation + haptic + loading state).
struct LokaButton: View {
    enum Style {
        case primary   // brand gradient, high emphasis
        case secondary // tinted fill, medium emphasis
        case ghost     // borderless, low emphasis
        case destructive
    }

    let title: String
    var systemImage: String?
    var style: Style = .primary
    var isLoading: Bool = false
    var fullWidth: Bool = true
    var action: () -> Void

    var body: some View {
        Button {
            Haptics.impact(.light)
            action()
        } label: {
            HStack(spacing: LokaSpacing.sm) {
                if isLoading {
                    ProgressView()
                        .controlSize(.small)
                        .tint(foreground)
                } else if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: LokaSize.iconMedium, weight: .semibold))
                }
                Text(title)
                    .font(LokaFont.calloutEmphasized)
            }
            .foregroundStyle(foreground)
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .frame(height: LokaSize.controlHeight)
            .padding(.horizontal, fullWidth ? 0 : LokaSpacing.xl)
            .background(background)
            .overlay(border)
            .clipShape(RoundedRectangle(cornerRadius: LokaCorner.md, style: .continuous))
        }
        .buttonStyle(PressableButtonStyle())
        .disabled(isLoading)
        .opacity(isLoading ? 0.85 : 1)
    }

    // MARK: - Styling

    private var foreground: Color {
        switch style {
        case .primary, .destructive: return LokaColor.onBrand
        case .secondary, .ghost: return LokaColor.brand
        }
    }

    @ViewBuilder private var background: some View {
        switch style {
        case .primary: LokaColor.brandGradient
        case .destructive: LokaColor.danger
        case .secondary: LokaColor.brandSoft
        case .ghost: Color.clear
        }
    }

    @ViewBuilder private var border: some View {
        if style == .ghost {
            RoundedRectangle(cornerRadius: LokaCorner.md, style: .continuous)
                .strokeBorder(LokaColor.border, lineWidth: 1)
        }
    }
}

// MARK: - Backward-compatible aliases

/// Retained so any legacy call sites keep compiling; new code should use `LokaButton`.
struct PrimaryButton: View {
    let title: String
    var isLoading: Bool = false
    var action: () -> Void
    var body: some View {
        LokaButton(title: title, style: .primary, isLoading: isLoading, action: action)
    }
}

struct SecondaryButton: View {
    let title: String
    var action: () -> Void
    var body: some View {
        LokaButton(title: title, style: .secondary, action: action)
    }
}

#Preview {
    VStack(spacing: LokaSpacing.md) {
        LokaButton(title: "Support", systemImage: "hand.thumbsup.fill", style: .primary) {}
        LokaButton(title: "Oppose with explanation", style: .secondary) {}
        LokaButton(title: "Learn more", style: .ghost) {}
        LokaButton(title: "Delete", style: .destructive) {}
        LokaButton(title: "Loading", isLoading: true) {}
    }
    .padding()
    .background(LokaColor.base)
}
