import Foundation
import OSLog

/// API request/response logger. View with:
/// `log stream --predicate 'subsystem == "com.rbchronicles.loka.app"' --info`
private let apiLog = Logger(subsystem: "com.rbchronicles.loka.app", category: "API")

/// Executes ``APIRequest``s against the Loka backend.
///
/// The client owns transport concerns only — URL/header assembly, the
/// `401 → refresh → retry` recovery, status/error mapping — and returns raw
/// `Data`. Typed decoding lives in the ``send(_:decode:)`` extension so the
/// decoded value never crosses the actor boundary (keeping generics free of
/// `Sendable` constraints).
protocol APIClient: Sendable {
    /// Execute `request` and return its response body, or throw an ``APIError``.
    func data(for request: APIRequest) async throws -> Data
}

extension APIClient {
    /// Execute `request` and decode the body as `T` (via `JSONDecoder.loka`).
    func send<T: Decodable>(_ request: APIRequest, decode: T.Type) async throws -> T {
        let data = try await data(for: request)
        do {
            return try JSONDecoder.loka.decode(T.self, from: data)
        } catch {
            throw APIError.decoding(error)
        }
    }

    /// Execute `request`, ignoring the response body.
    func send(_ request: APIRequest) async throws {
        _ = try await data(for: request)
    }
}

