import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case transport(Error)
    case decoding(Error)
    case status(Int)
    case server(Int, String)
    case unauthorized

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .transport(let error): return error.localizedDescription
        case .decoding: return "Could not read server response"
        case .status(let code): return "Request failed (\(code))"
        case .server(_, let message): return message
        case .unauthorized: return "Your session has expired. Please sign in again."
        }
    }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case patch = "PATCH"
    case delete = "DELETE"
}

struct MultipartFile {
    let field: String
    let filename: String
    let mimeType: String
    let data: Data
}

protocol APIClient {
    func send<T: Decodable>(
        _ method: HTTPMethod,
        _ path: String,
        query: [URLQueryItem],
        body: (any Encodable)?,
        decode: T.Type
    ) async throws -> T

    func send(
        _ method: HTTPMethod,
        _ path: String,
        query: [URLQueryItem],
        body: (any Encodable)?
    ) async throws

    func upload<T: Decodable>(
        _ path: String,
        fields: [String: String],
        files: [MultipartFile],
        decode: T.Type
    ) async throws -> T
}

// Convenience overloads with default arguments.
extension APIClient {
    func get<T: Decodable>(_ path: String, query: [URLQueryItem] = [], as type: T.Type) async throws -> T {
        try await send(.get, path, query: query, body: nil, decode: type)
    }

    func send<T: Decodable>(_ method: HTTPMethod, _ path: String, body: (any Encodable)? = nil, decode: T.Type) async throws -> T {
        try await send(method, path, query: [], body: body, decode: decode)
    }

    func send(_ method: HTTPMethod, _ path: String, body: (any Encodable)? = nil) async throws {
        try await send(method, path, query: [], body: body)
    }
}

final class HTTPAPIClient: APIClient {
    private let baseURL: URL
    private let session: URLSession
    private let secureStorage: SecureStorage

    init(
        baseURL: URL = AppConfig.baseURL,
        session: URLSession = .shared,
        secureStorage: SecureStorage = KeychainSecureStorage()
    ) {
        self.baseURL = baseURL
        self.session = session
        self.secureStorage = secureStorage
    }

    func send<T: Decodable>(
        _ method: HTTPMethod,
        _ path: String,
        query: [URLQueryItem],
        body: (any Encodable)?,
        decode: T.Type
    ) async throws -> T {
        let data = try await perform(method, path, query: query, body: body, allowRefresh: true)
        do {
            return try JSONDecoder.loka.decode(T.self, from: data)
        } catch {
            throw APIError.decoding(error)
        }
    }

    func send(
        _ method: HTTPMethod,
        _ path: String,
        query: [URLQueryItem],
        body: (any Encodable)?
    ) async throws {
        _ = try await perform(method, path, query: query, body: body, allowRefresh: true)
    }

    func upload<T: Decodable>(
        _ path: String,
        fields: [String: String],
        files: [MultipartFile],
        decode: T.Type
    ) async throws -> T {
        let boundary = "Boundary-\(UUID().uuidString)"
        let body = multipartBody(boundary: boundary, fields: fields, files: files)
        let data = try await perform(
            .post,
            path,
            query: [],
            rawBody: body,
            contentType: "multipart/form-data; boundary=\(boundary)",
            allowRefresh: true
        )
        do {
            return try JSONDecoder.loka.decode(T.self, from: data)
        } catch {
            throw APIError.decoding(error)
        }
    }

    // MARK: - Request execution

    private func perform(
        _ method: HTTPMethod,
        _ path: String,
        query: [URLQueryItem],
        body: (any Encodable)?,
        allowRefresh: Bool
    ) async throws -> Data {
        var rawBody: Data?
        var contentType: String?
        if let body {
            rawBody = try JSONEncoder.loka.encode(body)
            contentType = "application/json"
        }
        return try await perform(
            method,
            path,
            query: query,
            rawBody: rawBody,
            contentType: contentType,
            allowRefresh: allowRefresh
        )
    }

