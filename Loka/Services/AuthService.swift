import Foundation

protocol AuthService {
    func login(email: String, password: String) async throws -> String
    func signup(displayName: String, email: String, password: String, confirmPassword: String) async throws
    func verifySignup(email: String, code: String) async throws -> String
    func sendOTP(email: String) async throws
    func verifyOTP(email: String, code: String) async throws -> String
    func logout() async
}

final class HTTPAuthService: AuthService {
    private let client: any APIClient
    private let secureStorage: SecureStorage

    init(
        client: any APIClient = ServiceLocator.shared.client,
        secureStorage: SecureStorage = ServiceLocator.shared.secureStorage
    ) {
        self.client = client
        self.secureStorage = secureStorage
    }

    func login(email: String, password: String) async throws -> String {
        let tokens = try await client.send(Endpoints.login(email: email, password: password), decode: TokenResponseDTO.self)
        secureStorage.saveAccessToken(tokens.accessToken)
        secureStorage.saveRefreshToken(tokens.refreshToken)
        return tokens.accessToken
    }

    func signup(displayName: String, email: String, password: String, confirmPassword: String) async throws {
        try await client.send(Endpoints.signup(displayName: displayName, email: email, password: password, confirmPassword: confirmPassword))
    }

    func verifySignup(email: String, code: String) async throws -> String {
        let tokens = try await client.send(Endpoints.verifySignup(email: email, code: code), decode: TokenResponseDTO.self)
        secureStorage.saveAccessToken(tokens.accessToken)
        secureStorage.saveRefreshToken(tokens.refreshToken)
        return tokens.accessToken
    }

    func sendOTP(email: String) async throws {
        try await client.send(Endpoints.sendOTP(email: email))
    }

    func verifyOTP(email: String, code: String) async throws -> String {
        let tokens = try await client.send(Endpoints.verifyOTP(email: email, code: code), decode: TokenResponseDTO.self)
        secureStorage.saveAccessToken(tokens.accessToken)
        secureStorage.saveRefreshToken(tokens.refreshToken)
        return tokens.accessToken
    }

    func logout() async {
        if let refresh = secureStorage.refreshToken {
            try? await client.send(Endpoints.logout(refreshToken: refresh))
        }
        secureStorage.clear()
    }
}

final class MockAuthService: AuthService {
    private let secureStorage: SecureStorage

    init(secureStorage: SecureStorage = KeychainSecureStorage()) {
        self.secureStorage = secureStorage
    }

    private func mockToken() -> String {
        let token = "mock-token-\(UUID().uuidString)"
        secureStorage.saveAccessToken(token)
        secureStorage.saveRefreshToken("mock-refresh")
        return token
    }

    func login(email: String, password: String) async throws -> String {
        try await Task.sleep(nanoseconds: 400_000_000)
        return mockToken()
    }

    func signup(displayName: String, email: String, password: String, confirmPassword: String) async throws {
        try await Task.sleep(nanoseconds: 400_000_000)
    }

    func verifySignup(email: String, code: String) async throws -> String {
        try await Task.sleep(nanoseconds: 400_000_000)
        return mockToken()
    }

    func sendOTP(email: String) async throws {
        try await Task.sleep(nanoseconds: 400_000_000)
    }

    func verifyOTP(email: String, code: String) async throws -> String {
        try await Task.sleep(nanoseconds: 400_000_000)
        return mockToken()
    }

    func logout() async {
        secureStorage.clear()
    }
}
