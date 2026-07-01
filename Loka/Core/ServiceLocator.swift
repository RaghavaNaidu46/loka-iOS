import Foundation

/// Lightweight dependency container. Holds the single shared keychain-backed
/// `SecureStorage` and the configured `APIClient` so every HTTP service and
/// repository talks to the same session and base URL.
final class ServiceLocator {
    static let shared = ServiceLocator()

    let secureStorage: SecureStorage
    let client: any APIClient

    private init() {
        let storage = KeychainSecureStorage()
        self.secureStorage = storage
        let environment = LokaAPIEnvironment(baseURL: AppConfig.baseURL, secureStorage: storage)
        self.client = HTTPAPIClient(environment: environment)
    }
}
