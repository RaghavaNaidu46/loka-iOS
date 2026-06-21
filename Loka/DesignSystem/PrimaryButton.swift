import SwiftUI

struct PrimaryButton: View {
    let title: String
    var isLoading: Bool = false
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                if isLoading { ProgressView().tint(.white) }
                Text(title)
                    .font(LokaFont.bodyEmphasized)
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity, minHeight: 48)
            .background(LokaColor.accent)
            .clipShape(RoundedRectangle(cornerRadius: LokaCorner.md))
        }
        .disabled(isLoading)
    }
}

struct SecondaryButton: View {
    let title: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(LokaFont.bodyEmphasized)
                .foregroundStyle(LokaColor.accent)
                .frame(maxWidth: .infinity, minHeight: 48)
                .background(LokaColor.surface)
                .clipShape(RoundedRectangle(cornerRadius: LokaCorner.md))
                .overlay(
                    RoundedRectangle(cornerRadius: LokaCorner.md)
                        .strokeBorder(LokaColor.accent.opacity(0.4), lineWidth: 1)
                )
        }
    }
}

struct DestructiveWarningButton: View {
    let title: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(LokaFont.bodyEmphasized)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, minHeight: 48)
                .background(LokaColor.danger)
                .clipShape(RoundedRectangle(cornerRadius: LokaCorner.md))
        }
    }
}
