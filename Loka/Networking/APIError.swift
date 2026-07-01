import Foundation

/// Errors surfaced by ``APIClient``. Conforms to `LocalizedError` so
/// `error.localizedDescription` is safe to show directly in the UI.
enum APIError: Error, LocalizedError {
    /// The request URL could not be constructed from the base URL + path.
    case invalidURL
    /// The underlying `URLSession` transport failed (offline, timeout, TLS…).
    case transport(Error)
    /// The response body could not be decoded into the expected type.
    case decoding(Error)
    /// A non-HTTP response, or an HTTP status with no server message to surface.
    case status(Int)
    /// A non-2xx HTTP status with a server-provided message (FastAPI `detail`).
    case server(Int, String)
    /// Authentication failed and could not be recovered by a token refresh —
    /// the session should be treated as expired.
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
