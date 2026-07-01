import Foundation

/// Single source of truth for every Loka API endpoint.
///
/// Every path string lives in one place — the ``Path`` table below — so there's
/// no hunting for URLs across the codebase. Each public accessor is one
/// documented `static func` that turns a `Path` into a ready ``APIRequest``
/// (method, query, body). Services call these and never construct paths or
/// bodies themselves.
enum Endpoints {

    /// The one place every endpoint path is declared. Fixed paths are constants;
    /// paths with an id are tiny builders.
    enum Path {
        // Auth
        static let login = "auth/login"
        static let signup = "auth/signup"
        static let verifySignup = "auth/verify-signup"
        static let sendOTP = "auth/send-otp"
        static let verifyOTP = "auth/verify-otp"
        static let logout = "auth/logout"
        static let refresh = "auth/refresh"

        // Citizen / profile / verification
        static let me = "profile/me"
        static let districts = "verification/districts"
        static let uploadXML = "verification/upload-xml"

        // Feed
        static let feedNearby = "feed/nearby"
        static let feedNew = "feed/new"
        static let feedPriority = "feed/priority"
        static let feedResolved = "feed/resolved"

        // Issues — id-paths are composed from `issue(_:)` so the base segment
        // is written once.
        static let issues = "issues"
        static let searchIssues = "search/issues"
        static func issue(_ id: String) -> String { "\(issues)/\(id)" }
        static func submitIssue(_ id: String) -> String { "\(issue(id))/submit" }
        static func relatedIssues(_ id: String) -> String { "\(issue(id))/related" }

        // Participation
        static func support(_ issueId: String) -> String { "\(issue(issueId))/support" }
        static func oppose(_ issueId: String) -> String { "\(issue(issueId))/oppose" }
        static func participationStatus(_ issueId: String) -> String { "\(issue(issueId))/participation/status" }

        // Comments
        static func comments(_ issueId: String) -> String { "\(issue(issueId))/comments" }

        // Notifications
        static let notifications = "notifications"
        static func markNotificationRead(_ id: String) -> String { "\(notifications)/\(id)/read" }
    }

    // MARK: - Auth
    //
    // Auth endpoints set `allowsRefreshRetry: false`: a 401 here means bad
    // credentials / code, not an expired access token, so we must not attempt a
    // token refresh + retry.

    /// `POST auth/login` — email + password → token pair.
    static func login(email: String, password: String) -> APIRequest {
        struct Body: Encodable { let email: String; let password: String }
        return post(Path.login, body: Body(email: email, password: password), refreshRetry: false)
    }

    /// `POST auth/signup` — creates an account; server emails a confirmation code.
    static func signup(displayName: String, email: String, password: String, confirmPassword: String) -> APIRequest {
        struct Body: Encodable {
            let displayName: String
            let email: String
            let password: String
            let confirmPassword: String
        }
        return post(Path.signup, body: Body(displayName: displayName, email: email, password: password, confirmPassword: confirmPassword), refreshRetry: false)
    }

    /// `POST auth/verify-signup` — confirm a new account with the emailed code → token pair.
    static func verifySignup(email: String, code: String) -> APIRequest {
        struct Body: Encodable { let email: String; let code: String }
        return post(Path.verifySignup, body: Body(email: email, code: code), refreshRetry: false)
    }

    /// `POST auth/send-otp` — request a passwordless login code by email.
    static func sendOTP(email: String) -> APIRequest {
        struct Body: Encodable { let email: String }
        return post(Path.sendOTP, body: Body(email: email), refreshRetry: false)
    }

    /// `POST auth/verify-otp` — verify a login code → token pair. (JSON key is `otp`.)
    static func verifyOTP(email: String, code: String) -> APIRequest {
        struct Body: Encodable { let email: String; let otp: String }
        return post(Path.verifyOTP, body: Body(email: email, otp: code), refreshRetry: false)
    }

    /// `POST auth/logout` — blacklist the refresh token server-side.
    static func logout(refreshToken: String) -> APIRequest {
        struct Body: Encodable { let refreshToken: String }
        return post(Path.logout, body: Body(refreshToken: refreshToken), refreshRetry: false)
    }

    /// `POST auth/refresh` — rotate an expired access token. Used internally by
    /// ``HTTPAPIClient`` during its 401 recovery.
    static func refresh(refreshToken: String) -> APIRequest {
        struct Body: Encodable { let refreshToken: String }
        return post(Path.refresh, body: Body(refreshToken: refreshToken), refreshRetry: false)
    }

    // MARK: - Citizen / Profile

    /// `GET profile/me` — the signed-in citizen.
    static func me() -> APIRequest {
        get(Path.me)
    }

    /// `PATCH verification/districts?homeDistrictId=&livingInDistrictId=` —
    /// set participation districts. Each id is included only when provided.
    static func updateDistricts(homeDistrictId: String?, livingInDistrictId: String?) -> APIRequest {
        patch(Path.districts, query: queryItems([
            ("homeDistrictId", homeDistrictId),
            ("livingInDistrictId", livingInDistrictId)
        ]))
    }

    // MARK: - Feed / Issues

    /// `GET feed/nearby` — issues in the citizen's district.
    static func feedNearby() -> APIRequest { get(Path.feedNearby) }
    /// `GET feed/new` — recently submitted issues.
    static func feedNew() -> APIRequest { get(Path.feedNew) }
    /// `GET feed/priority` — highest-participation issues.
    static func feedPriority() -> APIRequest { get(Path.feedPriority) }
    /// `GET feed/resolved` — resolved outcomes.
    static func feedResolved() -> APIRequest { get(Path.feedResolved) }

