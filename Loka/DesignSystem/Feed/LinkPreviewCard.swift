import SwiftUI

/// A tappable unfurled-link card: thumbnail on top, title + host below.
struct LinkPreviewCard: View {
    let link: LinkPreview
    var interactive: Bool = true

    var body: some View {
        if interactive {
            Button {
                Haptics.tap()
                UIApplication.shared.open(link.url)
            } label: { card }
            .buttonStyle(PressableButtonStyle())
        } else {
            card
        }
    }

    private var card: some View {
        VStack(alignment: .leading, spacing: 0) {
                if let imageURL = link.imageURL {
                    Color.clear
                        .aspectRatio(1.9, contentMode: .fit)
                        .overlay { RemoteImage(url: imageURL, maxPixel: 1000) }
                        .clipped()
                }
                VStack(alignment: .leading, spacing: LokaSpacing.xs) {
                    Text(link.host.uppercased())
                        .font(LokaFont.statusLabel)
                        .foregroundStyle(LokaColor.textTertiary)
                    Text(link.title)
                        .font(LokaFont.calloutEmphasized)
                        .foregroundStyle(LokaColor.textPrimary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    HStack(spacing: LokaSpacing.xs) {
                        Image(systemName: "link").font(.system(size: 11))
                        Text(link.url.absoluteString).lineLimit(1)
                    }
                    .font(LokaFont.caption)
                    .foregroundStyle(LokaColor.textSecondary)
                }
                .padding(LokaSpacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(LokaColor.surfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: LokaCorner.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: LokaCorner.md, style: .continuous)
                    .strokeBorder(LokaColor.border, lineWidth: 0.5)
            )
    }
}
