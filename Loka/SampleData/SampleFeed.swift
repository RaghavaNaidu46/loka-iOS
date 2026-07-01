#if DEBUG
import Foundation

/// Deterministic sample feed used by the DEBUG "Load sample feed data" toggle.
/// 112 posts cycling through every content type — plain text, single image
/// (landscape/portrait/square), 2/3/4/5+ galleries, video, link preview, poll,
/// and combinations — across all categories, statuses, districts, and authors.
enum SampleFeed {
    static let issues: [Issue] = build()
    private static let byId: [String: Issue] = Dictionary(uniqueKeysWithValues: issues.map { ($0.id, $0) })

    static func isSample(_ id: String) -> Bool { id.hasPrefix("sample-") }
    static func detail(id: String) -> Issue? { byId[id] }

    static func related(to id: String) -> [Issue] {
        guard let source = byId[id] else { return [] }
        return issues.filter { $0.id != id && $0.category == source.category }.prefix(3).map { $0 }
    }

    static func comments(for id: String) -> [LokaComment] {
        let seed = abs(id.hashValue)
        let count = seed % 5           // 0…4 comments
        guard count > 0 else { return [] }
        return (0..<count).map { k in
            LokaComment(
                id: "\(id)-c\(k)",
                citizenId: "cz-\(k)",
                citizenDisplayName: authors[(seed + k) % authors.count],
                issueId: id,
                text: commentTexts[(seed + k) % commentTexts.count],
                createdAt: Date().addingTimeInterval(-Double(k) * 3_600)
            )
        }
    }

    // MARK: - Generation

    private static func build() -> [Issue] {
        let districts = LokaRegion.sampleDistricts
        let categories = IssueCategory.allCases
        let statuses: [IssueStatus] = [.published, .active, .underReview, .resolved, .submitted, .rejected, .archived, .merged]

        return (0..<112).map { i in
            let c = contentPool[i % contentPool.count]
            let district = districts[i % districts.count]
            let (media, link, poll, evidence) = payload(for: i)
            let created = Date().addingTimeInterval(-Double(i) * 5_400 - 240)   // ~1.5h apart, newest a few min ago

            return Issue(
                id: "sample-\(i)",
                title: c.title,
                description: (i % 14 == 13) ? longBody : c.body,
                desiredOutcome: c.outcome,
                category: categories[i % categories.count],
                location: IssueLocation(area: i % 2 == 0 ? c.area : nil, city: district.name, district: district),
                status: statuses[i % statuses.count],
                supportCount: 5 + (i * 13) % 480,
                opposeCount: (i * 7) % 90,
                evidenceCount: evidence,
                createdAt: created,
                updatedAt: created,
                creatorDisplayName: authors[i % authors.count],
                media: media,
                link: link,
                poll: poll
            )
        }
    }

    /// Assigns the content archetype for a given index.
    private static func payload(for i: Int) -> ([PostMedia], LinkPreview?, PostPoll?, Int) {
        switch i % 14 {
        case 0:  return ([], nil, nil, i % 3)                                  // text only (+evidence)
        case 1:  return ([SampleMedia.image(i, 1200, 800)], nil, nil, 0)       // landscape image
        case 2:  return ([SampleMedia.image(i, 800, 1100)], nil, nil, 0)       // portrait image
        case 3:  return ([SampleMedia.image(i, 1000, 1000)], nil, nil, 0)      // square image
        case 4:  return (SampleMedia.gallery(i * 4, count: 2), nil, nil, 0)    // 2 images
        case 5:  return (SampleMedia.gallery(i * 4, count: 3), nil, nil, 0)    // 3 images
        case 6:  return (SampleMedia.gallery(i * 4, count: 4), nil, nil, 0)    // 4 images
        case 7:  return (SampleMedia.gallery(i * 4, count: 6), nil, nil, 0)    // 5+ images
        case 8:  return ([SampleMedia.video(i, posterSeed: i)], nil, nil, 0)   // video
        case 9:  return ([], SampleMedia.link(i), nil, 0)                      // link
        case 10: return ([], nil, poll(i), 0)                                  // poll
        case 11: return ([SampleMedia.image(i, 1000, 700)], nil, poll(i), 0)   // poll + image
        case 12: return ([SampleMedia.image(i, 1200, 900)], nil, nil, 0)       // image + text
        default: return ([], nil, nil, 0)                                      // long text only
        }
    }

