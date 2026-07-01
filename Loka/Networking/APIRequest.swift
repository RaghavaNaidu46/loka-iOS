import Foundation

/// A single file to upload as one part of a multipart request.
struct MultipartFile: Sendable {
    let field: String
    let filename: String
    let mimeType: String
    let data: Data
}

/// The payload of a `multipart/form-data` request: plain form fields plus files.
struct MultipartPayload: Sendable {
    let fields: [String: String]
    let files: [MultipartFile]
}

/// A value-type description of one API call. ``APIClient`` turns it into a
/// `URLRequest` (resolving the path against the base URL, attaching the bearer
/// token, encoding the body, etc.). Build these via ``Endpoints`` — never
/// inline in a service.
struct APIRequest: Sendable {
    /// HTTP method.
    var method: HTTPMethod

    /// Path resolved against ``APIEnvironment/baseURL`` (e.g. `"issues/\(id)"`).
    /// No leading slash.
    var path: String

    /// Query parameters, appended in the order given.
    var query: [URLQueryItem]

    /// Pre-encoded JSON body, if any. Bodies are encoded in ``Endpoints`` (with
    /// `JSONEncoder.loka`) so the client stays `Sendable` and body-shape-free.
    var body: Data?

    /// `Content-Type` for ``body`` (JSON bodies set `application/json`).
    /// Ignored when ``multipart`` is set (which supplies its own boundary type).
    var contentType: String?

    /// A multipart form payload, mutually exclusive with ``body``.
    var multipart: MultipartPayload?

    /// Whether a `401` should trigger a token refresh + one retry. Auth
    /// endpoints set this `false` (a failed login must not attempt a refresh).
    var allowsRefreshRetry: Bool

    init(
        method: HTTPMethod = .get,
        path: String,
        query: [URLQueryItem] = [],
        body: Data? = nil,
        contentType: String? = nil,
        multipart: MultipartPayload? = nil,
        allowsRefreshRetry: Bool = true
    ) {
        self.method = method
        self.path = path
        self.query = query
        self.body = body
        self.contentType = contentType
        self.multipart = multipart
        self.allowsRefreshRetry = allowsRefreshRetry
    }
}
