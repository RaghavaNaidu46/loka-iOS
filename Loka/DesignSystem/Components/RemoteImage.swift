import SwiftUI

/// A cached, downsampled remote image. Shows a shimmer while loading and a
/// fallback on failure. Loading uses `.task(id:)`, which cancels automatically
/// when the view scrolls away or is reused — keeping the feed light on memory.
struct RemoteImage: View {
    let url: URL?
    /// Largest edge to decode to, in pixels. Keep close to the on-screen size.
    var maxPixel: CGFloat = 900

    @State private var image: UIImage?
    @State private var failed = false

    var body: some View {
        ZStack {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .transition(.opacity)
            } else if failed {
                ZStack {
                    LokaColor.surfaceElevated
                    Image(systemName: "photo")
                        .font(.system(size: 26))
                        .foregroundStyle(LokaColor.textTertiary)
                }
            } else {
                SkeletonBlock(cornerRadius: 0)
            }
        }
        .task(id: url?.absoluteString) {
            await load()
        }
    }

    private func load() async {
        image = nil
        failed = false
        guard let url else { failed = true; return }
        do {
            let loaded = try await ImageLoader.shared.image(for: url, maxPixel: maxPixel)
            guard !Task.isCancelled else { return }
            withAnimation(.easeOut(duration: 0.2)) { image = loaded }
        } catch {
            if !Task.isCancelled { failed = true }
        }
    }
}