    private static func poll(_ seed: Int) -> PostPoll {
        let defs: [(String, [String])] = [
            ("Which should the ward prioritise first?", ["Road repairs", "Drainage", "Street lighting", "Parks"]),
            ("Should the market be pedestrian-only on weekends?", ["Yes", "No", "Only Sundays"]),
            ("Best time for a community clean-up drive?", ["Sat morning", "Sat evening", "Sun morning"]),
            ("How is the water supply this month?", ["Reliable", "Irregular", "Very poor"])
        ]
        let d = defs[seed % defs.count]
        let options = d.1.enumerated().map { idx, text in
            PostPoll.Option(id: "opt-\(seed)-\(idx)", text: text, votes: 18 + (seed + idx * 11) % 70)
        }
        return PostPoll(question: d.0, options: options, userVotedIndex: nil)
    }

    // MARK: - Text pools

    private struct Content { let title: String; let body: String; let outcome: String; let area: String }

    private static let contentPool: [Content] = [
        Content(title: "Pothole-ridden stretch near the market needs urgent repair",
                body: "The 200m road outside the vegetable market has deep potholes that flood after every shower. Two-wheelers skid here daily.",
                outcome: "Resurface the stretch and fix the camber so water drains off.", area: "MG Road"),
        Content(title: "Streetlights out on the main road for two weeks",
                body: "An entire block has been dark since the last storm. Residents avoid walking here after 7pm.",
                outcome: "Restore the streetlights and add two more poles at the corner.", area: "Sector 4"),
        Content(title: "Overflowing garbage bins attracting stray animals",
                body: "Collection has been irregular and the bins overflow onto the footpath, creating a health hazard near the school.",
                outcome: "Reinstate daily collection and add a covered bin.", area: "Gandhi Nagar"),
        Content(title: "Irregular water supply in the colony",
                body: "We get water for barely 30 minutes on alternate days. Families are relying on expensive tankers.",
                outcome: "Restore a predictable daily supply schedule.", area: "Green Park"),
        Content(title: "Broken footpath making it unsafe for pedestrians",
                body: "The tiles are uprooted for a long stretch, forcing people — including elders — to walk on the road.",
                outcome: "Relay the footpath with a continuous, level surface.", area: "Station Road"),
        Content(title: "Waterlogging every time it rains here",
                body: "The junction turns into a pond within minutes of rain because the drain is choked with silt.",
                outcome: "De-silt the stormwater drain before the monsoon.", area: "Old Town"),
        Content(title: "Park benches and lights damaged, needs restoration",
                body: "The neighbourhood park is unusable in the evening — broken benches and no working lights.",
                outcome: "Repair benches and restore lighting so families can use it again.", area: "Lake View"),
        Content(title: "Traffic signal not working at the busy junction",
                body: "The signal has been blinking for days, causing near-misses during peak hours.",
                outcome: "Restore signal operation and add a pedestrian phase.", area: "Ring Road")
    ]

    private static let longBody = """
    This has been an ongoing problem for our neighbourhood for several months now, and despite multiple informal complaints nothing has changed. The issue affects everyone who uses this route daily — schoolchildren, office-goers, and especially the elderly. During peak hours it becomes genuinely unsafe, and after rain it is worse. We have documented it repeatedly and are now raising it here formally so the community can add their support and the concerned department can prioritise a lasting fix rather than a temporary patch.
    """

    private static let authors = [
        "Aarav Sharma", "Diya Patel", "Kabir Rao", "Ananya Reddy", "Vivaan Nair",
        "Ishaan Gupta", "Meera Krishnan", "Rohan Das", "Saanvi Iyer", "Arjun Menon"
    ]

    private static let commentTexts = [
        "This has been a problem for months. Thanks for raising it.",
        "Same issue in the next lane too.",
        "I reported this earlier with no response — glad it's here now.",
        "Adding my support. We need action before the rains.",
        "Can we get an update on the timeline?",
        "The photos are exactly what it looks like. Well documented.",
        "Happy to help organise a community follow-up.",
        "This affects the school kids the most."
    ]
}
#endif
