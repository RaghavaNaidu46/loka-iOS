import SwiftUI

struct BecomeCitizenView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = BecomeCitizenViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: LokaSpacing.xl) {
                if showsProgress { progressBar }
                Group {
                    switch viewModel.step {
                    case .intro:      introStep
                    case .upload:     uploadStep
                    case .shareCode:  shareCodeStep
                    case .processing: processingStep
                    case .districts:  districtsStep
                    case .complete:   completeStep
                    }
                }
                .transition(.opacity)
            }
            .padding(LokaSpacing.lg)
            .padding(.bottom, LokaSpacing.xxl)
            .animation(LokaAnimation.smooth, value: viewModel.step)
        }
        .scrollIndicators(.hidden)
        .background(LokaColor.base)
        .navigationTitle("Become a Citizen")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Progress

    private var showsProgress: Bool {
        switch viewModel.step {
        case .intro, .complete: return false
        default: return true
        }
    }

    private var stepIndex: Int {
        switch viewModel.step {
        case .intro: return 0
        case .upload: return 1
        case .shareCode: return 2
        case .processing: return 3
        case .districts: return 4
        case .complete: return 5
        }
    }

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(LokaColor.surfaceElevated)
                Capsule().fill(LokaColor.brandGradient)
                    .frame(width: geo.size.width * (CGFloat(stepIndex) / 4.0))
            }
        }
        .frame(height: 6)
        .animation(LokaAnimation.smooth, value: stepIndex)
    }

    // MARK: - Steps

    private var introStep: some View {
        VStack(alignment: .leading, spacing: LokaSpacing.lg) {
            iconBadge("checkmark.shield.fill", tint: LokaColor.brand)
            stepTitle("Verify once. Participate openly.", "Loka verifies your identity privately using Aadhaar Offline XML. Your Aadhaar number and personal details are never shown publicly.")
            VStack(alignment: .leading, spacing: LokaSpacing.md) {
                bulletPoint("Your real identity is never publicly visible")
                bulletPoint("Only display name and district are shown publicly")
                bulletPoint("Verification uniqueness prevents duplicate accounts")
            }
            LokaButton(title: "Begin verification", systemImage: "arrow.right") { viewModel.next() }
        }
    }

    private var uploadStep: some View {
        VStack(alignment: .leading, spacing: LokaSpacing.lg) {
            stepTitle("Upload Aadhaar Offline XML", "Download your offline XML package from the UIDAI portal and upload it here.")
            uploadDropzone
            LokaButton(title: "Continue", style: .primary) { viewModel.next() }
        }
    }

    private var shareCodeStep: some View {
        VStack(alignment: .leading, spacing: LokaSpacing.lg) {
            stepTitle("Enter share code", "The share code is the password you set while downloading the offline XML.")
            LokaTextField(placeholder: "Share code", text: $viewModel.shareCode, systemImage: "key.fill")
            if let error = viewModel.errorMessage {
                Label(error, systemImage: "exclamationmark.circle.fill")
                    .font(LokaFont.caption).foregroundStyle(LokaColor.danger)
            }
            LokaButton(title: "Verify", isLoading: viewModel.isLoading) {
                viewModel.step = .processing
                Task { await viewModel.submitVerification() }
            }
        }
    }

    private var processingStep: some View {
        VStack(spacing: LokaSpacing.lg) {
            ProgressView().controlSize(.large).tint(LokaColor.brand)
            Text("Validating your verification\u{2026}")
                .font(LokaFont.callout)
                .foregroundStyle(LokaColor.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, LokaSpacing.xxxl)
        .task {
            if viewModel.shareCode.isEmpty {
                await viewModel.submitVerification()
            }
        }
    }

    private var districtsStep: some View {
        VStack(alignment: .leading, spacing: LokaSpacing.lg) {
            stepTitle("Select your districts", "Loka enforces geographic participation. You can raise and support issues in these districts only.")
            districtPicker(title: "Home district", selection: $viewModel.homeDistrict)
            districtPicker(title: "Living-in district", selection: $viewModel.livingInDistrict)
            LokaButton(title: "Continue") { withAnimation(LokaAnimation.smooth) { viewModel.step = .complete } }
                .opacity(viewModel.homeDistrict == nil ? 0.5 : 1)
                .disabled(viewModel.homeDistrict == nil)
        }
    }

    private var completeStep: some View {
        VStack(spacing: LokaSpacing.lg) {
            iconBadge("checkmark.seal.fill", tint: LokaColor.support, large: true)
            stepTitle("Verification complete", "Welcome to Loka. You can now create and participate in civic issues.", centered: true)
            LokaButton(title: "Done") { Haptics.success(); dismiss() }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, LokaSpacing.xl)
        .onAppear { Haptics.success() }
    }

    // MARK: - Pieces

    private func iconBadge(_ systemImage: String, tint: Color, large: Bool = false) -> some View {
        ZStack {
            Circle().fill(tint.opacity(0.14)).frame(width: large ? 96 : 72, height: large ? 96 : 72)
            Image(systemName: systemImage)
                .font(.system(size: large ? 44 : 32, weight: .semibold))
                .foregroundStyle(tint)
        }
    }

    private func stepTitle(_ title: String, _ subtitle: String, centered: Bool = false) -> some View {
        VStack(alignment: centered ? .center : .leading, spacing: LokaSpacing.xs) {
            Text(title)
                .font(LokaFont.headingLarge)
                .foregroundStyle(LokaColor.textPrimary)
            Text(subtitle)
                .font(LokaFont.callout)
                .foregroundStyle(LokaColor.textSecondary)
                .multilineTextAlignment(centered ? .center : .leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: centered ? .center : .leading)
    }

    private func districtPicker(title: String, selection: Binding<District?>) -> some View {
        VStack(alignment: .leading, spacing: LokaSpacing.xs) {
            Text(title).font(LokaFont.captionEmphasized).foregroundStyle(LokaColor.textPrimary)
            Menu {
                Button("Select") { selection.wrappedValue = nil }
                ForEach(LokaRegion.sampleDistricts) { district in
                    Button("\(district.name), \(district.state)") { selection.wrappedValue = district }
                }
            } label: {
                HStack {
                    Text(selection.wrappedValue?.name ?? "Select")
                        .font(LokaFont.body)
                        .foregroundStyle(selection.wrappedValue == nil ? LokaColor.textTertiary : LokaColor.textPrimary)
                    Spacer()
                    Image(systemName: "chevron.up.chevron.down").font(.system(size: 12)).foregroundStyle(LokaColor.textTertiary)
                }
                .padding(.horizontal, LokaSpacing.md)
                .frame(height: LokaSize.controlHeight)
                .background(LokaColor.surface, in: RoundedRectangle(cornerRadius: LokaCorner.md, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: LokaCorner.md, style: .continuous).strokeBorder(LokaColor.border, lineWidth: 1))
            }
        }
    }

    private var uploadDropzone: some View {
        RoundedRectangle(cornerRadius: LokaCorner.lg, style: .continuous)
            .strokeBorder(LokaColor.brand.opacity(0.5), style: StrokeStyle(lineWidth: 1.5, dash: [7]))
            .frame(height: 170)
            .background(LokaColor.brandSoft, in: RoundedRectangle(cornerRadius: LokaCorner.lg, style: .continuous))
            .overlay(
                VStack(spacing: LokaSpacing.sm) {
                    Image(systemName: "arrow.up.doc.fill").font(.system(size: 32)).foregroundStyle(LokaColor.brand)
                    Text("Tap to select XML").font(LokaFont.calloutEmphasized).foregroundStyle(LokaColor.textPrimary)
                    Text("UIDAI offline eKYC package").font(LokaFont.caption).foregroundStyle(LokaColor.textSecondary)
                }
            )
    }

    private func bulletPoint(_ text: String) -> some View {
        HStack(alignment: .top, spacing: LokaSpacing.sm) {
            Image(systemName: "checkmark.circle.fill").foregroundStyle(LokaColor.support)
            Text(text).font(LokaFont.callout).foregroundStyle(LokaColor.textSecondary)
            Spacer(minLength: 0)
        }
    }
}
