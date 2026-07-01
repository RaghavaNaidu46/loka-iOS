import SwiftUI

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
    // Editing a field clears its own validation error ("once entered, hide").
    @Published var email: String = "" { didSet { emailError = nil } }
    @Published var password: String = "" { didSet { passwordError = nil } }
    @Published var confirmPassword: String = "" { didSet { confirmPasswordError = nil } }
    @Published var displayName: String = "" { didSet { displayNameError = nil } }
    @Published var code: String = "" { didSet { codeError = nil } }
    @Published var isLoading = false

    /// Per-field validation errors, shown beneath each field.
    @Published var emailError: String?
    @Published var passwordError: String?
    @Published var confirmPasswordError: String?
    @Published var displayNameError: String?
    @Published var codeError: String?

    /// General (server) error not tied to a single field, e.g. "invalid credentials".
    @Published var errorMessage: String?

    /// Whether the last step change moved backward in the flow. The view uses
    /// this to slide correctly (forward: new from right; back: new from left).
    /// Set together with `step` so the view never renders a stale direction.
    @Published private(set) var isBackNavigation = false

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
        go(to: .signup)
    }

    func showLogin() {
        clearTransient()
        go(to: .login)
    }

    /// Change step and record the direction (by flow depth) in the same update.
    /// The direction is set first (so the view reads it correctly), then the
    /// step change is animated — the transition + header slide with one spring.
    private func go(to newStep: Step) {
        isBackNavigation = depth(of: newStep) < depth(of: step)
        withAnimation(LokaAnimation.snappy) { step = newStep }
    }

    private func depth(of step: Step) -> Int {
        switch step {
        case .login: return 0
        case .signup, .otpCode: return 1
        case .signupCode: return 2
        }
    }

    private func clearTransient() {
        errorMessage = nil
        code = ""
        emailError = nil
        passwordError = nil
        confirmPasswordError = nil
        displayNameError = nil
        codeError = nil
    }

    // MARK: - Password login

    func login() async {
        // Validate every field first so all missing ones surface together.
        var valid = true
        if !isValidEmail(trimmedEmail) { emailError = "Enter a valid email address"; valid = false }
        if password.isEmpty { passwordError = "Enter your password"; valid = false }
        guard valid else { return }

        await run {
            _ = try await self.service.login(email: self.trimmedEmail, password: self.password)
            self.isAuthenticated = true
        }
    }

    // MARK: - OTP login

    func sendLoginCode() async {
        guard isValidEmail(trimmedEmail) else {
            emailError = "Enter a valid email address"
            return
        }
        await run {
            try await self.service.sendOTP(email: self.trimmedEmail)
            self.code = ""
            self.go(to: .otpCode)
        }
    }

    func verifyLoginCode() async {
        guard code.count == 6 else {
            codeError = "Enter the 6-digit code"
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
        var valid = true
        if name.isEmpty { displayNameError = "Enter a display name"; valid = false }
        if !isValidEmail(trimmedEmail) { emailError = "Enter a valid email address"; valid = false }
        if password.count < 8 { passwordError = "Password must be at least 8 characters"; valid = false }
        if password != confirmPassword { confirmPasswordError = "Passwords do not match"; valid = false }
        guard valid else { return }

        await run {
            try await self.service.signup(
                displayName: name,
                email: self.trimmedEmail,
                password: self.password,
                confirmPassword: self.confirmPassword
            )
            self.code = ""
            self.go(to: .signupCode)
        }
    }

    func verifySignupCode() async {
        guard code.count == 6 else {
            codeError = "Enter the 6-digit code"
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
