import UIKit
import ImageIO

/// Loads remote images with two levels of caching and downsampling, so the feed
/// and map stay smooth and bounded in memory:
///
/// - **Disk + memory HTTP cache** (`URLCache`) avoids re-downloading bytes.
/// - **Decoded-image cache** (`NSCache`, cost-bounded) avoids re-decoding on
///   scroll and is auto-evicted under memory pressure.
/// - **Downsampling** (ImageIO thumbnails) means a 1200×800 photo shown in a
///   200pt cell costs ~0.3 MB instead of ~3.8 MB.
///
/// Being an `actor`, decoding runs off the main thread (no scroll jank) and
/// concurrent requests for the same work are naturally serialized.
actor ImageLoader {
    static let shared = ImageLoader()

    private let cache = NSCache<NSString, UIImage>()
    private let session: URLSession

    private init() {
        let config = URLSessionConfiguration.default
        config.urlCache = URLCache(memoryCapacity: 32 * 1024 * 1024, diskCapacity: 256 * 1024 * 1024)
        config.requestCachePolicy = .returnCacheDataElseLoad
        session = URLSession(configuration: config)

        cache.countLimit = 250
        cache.totalCostLimit = 96 * 1024 * 1024   // ~96 MB of decoded pixels
    }

    /// Returns a downsampled image for `url`, sized so its largest edge is at
    /// most `maxPixel` pixels. Cached by url + size.
    func image(for url: URL, maxPixel: CGFloat) async throws -> UIImage {
        let key = "\(url.absoluteString)@\(Int(maxPixel))" as NSString
        if let cached = cache.object(forKey: key) { return cached }

        let (data, _) = try await session.data(from: url)
        guard let image = Self.downsample(data: data, maxPixel: maxPixel) else {
            throw URLError(.cannotDecodeContentData)
        }
        cache.setObject(image, forKey: key, cost: image.memoryCost)
        return image
    }

    /// Decode + downsample in one pass via ImageIO (never fully decodes the
    /// original into memory).
    private static func downsample(data: Data, maxPixel: CGFloat) -> UIImage? {
        let sourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let source = CGImageSourceCreateWithData(data as CFData, sourceOptions) else { return nil }

        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: max(maxPixel, 1)
        ]
        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}

private extension UIImage {
    /// Approximate decoded size in bytes (used as the NSCache cost).
    var memoryCost: Int {
        guard let cg = cgImage else { return 1 }
        return cg.bytesPerRow * cg.height
    }
}
