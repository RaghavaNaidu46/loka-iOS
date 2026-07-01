import Foundation

/// The seam between ``APIClient`` and the rest of the app: it supplies the API
/// base URL and reads/writes the auth tokens. Keeping this behind a protocol
/// lets the client stay free of `SecureStorage`/config details and makes it
/// trivial to inject a fake in tests.
protocol APIEnvironment: Sendable {
    /// Base URL every request path is resolved against (e.g. the deployed host).
    var baseURL: URL { get }

    /// The current access token, if signed in.
    func accessToken() -> String?

    /// The current refresh token, used to rotate an expired access token.
    func refreshToken() -> String?

    /// Persist a freshly rotated token pair.
    func store(access: String, refresh: String)

    /// Clear all persisted tokens (sign-out / unrecoverable auth failure).
    func clear()
}

/// Production environment: base URL from ``AppConfig`` and tokens from the
/// Keychain-backed `SecureStorage`.
///
/// `@unchecked Sendable` is justified: the only stored state is an immutable
/// `URL` and a `SecureStorage` whose access is Keychain-backed and thread-safe.
final class LokaAPIEnvironment: APIEnvironment, @unchecked Sendable {
    let baseURL: URL
    private let secureStorage: SecureStorage

    init(baseURL: URL = AppConfig.baseURL, secureStorage: SecureStorage) {
        self.baseURL = baseURL
        self.secureStorage = secureStorage
    }

    func accessToken() -> String? { secureStorage.accessToken }
    func refreshToken() -> String? { secureStorage.refreshToken }

    func store(access: String, refresh: String) {
        secureStorage.saveAccessToken(access)
        secureStorage.saveRefreshToken(refresh)
    }

    func clear() { secureStorage.clear() }
}
