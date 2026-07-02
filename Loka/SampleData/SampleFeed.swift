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
        let categories = IssueCategory.allCases
        let statuses: [IssueStatus] = [.published, .active, .underReview, .resolved, .submitted, .rejected, .archived, .merged]

        return (0..<140).map { i in
            let c = contentPool[i % contentPool.count]
            let place = places[i % places.count]
            // Each place becomes the issue's district so locations spread across
            // both states (not just a handful of cities).
            let district = District(id: "smpl-\(i % places.count)", name: place.name, state: place.state,
                                    country: "India", coordinate: Coordinate(latitude: place.lat, longitude: place.lon))
            let (media, link, poll, evidence) = payload(for: i, keywords: c.keywords)
            let created = Date().addingTimeInterval(-Double(i) * 5_400 - 240)   // ~1.5h apart, newest a few min ago

            // Scatter pins ~±0.05° (~5km) around the town centre.
            let point = Coordinate(latitude: place.lat + Double((i % 13) - 6) * 0.008,
                                   longitude: place.lon + Double((i % 11) - 5) * 0.008)

            return Issue(
                id: "sample-\(i)",
                title: c.title,
                description: (i % 14 == 13) ? longBody : c.body,
                desiredOutcome: c.outcome,
                category: categories[i % categories.count],
                location: IssueLocation(area: i % 2 == 0 ? c.area : nil, city: district.name, district: district, coordinate: point),
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

    /// Assigns the content archetype for a given index, using topic `keywords`
    /// so the images relate to the post.
    private static func payload(for i: Int, keywords: String) -> ([PostMedia], LinkPreview?, PostPoll?, Int) {
        switch i % 14 {
        case 0:  return ([], nil, nil, i % 3)                                          // text only (+evidence)
        case 1:  return ([SampleMedia.image(i, 1200, 800, keywords)], nil, nil, 0)     // landscape image
        case 2:  return ([SampleMedia.image(i, 800, 1100, keywords)], nil, nil, 0)     // portrait image
        case 3:  return ([SampleMedia.image(i, 1000, 1000, keywords)], nil, nil, 0)    // square image
        case 4:  return (SampleMedia.gallery(i * 4, count: 2, keywords), nil, nil, 0)  // 2 images
        case 5:  return (SampleMedia.gallery(i * 4, count: 3, keywords), nil, nil, 0)  // 3 images
        case 6:  return (SampleMedia.gallery(i * 4, count: 4, keywords), nil, nil, 0)  // 4 images
        case 7:  return (SampleMedia.gallery(i * 4, count: 6, keywords), nil, nil, 0)  // 5+ images
        case 8:  return ([SampleMedia.video(i, posterSeed: i, keywords)], nil, nil, 0) // video
        case 9:  return ([], SampleMedia.link(i), nil, 0)                              // link
        case 10: return ([], nil, poll(i), 0)                                          // poll
        case 11: return ([SampleMedia.image(i, 1000, 700, keywords)], nil, poll(i), 0) // poll + image
        case 12: return ([SampleMedia.image(i, 1200, 900, keywords)], nil, nil, 0)     // image + text
        default: return ([], nil, nil, 0)                                              // long text only
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

    private struct Content { let title: String; let body: String; let outcome: String; let area: String; let keywords: String }

    private static let contentPool: [Content] = [
        Content(title: "Pothole-ridden stretch near the market needs urgent repair",
                body: "The 200m road outside the vegetable market has deep potholes that flood after every shower. Two-wheelers skid here daily.",
                outcome: "Resurface the stretch and fix the camber so water drains off.", area: "MG Road",
                keywords: "pothole,road"),
        Content(title: "Streetlights out on the main road for two weeks",
                body: "An entire block has been dark since the last storm. Residents avoid walking here after 7pm.",
                outcome: "Restore the streetlights and add two more poles at the corner.", area: "Sector 4",
                keywords: "streetlight,night"),
        Content(title: "Overflowing garbage bins attracting stray animals",
                body: "Collection has been irregular and the bins overflow onto the footpath, creating a health hazard near the school.",
                outcome: "Reinstate daily collection and add a covered bin.", area: "Gandhi Nagar",
                keywords: "garbage,street"),
        Content(title: "Irregular water supply in the colony",
                body: "We get water for barely 30 minutes on alternate days. Families are relying on expensive tankers.",
                outcome: "Restore a predictable daily supply schedule.", area: "Green Park",
                keywords: "water,tap"),
        Content(title: "Broken footpath making it unsafe for pedestrians",
                body: "The tiles are uprooted for a long stretch, forcing people — including elders — to walk on the road.",
                outcome: "Relay the footpath with a continuous, level surface.", area: "Station Road",
                keywords: "sidewalk,pavement"),
        Content(title: "Waterlogging every time it rains here",
                body: "The junction turns into a pond within minutes of rain because the drain is choked with silt.",
                outcome: "De-silt the stormwater drain before the monsoon.", area: "Old Town",
                keywords: "flood,street"),
        Content(title: "Park benches and lights damaged, needs restoration",
                body: "The neighbourhood park is unusable in the evening — broken benches and no working lights.",
                outcome: "Repair benches and restore lighting so families can use it again.", area: "Lake View",
                keywords: "park,bench"),
        Content(title: "Traffic signal not working at the busy junction",
                body: "The signal has been blinking for days, causing near-misses during peak hours.",
                outcome: "Restore signal operation and add a pedestrian phase.", area: "Ring Road",
                keywords: "traffic,signal")
    ]

    private static let longBody = """
    This has been an ongoing problem for our neighbourhood for several months now, and despite multiple informal complaints nothing has changed. The issue affects everyone who uses this route daily — schoolchildren, office-goers, and especially the elderly. During peak hours it becomes genuinely unsafe, and after rain it is worse. We have documented it repeatedly and are now raising it here formally so the community can add their support and the concerned department can prioritise a lasting fix rather than a temporary patch.
    """

    /// Towns and cities across Andhra Pradesh & Telangana so pins spread over
    /// both states rather than clustering in a few cities.
    private static let places: [(name: String, state: String, lat: Double, lon: Double)] = [
        // Andhra Pradesh
        ("Visakhapatnam", "Andhra Pradesh", 17.6868, 83.2185),
        ("Vijayawada", "Andhra Pradesh", 16.5062, 80.6480),
        ("Guntur", "Andhra Pradesh", 16.3067, 80.4365),
        ("Tirupati", "Andhra Pradesh", 13.6288, 79.4192),
        ("Nellore", "Andhra Pradesh", 14.4426, 79.9865),
        ("Kakinada", "Andhra Pradesh", 16.9891, 82.2475),
        ("Rajamahendravaram", "Andhra Pradesh", 16.9891, 81.7840),
        ("Kurnool", "Andhra Pradesh", 15.8281, 78.0373),
        ("Anantapur", "Andhra Pradesh", 14.6819, 77.6006),
        ("Kadapa", "Andhra Pradesh", 14.4673, 78.8242),
        ("Eluru", "Andhra Pradesh", 16.7107, 81.0952),
        ("Ongole", "Andhra Pradesh", 15.5057, 80.0499),
        ("Vizianagaram", "Andhra Pradesh", 18.1067, 83.3956),
        ("Srikakulam", "Andhra Pradesh", 18.2969, 83.8938),
        ("Chittoor", "Andhra Pradesh", 13.2172, 79.1003),
        ("Machilipatnam", "Andhra Pradesh", 16.1875, 81.1389),
        ("Tenali", "Andhra Pradesh", 16.2430, 80.6400),
        ("Proddatur", "Andhra Pradesh", 14.7502, 78.5481),
        // Telangana
        ("Hyderabad", "Telangana", 17.3850, 78.4867),
        ("Secunderabad", "Telangana", 17.4399, 78.4983),
        ("Warangal", "Telangana", 17.9689, 79.5941),
        ("Khammam", "Telangana", 17.2473, 80.1514),
        ("Nizamabad", "Telangana", 18.6725, 78.0941),
        ("Karimnagar", "Telangana", 18.4386, 79.1288),
        ("Ramagundam", "Telangana", 18.7550, 79.4740),
        ("Mahbubnagar", "Telangana", 16.7488, 77.9857),
        ("Nalgonda", "Telangana", 17.0575, 79.2684),
        ("Adilabad", "Telangana", 19.6641, 78.5320),
        ("Siddipet", "Telangana", 18.1018, 78.8520),
        ("Suryapet", "Telangana", 17.1400, 79.6200),
        ("Miryalaguda", "Telangana", 16.8726, 79.5658),
        ("Sangareddy", "Telangana", 17.6247, 78.0820)
    ]

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
