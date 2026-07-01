#if DEBUG
import Foundation

/// Curated remote-media pools for the sample feed. Images come from
/// picsum.photos (stable per seed); videos are public sample clips.
enum SampleMedia {
    private static func url(_ s: String) -> URL { URL(string: s)! }

    /// A picsum image for a given seed and size (aspect ratio = w/h).
    static func image(_ seed: Int, _ w: Int, _ h: Int) -> PostMedia {
        PostMedia(
            id: "img-\(seed)-\(w)x\(h)",
            kind: .image,
            url: url("https://picsum.photos/seed/loka\(seed)/\(w)/\(h)"),
            posterURL: nil,
            aspectRatio: Double(w) / Double(h),
            alt: "Sample photo",
            duration: nil
        )
    }

    /// A set of square-ish gallery images with distinct seeds.
    static func gallery(_ startSeed: Int, count: Int) -> [PostMedia] {
        (0..<count).map { image(startSeed + $0, 800, 800) }
    }

    private static let videoURLs = [
        "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
        "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
        "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4"
    ]

    static func video(_ index: Int, posterSeed: Int) -> PostMedia {
        PostMedia(
            id: "vid-\(index)-\(posterSeed)",
            kind: .video,
            url: url(videoURLs[index % videoURLs.count]),
            posterURL: url("https://picsum.photos/seed/loka\(posterSeed)/1200/700"),
            aspectRatio: 1200.0 / 700.0,
            alt: "Sample video",
            duration: 30
        )
    }

    private static let links: [(title: String, host: String, urlString: String)] = [
        ("City council approves new drainage project ahead of monsoon", "thehindu.com", "https://www.thehindu.com"),
        ("Municipal budget 2026: what changed for your ward", "timesofindia.com", "https://timesofindia.indiatimes.com"),
        ("How to file a civic complaint that actually gets resolved", "loka.city", "https://loka.city/guide"),
        ("Ward-level air quality dashboard goes live this week", "downtoearth.org.in", "https://www.downtoearth.org.in")
    ]

    static func link(_ seed: Int) -> LinkPreview {
        let l = links[seed % links.count]
        return LinkPreview(
            url: url(l.urlString),
            title: l.title,
            host: l.host,
            imageURL: url("https://picsum.photos/seed/lokalink\(seed)/1000/520")
        )
    }
}
#endif