    private func perform(
        _ method: HTTPMethod,
        _ path: String,
        query: [URLQueryItem],
        rawBody: Data?,
        contentType: String?,
        allowRefresh: Bool
    ) async throws -> Data {
        guard var components = URLComponents(
            url: URL(string: path, relativeTo: baseURL) ?? baseURL,
            resolvingAgainstBaseURL: true
        ) else {
            throw APIError.invalidURL
        }
        if !query.isEmpty {
            components.queryItems = query
        }
        guard let url = components.url else { throw APIError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        if let contentType {
            request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        }
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let token = secureStorage.accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request.httpBody = rawBody

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw APIError.transport(error)
        }

        guard let http = response as? HTTPURLResponse else {
            throw APIError.status(-1)
        }

        if http.statusCode == 401, allowRefresh, !path.contains("auth/") {
            if await refreshTokens() {
                return try await perform(
                    method,
                    path,
                    query: query,
                    rawBody: rawBody,
                    contentType: contentType,
                    allowRefresh: false
                )
            }
            throw APIError.unauthorized
        }

        guard (200..<300).contains(http.statusCode) else {
            throw APIError.server(http.statusCode, serverMessage(from: data) ?? "Request failed (\(http.statusCode))")
        }
        return data
    }

    // MARK: - Token refresh

    private func refreshTokens() async -> Bool {
        guard let refreshToken = secureStorage.refreshToken else { return false }
        struct RefreshBody: Encodable { let refreshToken: String }
        guard let url = URL(string: "auth/refresh", relativeTo: baseURL) else { return false }
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder.loka.encode(RefreshBody(refreshToken: refreshToken))
        do {
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
                return false
            }
            let tokens = try JSONDecoder.loka.decode(TokenResponseDTO.self, from: data)
            secureStorage.saveAccessToken(tokens.accessToken)
            secureStorage.saveRefreshToken(tokens.refreshToken)
            return true
        } catch {
            return false
        }
    }

    // MARK: - Helpers

    private func serverMessage(from data: Data) -> String? {
        guard let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        if let detail = object["detail"] as? String {
            return detail
        }
        // FastAPI validation errors return detail as an array of objects.
        if let details = object["detail"] as? [[String: Any]] {
            let messages = details.compactMap { $0["msg"] as? String }
            if !messages.isEmpty { return messages.joined(separator: "\n") }
        }
        return object["message"] as? String
    }

    private func multipartBody(boundary: String, fields: [String: String], files: [MultipartFile]) -> Data {
        var body = Data()
        let lineBreak = "\r\n"
        for (key, value) in fields {
            body.append("--\(boundary)\(lineBreak)")
            body.append("Content-Disposition: form-data; name=\"\(key)\"\(lineBreak)\(lineBreak)")
            body.append("\(value)\(lineBreak)")
        }
        for file in files {
            body.append("--\(boundary)\(lineBreak)")
            body.append("Content-Disposition: form-data; name=\"\(file.field)\"; filename=\"\(file.filename)\"\(lineBreak)")
            body.append("Content-Type: \(file.mimeType)\(lineBreak)\(lineBreak)")
            body.append(file.data)
            body.append(lineBreak)
        }
        body.append("--\(boundary)--\(lineBreak)")
        return body
    }
}

private extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

extension JSONDecoder {
    static let loka: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let raw = try container.decode(String.self)
            if let date = LokaDate.parse(raw) {
                return date
            }
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Unsupported date format: \(raw)"
            )
        }
        return decoder
    }()
}

extension JSONEncoder {
    static let loka: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()
}

/// Parses the variety of ISO-8601 strings the backend emits via `datetime.isoformat()`.
/// Python's `isoformat()` produces 6-digit microseconds (e.g. `…:14.776435+00:00`),
/// which `ISO8601DateFormatter` cannot parse — so we use explicit `DateFormatter`s
/// covering microseconds/no-fraction × offset/naive.
enum LokaDate {
    private static func formatter(_ format: String) -> DateFormatter {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone(identifier: "UTC")
        f.dateFormat = format
        return f
    }

    // Order matters: most specific (fractional + offset) first.
    private static let formatters: [DateFormatter] = [
        formatter("yyyy-MM-dd'T'HH:mm:ss.SSSSSSXXXXX"), // 2026-06-21T11:26:14.776435+00:00
        formatter("yyyy-MM-dd'T'HH:mm:ssXXXXX"),        // 2026-06-21T11:26:14+00:00
        formatter("yyyy-MM-dd'T'HH:mm:ss.SSSSSS"),      // 2026-06-21T16:56:14.776610 (naive)
        formatter("yyyy-MM-dd'T'HH:mm:ss"),             // 2026-06-21T16:56:14 (naive)
    ]

    static func parse(_ string: String) -> Date? {
        for formatter in formatters {
            if let date = formatter.date(from: string) {
                return date
            }
        }
        return nil
    }
}
