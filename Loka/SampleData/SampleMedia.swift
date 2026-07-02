#if DEBUG
import Foundation

/// Curated remote-media pools for the sample feed. Images come from LoremFlickr
/// (real Flickr photos matching the given keywords, so they relate to the post
/// content); videos are public sample clips. `lock` makes each URL stable — the
/// same seed always returns the same image.
enum SampleMedia {
    private static func url(_ s: String) -> URL { URL(string: s)! }

    /// A keyword-matched photo (aspect ratio = w/h). `keywords` is comma-separated.
    private static func flickr(_ w: Int, _ h: Int, _ keywords: String, lock: Int) -> URL {
        url("https://loremflickr.com/\(w)/\(h)/\(keywords)?lock=\(lock)")
    }

    static func image(_ seed: Int, _ w: Int, _ h: Int, _ keywords: String) -> PostMedia {
        PostMedia(
            id: "img-\(seed)-\(w)x\(h)",
            kind: .image,
            url: flickr(w, h, keywords, lock: seed),
            posterURL: nil,
            aspectRatio: Double(w) / Double(h),
            alt: keywords.replacingOccurrences(of: ",", with: " "),
            duration: nil
        )
    }

    /// A set of gallery images on the same topic, each visually distinct.
    static func gallery(_ startSeed: Int, count: Int, _ keywords: String) -> [PostMedia] {
        (0..<count).map { image(startSeed + $0, 800, 800, keywords) }
    }

    private static let videoURLs = [
        "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
        "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
        "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4"
    ]

    static func video(_ index: Int, posterSeed: Int, _ keywords: String) -> PostMedia {
        PostMedia(
            id: "vid-\(index)-\(posterSeed)",
            kind: .video,
            url: url(videoURLs[index % videoURLs.count]),
            posterURL: flickr(1200, 700, keywords, lock: posterSeed),
            aspectRatio: 1200.0 / 700.0,
            alt: "Sample video",
            duration: 30
        )
    }

    private static let links: [(title: String, host: String, urlString: String, keywords: String)] = [
        ("City council approves new drainage project ahead of monsoon", "thehindu.com", "https://www.thehindu.com", "drainage,construction"),
        ("Municipal budget 2026: what changed for your ward", "timesofindia.com", "https://timesofindia.indiatimes.com", "city,government"),
        ("How to file a civic complaint that actually gets resolved", "loka.city", "https://loka.city/guide", "notebook,city"),
        ("Ward-level air quality dashboard goes live this week", "downtoearth.org.in", "https://www.downtoearth.org.in", "city,skyline")
    ]

    static func link(_ seed: Int) -> LinkPreview {
        let l = links[seed % links.count]
        return LinkPreview(
            url: url(l.urlString),
            title: l.title,
            host: l.host,
            imageURL: flickr(1000, 520, l.keywords, lock: seed)
        )
    }
}
#endif
