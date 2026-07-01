import Foundation

/// Centralized runtime configuration. The API base URL can be overridden at launch
/// via the `LOKA_API_BASE_URL` environment variable (handy for local/staging builds);
/// it otherwise defaults to the shared deployed backend.
enum AppConfig {
    static let baseURL: URL = {
        if let override = ProcessInfo.processInfo.environment["LOKA_API_BASE_URL"],
           let url = URL(string: override) {
            return url
        }
        return URL(string: "http://16.112.4.127:8000")!
    }()
}
