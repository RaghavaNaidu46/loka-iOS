import Foundation

enum AuthState: Equatable {
    case anonymous
    case authenticated(citizenId: String)
}

enum CitizenState: Equatable {
    case visitor
    case unverified
    case verified
}

@MainActor
final class AppSessionManager: ObservableObject {
    @Published private(set) var authState: AuthState = .anonymous
    @Published private(set) var citizenState: CitizenState = .visitor
    @Published private(set) var currentCitizen: Citizen?
    @Published private(set) var homeDistrict: District?
    @Published private(set) var livingInDistrict: District?

    private let secureStorage: SecureStorage
    private let citizenRepository: CitizenRepository
    private let authService: AuthService

    init(
        secureStorage: SecureStorage = ServiceLocator.shared.secureStorage,
        citizenRepository: CitizenRepository = HTTPCitizenRepository(),
        authService: AuthService = HTTPAuthService()
    ) {
        self.secureStorage = secureStorage
        self.citizenRepository = citizenRepository
        self.authService = authService
    }

    func bootstrap() async {
        guard secureStorage.accessToken != nil else {
            authState = .anonymous
            return
        }
        do {
            let me = try await citizenRepository.fetchMe()
            currentCitizen = me
            authState = .authenticated(citizenId: me.id)
            citizenState = me.isVerified ? .verified : .unverified
            homeDistrict = me.homeDistrict
            livingInDistrict = me.livingInDistrict
        } catch APIError.unauthorized {
            // Token genuinely expired/revoked — sign out.
            signOutLocally()
        } catch let APIError.server(code, _) where code == 401 {
            signOutLocally()
        } catch {
            // Transient failure (network down, server error, decode) — keep the
            // saved token so the session can be restored on the next launch.
            authState = .anonymous
        }
    }

    func signOut() {
        // logout() blacklists the refresh token and then clears secure storage.
        let service = authService
        Task { await service.logout() }
        resetState()
    }

    /// Clears the persisted tokens immediately (used when a token is already invalid,
    /// so there is nothing to blacklist server-side).
    private func signOutLocally() {
        secureStorage.clear()
        resetState()
    }

    private func resetState() {
        authState = .anonymous
        citizenState = .visitor
        currentCitizen = nil
        homeDistrict = nil
        livingInDistrict = nil
    }
}
