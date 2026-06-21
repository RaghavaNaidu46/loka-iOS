import SwiftUI

struct BecomeCitizenView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = BecomeCitizenViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: LokaSpacing.lg) {
                switch viewModel.step {
                case .intro: introStep
                case .upload: uploadStep
                case .shareCode: shareCodeStep
                case .processing: processingStep
                case .districts: districtsStep
                case .complete: completeStep
                }
            }
            .padding(LokaSpacing.lg)
        }
        .background(LokaColor.background)
        .navigationTitle("Become a Citizen")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var introStep: some View {
        VStack(alignment: .leading, spacing: LokaSpacing.md) {
            Image(systemName: "checkmark.seal")
                .font(.system(size: 36))
                .foregroundStyle(LokaColor.accent)
            Text("Verify once. Participate openly.")
                .font(LokaFont.headingMedium)
            Text("Loka verifies your identity privately using Aadhaar Offline XML. Your Aadhaar number and personal details are never shown publicly.")
                .font(LokaFont.body)
                .foregroundStyle(LokaColor.textSecondary)
            bulletPoint("Your real identity is never publicly visible")
            bulletPoint("Only display name and district are shown publicly")
            bulletPoint("Verification uniqueness prevents duplicate accounts")
            PrimaryButton(title: "Begin verification") { viewModel.next() }
        }
    }

    private var uploadStep: some View {
        VStack(alignment: .leading, spacing: LokaSpacing.md) {
            Text("Upload Aadhaar Offline XML")
                .font(LokaFont.headingMedium)
            Text("Download your offline XML package from the UIDAI portal and upload it here.")
                .font(LokaFont.body)
                .foregroundStyle(LokaColor.textSecondary)
            placeholderUpload
            PrimaryButton(title: "Continue") { viewModel.next() }
        }
    }

    private var shareCodeStep: some View {
        VStack(alignment: .leading, spacing: LokaSpacing.md) {
            Text("Enter share code")
                .font(LokaFont.headingMedium)
            Text("The share code is the password you set while downloading the offline XML.")
                .font(LokaFont.body)
                .foregroundStyle(LokaColor.textSecondary)
            TextField("Share code", text: $viewModel.shareCode)
                .padding(LokaSpacing.md)
                .background(LokaColor.surface)
                .clipShape(RoundedRectangle(cornerRadius: LokaCorner.md))
            if let error = viewModel.errorMessage {
                Text(error).font(LokaFont.caption).foregroundStyle(LokaColor.danger)
            }
            PrimaryButton(title: "Verify", isLoading: viewModel.isLoading) {
                viewModel.step = .processing
                Task { await viewModel.submitVerification() }
            }
        }
    }

    private var processingStep: some View {
        VStack(spacing: LokaSpacing.md) {
            ProgressView()
                .progressViewStyle(.circular)
                .tint(LokaColor.accent)
            Text("Validating your verification…")
                .font(LokaFont.body)
                .foregroundStyle(LokaColor.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(LokaSpacing.xxl)
        .task {
            if viewModel.shareCode.isEmpty {
                await viewModel.submitVerification()
            }
        }
    }

    private var districtsStep: some View {
        VStack(alignment: .leading, spacing: LokaSpacing.md) {
            Text("Select your participation districts")
                .font(LokaFont.headingMedium)
            Text("Loka enforces geographic participation. You can raise and support issues in these districts only.")
                .font(LokaFont.body)
                .foregroundStyle(LokaColor.textSecondary)
            districtPicker(title: "Home district", selection: $viewModel.homeDistrict)
            districtPicker(title: "Living-in district", selection: $viewModel.livingInDistrict)
            PrimaryButton(title: "Continue") { viewModel.step = .complete }
                .disabled(viewModel.homeDistrict == nil)
        }
    }

    private var completeStep: some View {
        VStack(spacing: LokaSpacing.lg) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 48))
                .foregroundStyle(LokaColor.civicGreen)
            Text("Verification complete")
                .font(LokaFont.headingMedium)
            Text("Welcome to Loka. You can now create and participate in civic issues.")
                .font(LokaFont.body)
                .foregroundStyle(LokaColor.textSecondary)
                .multilineTextAlignment(.center)
            PrimaryButton(title: "Done") { dismiss() }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, LokaSpacing.xl)
    }

    private func districtPicker(title: String, selection: Binding<District?>) -> some View {
        VStack(alignment: .leading, spacing: LokaSpacing.xs) {
            Text(title).font(LokaFont.bodyEmphasized)
            Picker(title, selection: selection) {
                Text("Select").tag(Optional<District>(nil))
                ForEach(LokaRegion.sampleDistricts) { Text("\($0.name), \($0.state)").tag(Optional($0)) }
            }
            .pickerStyle(.menu)
            .padding(LokaSpacing.sm)
            .background(LokaColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: LokaCorner.sm))
        }
    }

    private var placeholderUpload: some View {
        RoundedRectangle(cornerRadius: LokaCorner.md)
            .strokeBorder(LokaColor.divider, style: StrokeStyle(lineWidth: 1.5, dash: [6]))
            .frame(height: 160)
            .overlay(
                VStack(spacing: LokaSpacing.xs) {
                    Image(systemName: "arrow.up.doc").font(.system(size: 28)).foregroundStyle(LokaColor.accent)
                    Text("Tap to select XML").font(LokaFont.body).foregroundStyle(LokaColor.textSecondary)
                }
            )
    }

    private func bulletPoint(_ text: String) -> some View {
        HStack(alignment: .top, spacing: LokaSpacing.sm) {
            Image(systemName: "checkmark.circle.fill").foregroundStyle(LokaColor.civicGreen)
            Text(text).font(LokaFont.body).foregroundStyle(LokaColor.textSecondary)
        }
    }
}
