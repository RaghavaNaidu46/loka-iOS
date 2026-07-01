import Foundation

/// Rich content that a post (`Issue`) can carry beyond its text: attached media,
/// a shared link, or a poll. All optional — a post may have none, one, or several.

/// A single attached image or video.
struct PostMedia: Identifiable, Codable, Hashable {
    enum Kind: String, Codable, Hashable {
        case image
        case video
    }

    let id: String
    let kind: Kind
    let url: URL
    /// Poster/thumbnail shown before a video plays (and while it loads).
    var posterURL: URL?
    /// Width ÷ height, used to lay the media out without a layout jump.
    var aspectRatio: Double = 1
    /// Accessibility description.
    var alt: String?
    /// Video length, if known.
    var duration: TimeInterval?

    /// The image to display in the feed (poster for videos, the image itself otherwise).
    var displayURL: URL { kind == .video ? (posterURL ?? url) : url }
}

/// An unfurled link preview card.
struct LinkPreview: Codable, Hashable {
    let url: URL
    let title: String
    let host: String
    var imageURL: URL?
}

/// A poll attached to a post.
struct PostPoll: Codable, Hashable {
    struct Option: Identifiable, Codable, Hashable {
        let id: String
        let text: String
        var votes: Int
    }

    let question: String
    var options: [Option]
    /// Index of the option the current user picked, if any.
    var userVotedIndex: Int?

    var totalVotes: Int { options.reduce(0) { $0 + $1.votes } }

    func fraction(_ option: Option) -> Double {
        guard totalVotes > 0 else { return 0 }
        return Double(option.votes) / Double(totalVotes)
    }
}
