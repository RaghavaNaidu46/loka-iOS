import SwiftUI

/// Renders a post's attached media as a social-style gallery:
/// 1 = full-width (aspect-correct), 2 = split, 3 = one large + two, 4 = 2×2,
/// 5+ = 2×2 with a "+N" overlay. Videos show a poster with a play badge and
/// open a full-screen player on tap. Images load remotely with a skeleton.
struct PostMediaView: View {
    let media: [PostMedia]
    var cornerRadius: CGFloat = LokaCorner.md
    /// When false (in-feed), taps fall through so the card opens the detail;
    /// when true (detail), tapping a video poster plays it.
    var interactive: Bool = true

    @State private var playing: PostMedia?
    private let gap: CGFloat = 3

    var body: some View {
        Group {
            switch media.count {
            case 0: EmptyView()
            case 1: single(media[0])
            case 2: row(media)
            case 3: three(media)
            case 4: grid(media)
            default: grid(Array(media.prefix(4)), extra: media.count - 4)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .sheet(item: $playing) { VideoPlayerSheet(url: $0.url) }
    }

    // MARK: - Layouts

    private func single(_ item: PostMedia) -> some View {
        let ar = min(max(item.aspectRatio, 0.62), 1.9)   // clamp extremes
        // `.fit` keeps the image within the available width (never overflows).
        return cell(item).aspectRatio(ar, contentMode: .fit)
    }

    private func row(_ items: [PostMedia]) -> some View {
        HStack(spacing: gap) {
            ForEach(items) { fill(cell($0)) }
        }
        .frame(height: 220)
    }

    private func three(_ items: [PostMedia]) -> some View {
        HStack(spacing: gap) {
            fill(cell(items[0]))
            VStack(spacing: gap) {
                fill(cell(items[1]))
                fill(cell(items[2]))
            }
            .frame(width: 116)
        }
        .frame(height: 260)
    }

    private func grid(_ items: [PostMedia], extra: Int = 0) -> some View {
        VStack(spacing: gap) {
            HStack(spacing: gap) { fill(cell(items[0])); fill(cell(items[1])) }
            HStack(spacing: gap) { fill(cell(items[2])); fill(cell(items[3], overflow: extra)) }
        }
        .frame(height: 300)
    }

    /// Makes a cell split the available space evenly (never larger than offered).
    private func fill(_ view: some View) -> some View {
        view.frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Cell

    private func cell(_ item: PostMedia, overflow: Int = 0) -> some View {
        remoteImage(item.displayURL)
            .overlay {
                if item.kind == .video { playBadge }
            }
            .overlay {
                if overflow > 0 {
                    ZStack {
                        Color.black.opacity(0.45)
                        Text("+\(overflow)")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    }
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                if interactive, item.kind == .video { Haptics.tap(); playing = item }
            }
            .accessibilityLabel(item.alt ?? (item.kind == .video ? "Video" : "Image"))
    }

    private func remoteImage(_ url: URL) -> some View {
        Color.clear
            .overlay { RemoteImage(url: url, maxPixel: 1000) }
            .clipped()
    }

    private var playBadge: some View {
        ZStack {
            Circle().fill(.black.opacity(0.45)).frame(width: 60, height: 60)
            Image(systemName: "play.fill").font(.system(size: 24)).foregroundStyle(.white)
        }
    }
}
