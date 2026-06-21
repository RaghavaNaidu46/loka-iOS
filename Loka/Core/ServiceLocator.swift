import Foundation

/// Lightweight dependency container. Holds the single shared keychain-backed
/// `SecureStorage` and the configured `APIClient` so every HTTP service and
/// repository talks to the same session and base URL.
final class ServiceLocator {
    static let shared = ServiceLocator()

    let secureStorage: SecureStorage
    let client: APIClient

    private init() {
        let storage = KeychainSecureStorage()
        self.secureStorage = storage
        self.client = HTTPAPIClient(baseURL: AppConfig.baseURL, secureStorage: storage)
    }
}