/// Actor-isolated ``APIClient``. Serializing request assembly through the actor
/// keeps token reads/refreshes free of data races.
actor HTTPAPIClient: APIClient {
    private let environment: any APIEnvironment
    private let session: URLSession

    /// - Parameters:
    ///   - environment: Supplies the base URL and auth tokens.
    ///   - session: Injected for testing/mocking. Defaults to `.shared`.
    init(environment: any APIEnvironment, session: URLSession = .shared) {
        self.environment = environment
        self.session = session
    }

    func data(for request: APIRequest) async throws -> Data {
        try await perform(request, allowRefresh: request.allowsRefreshRetry)
    }

    // MARK: - Request execution

    private func perform(_ request: APIRequest, allowRefresh: Bool) async throws -> Data {
        let urlRequest = try makeURLRequest(for: request)
        let method = urlRequest.httpMethod ?? "GET"
        let urlString = urlRequest.url?.absoluteString ?? "?"
        apiLog.info("➡️ \(method, privacy: .public) \(urlString, privacy: .public)")
        let start = Date()

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: urlRequest)
        } catch {
            apiLog.error("❌ \(urlString, privacy: .public) — \(error.localizedDescription, privacy: .public)")
            Self.emit(request: urlRequest, status: -1, start: start, data: Data(error.localizedDescription.utf8))
            throw APIError.transport(error)
        }

        guard let http = response as? HTTPURLResponse else {
            throw APIError.status(-1)
        }
        apiLog.info("⬅️ \(http.statusCode, privacy: .public) \(urlString, privacy: .public)")
        Self.emit(request: urlRequest, status: http.statusCode, start: start, data: data)

        // Recover an expired access token once, then replay the request.
        if http.statusCode == 401, allowRefresh {
            if await refreshTokens() {
                return try await perform(request, allowRefresh: false)
            }
            throw APIError.unauthorized
        }

        guard (200..<300).contains(http.statusCode) else {
            throw APIError.server(http.statusCode, Self.serverMessage(from: data) ?? "Request failed (\(http.statusCode))")
        }
        return data
    }

    // MARK: - Token refresh

    /// Rotate the access token using the stored refresh token. Returns whether a
    /// fresh pair was obtained and persisted. Never recurses into `perform`.
    private func refreshTokens() async -> Bool {
        guard let refresh = environment.refreshToken() else { return false }
        do {
            let urlRequest = try makeURLRequest(for: Endpoints.refresh(refreshToken: refresh))
            let (data, response) = try await session.data(for: urlRequest)
            guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
                return false
            }
            let tokens = try JSONDecoder.loka.decode(TokenResponseDTO.self, from: data)
            environment.store(access: tokens.accessToken, refresh: tokens.refreshToken)
            return true
        } catch {
            return false
        }
    }

    // MARK: - URLRequest assembly

    /// Build the fully-formed `URLRequest` — URL, headers, token and body.
    /// Exposed (non-private) for testing.
    func makeURLRequest(for request: APIRequest) throws -> URLRequest {
        let url = try Self.buildURL(base: environment.baseURL, path: request.path, query: request.query)

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        if let token = environment.accessToken() {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let multipart = request.multipart {
            let boundary = "Boundary-\(UUID().uuidString)"
            urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = Self.multipartBody(boundary: boundary, payload: multipart)
        } else {
            if let contentType = request.contentType {
                urlRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
            }
            urlRequest.httpBody = request.body
        }
        return urlRequest
    }

    /// Resolve `path` (and append `query`) against `base`. Static/pure for testing.
    static func buildURL(base: URL, path: String, query: [URLQueryItem]) throws -> URL {
        guard var components = URLComponents(
            url: URL(string: path, relativeTo: base) ?? base,
            resolvingAgainstBaseURL: true
        ) else {
            throw APIError.invalidURL
        }
        if !query.isEmpty {
            components.queryItems = query
        }
        guard let url = components.url else { throw APIError.invalidURL }
        return url
    }

    // MARK: - Helpers

    /// Extract a human-readable message from an error response — a FastAPI
    /// `detail` string, a validation-error array, or a `message` field.
    static func serverMessage(from data: Data) -> String? {
        guard let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        if let detail = object["detail"] as? String {
            return detail
        }
        if let details = object["detail"] as? [[String: Any]] {
            let messages = details.compactMap { $0["msg"] as? String }
            if !messages.isEmpty { return messages.joined(separator: "\n") }
        }
        return object["message"] as? String
    }

    static func multipartBody(boundary: String, payload: MultipartPayload) -> Data {
        var body = Data()
        let lineBreak = "\r\n"
        for (key, value) in payload.fields {
            body.append("--\(boundary)\(lineBreak)")
            body.append("Content-Disposition: form-data; name=\"\(key)\"\(lineBreak)\(lineBreak)")
            body.append("\(value)\(lineBreak)")
        }
        for file in payload.files {
            body.append("--\(boundary)\(lineBreak)")
            body.append("Content-Disposition: form-data; name=\"\(file.field)\"; filename=\"\(file.filename)\"\(lineBreak)")
            body.append("Content-Type: \(file.mimeType)\(lineBreak)\(lineBreak)")
            body.append(file.data)
            body.append(lineBreak)
        }
        body.append("--\(boundary)--\(lineBreak)")
        return body
    }

    // MARK: - Debug observer

    /// One executed request, surfaced to an optional observer for in-app debug
    /// tooling. No-op in production (the observer is `nil` unless wired by a
    /// `#if DEBUG` build), so it adds no cost on release.
    struct RequestLog: Sendable, Identifiable {
        let id = UUID()
        let date: Date
        let method: String
        let url: String
        /// HTTP status, or `-1` for a transport failure.
        let status: Int
        let milliseconds: Int
        let bytes: Int
        /// Response body (or the error text), decoded as UTF-8.
        let preview: String
        /// The request headers we sent (`Authorization` value redacted).
        let requestHeaders: [String: String]
        /// A ready-to-run `curl` for this request (token included, so it can be
        /// pasted straight into a terminal).
        let curl: String

        var ok: Bool { (200..<300).contains(status) }
    }

    /// Set by a debug build to receive every executed request. Written once at
    /// launch; `nonisolated(unsafe)` is acceptable for this debug-only hook.
    nonisolated(unsafe) static var requestObserver: (@Sendable (RequestLog) -> Void)?

    private static func emit(request: URLRequest, status: Int, start: Date, data: Data) {
        guard let observer = requestObserver else { return }
        let preview = String(decoding: data.prefix(5_000), as: UTF8.self)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        var headers = request.allHTTPHeaderFields ?? [:]
        if headers["Authorization"] != nil { headers["Authorization"] = "Bearer ••••" }
        observer(RequestLog(
            date: Date(),
            method: request.httpMethod ?? "GET",
            url: request.url?.absoluteString ?? "?",
            status: status,
            milliseconds: Int(Date().timeIntervalSince(start) * 1000),
            bytes: data.count,
            preview: preview,
            requestHeaders: headers,
            curl: curlCommand(for: request)
        ))
    }

    /// A copy-pasteable `curl` for the request, with real headers/token.
    private static func curlCommand(for request: URLRequest) -> String {
        func quote(_ s: String) -> String { "'" + s.replacingOccurrences(of: "'", with: "'\\''") + "'" }
        var parts = ["curl -X \(request.httpMethod ?? "GET") \(quote(request.url?.absoluteString ?? ""))"]
        for (key, value) in (request.allHTTPHeaderFields ?? [:]).sorted(by: { $0.key < $1.key }) {
            parts.append("-H \(quote("\(key): \(value)"))")
        }
        if let body = request.httpBody, !body.isEmpty {
            parts.append("--data \(quote(String(decoding: body, as: UTF8.self)))")
        }
        return parts.joined(separator: " \\\n  ")
    }
}

private extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
