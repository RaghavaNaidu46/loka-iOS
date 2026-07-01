import SwiftUI

struct AuthView: View {
    @StateObject private var viewModel = AuthViewModel()
    var onComplete: () -> Void = {}

    var body: some View {
        ScrollView {
            VStack(spacing: LokaSpacing.xl) {
                brandHeader
                VStack(alignment: .leading, spacing: LokaSpacing.lg) {
                    switch viewModel.step {
                    case .login:      loginStep
                    case .otpCode:    otpCodeStep
                    case .signup:     signupStep
                    case .signupCode: signupCodeStep
                    }
                }
                .padding(.horizontal, LokaSpacing.lg)
            }
            .padding(.bottom, LokaSpacing.xxl)
        }
        .background(LokaColor.base)
        .scrollDismissesKeyboard(.interactively)
        .navigationBarHidden(true)
        .onChange(of: viewModel.isAuthenticated) { _, authenticated in
            if authenticated { Haptics.success(); onComplete() }
        }
    }

    // MARK: - Brand header

    private var brandHeader: some View {
        VStack(spacing: LokaSpacing.lg) {
            BrandMark(size: 68, onGradient: false)
                .lokaShadow(.card)
            VStack(spacing: LokaSpacing.xs) {
                Text(title)
                    .font(LokaFont.displayMedium)
                    .foregroundStyle(LokaColor.textPrimary)
                Text(subtitle)
                    .font(LokaFont.callout)
                    .foregroundStyle(LokaColor.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, LokaSpacing.xxl)
        .padding(.bottom, LokaSpacing.sm)
    }

    private var title: String {
        switch viewModel.step {
        case .login, .otpCode: return "Welcome back"
        case .signup, .signupCode: return "Join Loka"
        }
    }

    private var subtitle: String {
        switch viewModel.step {
        case .login: return "Sign in to raise your voice."
        case .otpCode: return "Enter the code sent to \(viewModel.email)."
        case .signup: return "One citizen. One voice."
        case .signupCode: return "Confirm your email to continue."
        }
    }

    // MARK: - Steps

    private var loginStep: some View {
        VStack(alignment: .leading, spacing: LokaSpacing.lg) {
            LokaTextField(placeholder: "Email address", text: $viewModel.email, systemImage: "envelope", keyboard: .emailAddress, textContentType: .emailAddress)
            LokaTextField(placeholder: "Password", text: $viewModel.password, systemImage: "lock", isSecure: true, textContentType: .password)
            errorText
            LokaButton(title: "Sign in", isLoading: viewModel.isLoading) {
                Task { await viewModel.login() }
            }
            LokaButton(title: "Sign in with email code instead", style: .ghost) {
                Task { await viewModel.sendLoginCode() }
            }
            .disabled(viewModel.isLoading)
            footerPrompt(question: "New to Loka?", action: "Create an account") { viewModel.showSignup() }
        }
    }

    private var otpCodeStep: some View {
        VStack(alignment: .leading, spacing: LokaSpacing.lg) {
            LokaTextField(placeholder: "123456", text: $viewModel.code, systemImage: "number", keyboard: .numberPad)
            errorText
            LokaButton(title: "Verify & sign in", isLoading: viewModel.isLoading) {
                Task { await viewModel.verifyLoginCode() }
            }
            LokaButton(title: "Back to sign in", style: .ghost) { viewModel.showLogin() }
                .disabled(viewModel.isLoading)
        }
    }

    private var signupStep: some View {
        VStack(alignment: .leading, spacing: LokaSpacing.lg) {
            LokaTextField(placeholder: "Display name", text: $viewModel.displayName, systemImage: "person", textContentType: .name, autocapitalization: .words)
            LokaTextField(placeholder: "Email address", text: $viewModel.email, systemImage: "envelope", keyboard: .emailAddress, textContentType: .emailAddress)
            LokaTextField(placeholder: "Password", text: $viewModel.password, systemImage: "lock", isSecure: true, textContentType: .newPassword)
            LokaTextField(placeholder: "Confirm password", text: $viewModel.confirmPassword, systemImage: "lock.fill", isSecure: true, textContentType: .newPassword)
            errorText
            LokaButton(title: "Create account", isLoading: viewModel.isLoading) {
                Task { await viewModel.signup() }
            }
            footerPrompt(question: "Already have an account?", action: "Sign in") { viewModel.showLogin() }
        }
    }

    private var signupCodeStep: some View {
        VStack(alignment: .leading, spacing: LokaSpacing.lg) {
            LokaTextField(placeholder: "123456", text: $viewModel.code, systemImage: "number", keyboard: .numberPad)
            errorText
            LokaButton(title: "Verify & continue", isLoading: viewModel.isLoading) {
                Task { await viewModel.verifySignupCode() }
            }
            LokaButton(title: "Back", style: .ghost) { viewModel.showSignup() }
                .disabled(viewModel.isLoading)
        }
    }

    // MARK: - Reusable

    @ViewBuilder private var errorText: some View {
        if let error = viewModel.errorMessage {
            Label(error, systemImage: "exclamationmark.circle.fill")
                .font(LokaFont.caption)
                .foregroundStyle(LokaColor.danger)
        }
    }

    private func footerPrompt(question: String, action: String, perform: @escaping () -> Void) -> some View {
        HStack(spacing: LokaSpacing.xs) {
            Text(question).font(LokaFont.callout).foregroundStyle(LokaColor.textSecondary)
            Button(action) { Haptics.selection(); perform() }
                .font(LokaFont.calloutEmphasized)
                .foregroundStyle(LokaColor.brand)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.top, LokaSpacing.sm)
        .disabled(viewModel.isLoading)
    }
}

#Preview {
    NavigationStack { AuthView() }
}
