import SwiftUI

struct AuthView: View {
    @StateObject private var viewModel = AuthViewModel()
    var onComplete: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: LokaSpacing.lg) {
            switch viewModel.step {
            case .email:
                Text("Enter your email address")
                    .font(LokaFont.headingMedium)
                Text("We'll send you a one-time code to confirm.")
                    .font(LokaFont.body)
                    .foregroundStyle(LokaColor.textSecondary)
                TextField("Email address", text: $viewModel.email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .autocorrectionDisabled(true)
                    .padding(LokaSpacing.md)
                    .background(LokaColor.surface)
                    .clipShape(RoundedRectangle(cornerRadius: LokaCorner.md))
                if let error = viewModel.errorMessage {
                    Text(error).font(LokaFont.caption).foregroundStyle(LokaColor.danger)
                }
                PrimaryButton(title: "Send code", isLoading: viewModel.isLoading) {
                    Task { await viewModel.sendOTP() }
                }
            case .otp:
                Text("Enter the 6-digit code")
                    .font(LokaFont.headingMedium)
                Text("Sent to \(viewModel.email).")
                    .font(LokaFont.body)
                    .foregroundStyle(LokaColor.textSecondary)
                TextField("123456", text: $viewModel.otp)
                    .keyboardType(.numberPad)
                    .padding(LokaSpacing.md)
                    .background(LokaColor.surface)
                    .clipShape(RoundedRectangle(cornerRadius: LokaCorner.md))
                if let error = viewModel.errorMessage {
                    Text(error).font(LokaFont.caption).foregroundStyle(LokaColor.danger)
                }
                PrimaryButton(title: "Verify", isLoading: viewModel.isLoading) {
                    Task { await viewModel.verify() }
                }
            case .done:
                VStack(spacing: LokaSpacing.md) {
                    Image(systemName: "checkmark.seal")
                        .font(.system(size: 48))
                        .foregroundStyle(LokaColor.civicGreen)
                    Text("Signed in").font(LokaFont.headingMedium)
                    PrimaryButton(title: "Continue") { onComplete() }
                }
                .frame(maxWidth: .infinity)
            }
            Spacer()
        }
        .padding(LokaSpacing.lg)
        .navigationTitle("Sign in")
        .navigationBarTitleDisplayMode(.inline)
    }
}
