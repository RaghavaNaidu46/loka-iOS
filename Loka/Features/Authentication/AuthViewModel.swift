import Foundation

@MainActor
final class AuthViewModel: ObservableObject {
    enum Step { case email, otp, done }

    @Published var step: Step = .email
    @Published var email: String = ""
    @Published var otp: String = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let service: AuthService

    init(service: AuthService = HTTPAuthService()) {
        self.service = service
    }

    func sendOTP() async {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedEmail.contains("@") && trimmedEmail.contains(".") else {
            errorMessage = "Enter a valid email address"
            return
        }
        isLoading = true
        errorMessage = nil
        do {
            try await service.sendOTP(email: trimmedEmail)
            step = .otp
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func verify() async {
        guard otp.count == 6 else {
            errorMessage = "Enter the 6-digit code"
            return
        }
        isLoading = true
        errorMessage = nil
        do {
            _ = try await service.verifyOTP(email: email.trimmingCharacters(in: .whitespacesAndNewlines), code: otp)
            step = .done
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
