import Foundation

protocol AuthService {
    func sendOTP(email: String) async throws
    func verifyOTP(email: String, code: String) async throws -> String
    func logout() async
}

final class HTTPAuthService: AuthService {
    private let client: APIClient
    private let secureStorage: SecureStorage

    init(
        client: APIClient = ServiceLocator.shared.client,
        secureStorage: SecureStorage = ServiceLocator.shared.secureStorage
    ) {
        self.client = client
        self.secureStorage = secureStorage
    }

    func sendOTP(email: String) async throws {
        struct Body: Encodable { let email: String }
        try await client.send(.post, "auth/send-otp", body: Body(email: email))
    }

    func verifyOTP(email: String, code: String) async throws -> String {
        struct Body: Encodable { let email: String; let otp: String }
        let tokens = try await client.send(
            .post, "auth/verify-otp",
            body: Body(email: email, otp: code),
            decode: TokenResponseDTO.self
        )
        secureStorage.saveAccessToken(tokens.accessToken)
        secureStorage.saveRefreshToken(tokens.refreshToken)
        return tokens.accessToken
    }

    func logout() async {
        if let refresh = secureStorage.refreshToken {
            struct Body: Encodable { let refreshToken: String }
            try? await client.send(.post, "auth/logout", body: Body(refreshToken: refresh))
        }
        secureStorage.clear()
    }
}

final class MockAuthService: AuthService {
    private let secureStorage: SecureStorage

    init(secureStorage: SecureStorage = KeychainSecureStorage()) {
        self.secureStorage = secureStorage
    }

    func sendOTP(email: String) async throws {
        try await Task.sleep(nanoseconds: 400_000_000)
    }

    func verifyOTP(email: String, code: String) async throws -> String {
        try await Task.sleep(nanoseconds: 400_000_000)
        let token = "mock-token-\(UUID().uuidString)"
        secureStorage.saveAccessToken(token)
        return token
    }

    func logout() async {
        secureStorage.clear()
    }
}
