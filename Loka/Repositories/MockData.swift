import Foundation

enum MockData {
    static let currentCitizen: Citizen = Citizen(
        id: "mock-citizen-1",
        displayName: "Civic Citizen",
        phoneNumber: nil,
        verificationStatus: .unverified,
        homeDistrict: LokaRegion.sampleDistricts.first,
        livingInDistrict: LokaRegion.sampleDistricts.first,
        createdAt: Date().addingTimeInterval(-86_400 * 14),
        lastActiveAt: Date()
    )

    static let issues: [Issue] = {
        let vsg = LokaRegion.sampleDistricts[0]
        let vja = LokaRegion.sampleDistricts[1]
        let hyd = LokaRegion.sampleDistricts[4]
        let now = Date()
        return [
            Issue(
                id: "issue-1",
                title: "Water supply disrupted for 4 days in MVP Colony",
                description: "Residents of MVP Colony have not received tap water since Monday. The local pump station appears non-operational.",
                desiredOutcome: "Restore regular water supply and publish a maintenance schedule.",
                category: .water,
                location: IssueLocation(area: "MVP Colony", city: "Visakhapatnam", district: vsg),
                status: .active,
                supportCount: 214,
                opposeCount: 18,
                evidenceCount: 12,
                createdAt: now.addingTimeInterval(-86_400 * 3),
                updatedAt: now.addingTimeInterval(-3600 * 2),
                creatorDisplayName: "Citizen V"
            ),
            Issue(
                id: "issue-2",
                title: "Pothole-ridden road near Benz Circle slowing traffic",
                description: "Major potholes on the arterial road have caused two scooter accidents this week.",
                desiredOutcome: "Resurface the affected stretch and add temporary signage.",
                category: .roads,
                location: IssueLocation(area: "Benz Circle", city: "Vijayawada", district: vja),
                status: .underReview,
                supportCount: 88,
                opposeCount: 6,
                evidenceCount: 5,
                createdAt: now.addingTimeInterval(-86_400 * 1),
                updatedAt: now.addingTimeInterval(-3600 * 6),
                creatorDisplayName: "Citizen R"
            ),
            Issue(
                id: "issue-3",
                title: "Frequent power cuts in Kukatpally during evening hours",
                description: "Unscheduled power cuts of 1-2 hours have become routine in the last fortnight.",
                desiredOutcome: "Publish a load-shedding schedule and address transformer load issues.",
                category: .electricity,
                location: IssueLocation(area: "Kukatpally", city: "Hyderabad", district: hyd),
                status: .published,
                supportCount: 412,
                opposeCount: 22,
                evidenceCount: 3,
                createdAt: now.addingTimeInterval(-86_400 * 5),
                updatedAt: now.addingTimeInterval(-3600 * 12),
                creatorDisplayName: "Citizen K"
            ),
            Issue(
                id: "issue-4",
                title: "Open drainage near Government High School",
                description: "An open drain next to the school entrance is a daily hazard for students.",
                desiredOutcome: "Cover the drain and add a railing along the school boundary.",
                category: .publicSafety,
                location: IssueLocation(area: "Old Town", city: "Visakhapatnam", district: vsg),
                status: .resolved,
                supportCount: 156,
                opposeCount: 4,
                evidenceCount: 8,
                createdAt: now.addingTimeInterval(-86_400 * 30),
                updatedAt: now.addingTimeInterval(-86_400 * 2),
                creatorDisplayName: "Citizen S"
            ),
            Issue(
                id: "issue-5",
                title: "Public park encroachment in Banjara Hills",
                description: "A portion of the public park has been fenced off by an unidentified party.",
                desiredOutcome: "Investigate encroachment and restore public access.",
                category: .governance,
                location: IssueLocation(area: "Banjara Hills", city: "Hyderabad", district: hyd),
                status: .active,
                supportCount: 67,
                opposeCount: 11,
                evidenceCount: 4,
                createdAt: now.addingTimeInterval(-86_400 * 2),
                updatedAt: now.addingTimeInterval(-3600 * 1),
                creatorDisplayName: "Citizen H"
            )
        ]
    }()

    static let notifications: [LokaNotification] = {
        let now = Date()
        return [
            LokaNotification(
                id: "n-1",
                kind: .issueApproved,
                title: "Issue approved",
                body: "Your issue \"Pothole-ridden road near Benz Circle\" was approved.",
                referenceId: "issue-2",
                isRead: false,
                createdAt: now.addingTimeInterval(-1800)
            ),
            LokaNotification(
                id: "n-2",
                kind: .clarificationRequested,
                title: "Clarification requested",
                body: "A moderator asked for additional evidence on your issue.",
                referenceId: "issue-1",
                isRead: false,
                createdAt: now.addingTimeInterval(-3600 * 3)
            ),
            LokaNotification(
                id: "n-3",
                kind: .resolutionUpdate,
                title: "Issue resolved",
                body: "An issue you supported has been marked resolved.",
                referenceId: "issue-4",
                isRead: true,
                createdAt: now.addingTimeInterval(-86_400)
            )
        ]
    }()

    static func comments(forIssue id: String) -> [LokaComment] {
        let now = Date()
        return [
            LokaComment(
                id: "c-1",
                citizenId: "mock-c-2",
                citizenDisplayName: "Citizen A",
                issueId: id,
                text: "This is a long-standing problem in our area. Thanks for raising it.",
                createdAt: now.addingTimeInterval(-3600 * 5)
            ),
            LokaComment(
                id: "c-2",
                citizenId: "mock-c-3",
                citizenDisplayName: "Citizen B",
                issueId: id,
                text: "Adding evidence from yesterday — same situation continues.",
                createdAt: now.addingTimeInterval(-3600 * 2)
            )
        ]
    }
}
