import Foundation

@MainActor
final class AuthViewModel: ObservableObject {
    /// Screens in the auth flow.
    enum Step {
        case login        // email + password
        case otpCode      // email-code entry for passwordless login
        case signup       // display name, email, password, confirm
        case signupCode   // email-code entry to confirm a new account
    }

    @Published var step: Step = .login
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var displayName: String = ""
    @Published var code: String = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    /// Flips to true once tokens are stored; the view observes this to route home.
    @Published private(set) var isAuthenticated = false

    private let service: AuthService

    init(service: AuthService = HTTPAuthService()) {
        self.service = service
    }

    private var trimmedEmail: String {
        email.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func isValidEmail(_ value: String) -> Bool {
        value.contains("@") && value.contains(".")
    }

    // MARK: - Navigation

    func showSignup() {
        clearTransient()
        step = .signup
    }

    func showLogin() {
        clearTransient()
        step = .login
    }

    private func clearTransient() {
        errorMessage = nil
        code = ""
    }

    // MARK: - Password login

    func login() async {
        guard isValidEmail(trimmedEmail) else {
            errorMessage = "Enter a valid email address"
            return
        }
        guard !password.isEmpty else {
            errorMessage = "Enter your password"
            return
        }
        await run {
            _ = try await self.service.login(email: self.trimmedEmail, password: self.password)
            self.isAuthenticated = true
        }
    }

    // MARK: - OTP login

    func sendLoginCode() async {
        guard isValidEmail(trimmedEmail) else {
            errorMessage = "Enter a valid email address"
            return
        }
        await run {
            try await self.service.sendOTP(email: self.trimmedEmail)
            self.code = ""
            self.step = .otpCode
        }
    }

    func verifyLoginCode() async {
        guard code.count == 6 else {
            errorMessage = "Enter the 6-digit code"
            return
        }
        await run {
            _ = try await self.service.verifyOTP(email: self.trimmedEmail, code: self.code)
            self.isAuthenticated = true
        }
    }

    // MARK: - Signup

    func signup() async {
        let name = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else {
            errorMessage = "Enter a display name"
            return
        }
        guard isValidEmail(trimmedEmail) else {
            errorMessage = "Enter a valid email address"
            return
        }
        guard password.count >= 8 else {
            errorMessage = "Password must be at least 8 characters"
            return
        }
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match"
            return
        }
        await run {
            try await self.service.signup(
                displayName: name,
                email: self.trimmedEmail,
                password: self.password,
                confirmPassword: self.confirmPassword
            )
            self.code = ""
            self.step = .signupCode
        }
    }

    func verifySignupCode() async {
        guard code.count == 6 else {
            errorMessage = "Enter the 6-digit code"
            return
        }
        await run {
            _ = try await self.service.verifySignup(email: self.trimmedEmail, code: self.code)
            self.isAuthenticated = true
        }
    }

    // MARK: - Helper

    private func run(_ work: @escaping () async throws -> Void) async {
        isLoading = true
        errorMessage = nil
        do {
            try await work()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