    /// `GET issues/{id}` — full issue detail.
    static func issueDetail(id: String) -> APIRequest {
        get(Path.issue(id))
    }

    /// `GET issues/{id}/related` — issues related to the given one.
    static func relatedIssues(id: String) -> APIRequest {
        get(Path.relatedIssues(id))
    }

    /// `GET search/issues?query=&districtId=&category=` — each filter included
    /// only when present (query only when non-empty). Backs both search and
    /// duplicate detection.
    static func searchIssues(query: String, districtId: String?, category: String?) -> APIRequest {
        get(Path.searchIssues, query: queryItems([
            ("query", query.isEmpty ? nil : query),
            ("districtId", districtId),
            ("category", category)
        ]))
    }

    /// `POST issues` — create a draft issue.
    static func createIssue(title: String, description: String, desiredOutcome: String,
                            category: IssueCategory, area: String?, city: String, districtId: String) -> APIRequest {
        struct LocationBody: Encodable { let area: String?; let city: String; let districtId: String }
        struct CreateBody: Encodable {
            let title: String
            let description: String
            let desiredOutcome: String
            let category: IssueCategory
            let location: LocationBody
        }
        return post(Path.issues, body: CreateBody(
            title: title, description: description, desiredOutcome: desiredOutcome, category: category,
            location: LocationBody(area: area, city: city, districtId: districtId)
        ))
    }

    /// `POST issues/{id}/submit` — submit a draft for moderation review.
    static func submitIssue(id: String) -> APIRequest {
        post(Path.submitIssue(id))
    }

    // MARK: - Participation

    /// `POST issues/{id}/support` — record permanent support.
    static func support(issueId: String) -> APIRequest {
        struct Body: Encodable { let confirmed: Bool }
        return post(Path.support(issueId), body: Body(confirmed: true))
    }

    /// `POST issues/{id}/oppose` — record permanent opposition with explanation.
    static func oppose(issueId: String, explanation: String) -> APIRequest {
        struct Body: Encodable { let explanation: String; let confirmed: Bool }
        return post(Path.oppose(issueId), body: Body(explanation: explanation, confirmed: true))
    }

    /// `GET issues/{id}/participation/status` — whether the citizen has participated.
    static func participationStatus(issueId: String) -> APIRequest {
        get(Path.participationStatus(issueId))
    }

    // MARK: - Comments

    /// `GET issues/{id}/comments` — discussion thread.
    static func comments(issueId: String) -> APIRequest {
        get(Path.comments(issueId))
    }

    /// `POST issues/{id}/comments` — add a comment.
    static func addComment(issueId: String, text: String) -> APIRequest {
        struct Body: Encodable { let text: String }
        return post(Path.comments(issueId), body: Body(text: text))
    }

    // MARK: - Notifications

    /// `GET notifications` — the citizen's notifications.
    static func notifications() -> APIRequest { get(Path.notifications) }

    /// `PATCH notifications/{id}/read` — mark one as read.
    static func markNotificationRead(id: String) -> APIRequest {
        patch(Path.markNotificationRead(id))
    }

    // MARK: - Verification

    /// `POST verification/upload-xml` — multipart upload of the Aadhaar Offline
    /// XML plus its share code.
    static func uploadVerificationXML(data: Data, shareCode: String) -> APIRequest {
        let file = MultipartFile(field: "xmlFile", filename: "aadhaar.xml", mimeType: "application/xml", data: data)
        return APIRequest(method: .post, path: Path.uploadXML,
                          multipart: MultipartPayload(fields: ["shareCode": shareCode], files: [file]))
    }

    // MARK: - Builders
    //
    // One place each for GET/POST/PATCH assembly, so no endpoint repeats the
    // method / JSON content-type / body-encoding boilerplate.

    private static func get(_ path: String, query: [URLQueryItem] = []) -> APIRequest {
        APIRequest(method: .get, path: path, query: query)
    }

    private static func patch(_ path: String, query: [URLQueryItem] = []) -> APIRequest {
        APIRequest(method: .patch, path: path, query: query)
    }

    /// POST with no body.
    private static func post(_ path: String) -> APIRequest {
        APIRequest(method: .post, path: path)
    }

    /// POST a JSON body. `refreshRetry: false` for auth endpoints, where a 401
    /// means bad credentials — not an expired token to refresh.
    private static func post<Body: Encodable>(_ path: String, body: Body, refreshRetry: Bool = true) -> APIRequest {
        APIRequest(method: .post, path: path, body: encode(body),
                   contentType: "application/json", allowsRefreshRetry: refreshRetry)
    }

    /// Builds query items from an ordered list of name/value pairs, dropping the
    /// nil values. Ordered (not a dictionary) so the query string is deterministic.
    private static func queryItems(_ pairs: [(String, String?)]) -> [URLQueryItem] {
        pairs.compactMap { name, value in value.map { URLQueryItem(name: name, value: $0) } }
    }

    /// Encodes a request body with the shared coder. Our body structs are simple
    /// and never fail to encode, so a failure degrades to an empty body rather
    /// than making every endpoint `throws`.
    private static func encode<T: Encodable>(_ value: T) -> Data {
        (try? JSONEncoder.loka.encode(value)) ?? Data()
    }
}
