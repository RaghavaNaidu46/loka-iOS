import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var session: AppSessionManager
    @EnvironmentObject private var router: AppRouter
    @State private var showSignOutConfirm = false

    private var profileName: String {
        let name = session.currentCitizen?.displayName ?? ""
        return name.isEmpty ? "Verified Citizen" : name
    }

    var body: some View {
        NavigationStack(path: $router.profilePath) {
            ScrollView {
                VStack(spacing: LokaSpacing.xl) {
                    hero
                    if session.citizenState == .verified {
                        verifiedContent
                    } else {
                        visitorContent
                    }
                    signOutButton
                }
                .padding(LokaSpacing.lg)
                .padding(.bottom, LokaSize.tabBarClearance)
            }
            .scrollIndicators(.hidden)
            .background(LokaColor.base)
            .navigationTitle("Profile")
            .navigationDestination(for: IssueRoute.self) { route in
                switch route {
                case .detail(let id): IssueDetailView(issueId: id)
                }
            }
            .alert("Sign out?", isPresented: $showSignOutConfirm) {
                Button("Cancel", role: .cancel) {}
                Button("Sign out", role: .destructive) { session.signOut() }
            }
        }
    }

    // MARK: - Hero

    private var hero: some View {
        VStack(spacing: LokaSpacing.md) {
            LokaAvatar(name: profileName, size: LokaSize.avatarLarge, isVerified: session.citizenState == .verified)
            VStack(spacing: LokaSpacing.xs) {
                Text(session.citizenState == .verified ? profileName : "Guest")
                    .font(LokaFont.headingLarge)
                    .foregroundStyle(LokaColor.textPrimary)
                HStack(spacing: LokaSpacing.xs) {
                    Image(systemName: session.citizenState == .verified ? "checkmark.seal.fill" : "person.crop.circle.badge.questionmark")
                        .foregroundStyle(session.citizenState == .verified ? LokaColor.support : LokaColor.textTertiary)
                    Text(session.citizenState == .verified ? "Verified Citizen" : "Not verified")
                        .font(LokaFont.callout)
                        .foregroundStyle(LokaColor.textSecondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, LokaSpacing.lg)
    }

    // MARK: - Verified

    private var verifiedContent: some View {
        VStack(spacing: LokaSpacing.xl) {
            HStack(spacing: LokaSpacing.md) {
                districtTile(title: "Home district", value: session.homeDistrict?.name)
                districtTile(title: "Living in", value: session.livingInDistrict?.name)
            }

            actionCard {
                actionRow(icon: "doc.plaintext.fill", tint: LokaColor.brand, title: "My issues", subtitle: "Issues you've raised")
                Divider().overlay(LokaColor.divider).padding(.leading, 56)
                actionRow(icon: "hand.raised.fill", tint: LokaColor.support, title: "My participation", subtitle: "Support & opposition history")
            }

            aboutCard
        }
    }

    // MARK: - Visitor

    private var visitorContent: some View {
        VStack(spacing: LokaSpacing.xl) {
            NavigationLink {
                BecomeCitizenView()
            } label: {
                HStack(spacing: LokaSpacing.md) {
                    ZStack {
                        Circle().fill(.white.opacity(0.2)).frame(width: 44, height: 44)
                        Image(systemName: "checkmark.seal.fill").font(.system(size: 20)).foregroundStyle(.white)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Become a Citizen")
                            .font(LokaFont.calloutEmphasized)
                            .foregroundStyle(.white)
                        Text("Verify with Aadhaar to participate")
                            .font(LokaFont.caption)
                            .foregroundStyle(.white.opacity(0.85))
                    }
                    Spacer()
                    Image(systemName: "chevron.right").foregroundStyle(.white.opacity(0.8))
                }
                .padding(LokaSpacing.lg)
                .background(LokaColor.brandGradient, in: RoundedRectangle(cornerRadius: LokaCorner.lg, style: .continuous))
                .lokaShadow(.card)
            }
            .buttonStyle(PressableButtonStyle())

            aboutCard
        }
    }

    // MARK: - Reusable pieces

    private func districtTile(title: String, value: String?) -> some View {
        VStack(alignment: .leading, spacing: LokaSpacing.xs) {
            Image(systemName: "mappin.and.ellipse")
                .font(.system(size: LokaSize.iconMedium))
                .foregroundStyle(LokaColor.brand)
            Text(value ?? "\u{2014}")
                .font(LokaFont.headingSmall)
                .foregroundStyle(LokaColor.textPrimary)
                .lineLimit(1)
            Text(title)
                .font(LokaFont.caption)
                .foregroundStyle(LokaColor.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(LokaSpacing.lg)
        .background(LokaColor.surface, in: RoundedRectangle(cornerRadius: LokaCorner.lg, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: LokaCorner.lg, style: .continuous).strokeBorder(LokaColor.border, lineWidth: 0.5))
    }

    private func actionCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 0) { content() }
            .background(LokaColor.surface, in: RoundedRectangle(cornerRadius: LokaCorner.lg, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: LokaCorner.lg, style: .continuous).strokeBorder(LokaColor.border, lineWidth: 0.5))
    }

    private func actionRow(icon: String, tint: Color, title: String, subtitle: String? = nil) -> some View {
        HStack(spacing: LokaSpacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: LokaCorner.sm, style: .continuous).fill(tint.opacity(0.14)).frame(width: 36, height: 36)
                Image(systemName: icon).font(.system(size: LokaSize.iconSmall, weight: .semibold)).foregroundStyle(tint)
            }
            VStack(alignment: .leading, spacing: 1) {
                Text(title).font(LokaFont.callout).foregroundStyle(LokaColor.textPrimary)
                if let subtitle {
                    Text(subtitle).font(LokaFont.caption).foregroundStyle(LokaColor.textSecondary)
                }
            }
            Spacer()
            Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundStyle(LokaColor.textTertiary)
        }
        .padding(LokaSpacing.md)
        .contentShape(Rectangle())
    }

    private var aboutCard: some View {
        actionCard {
            actionRow(icon: "info.circle.fill", tint: LokaColor.info, title: "About Loka")
            Divider().overlay(LokaColor.divider).padding(.leading, 56)
            actionRow(icon: "doc.text.fill", tint: LokaColor.textSecondary, title: "Policies")
            Divider().overlay(LokaColor.divider).padding(.leading, 56)
            actionRow(icon: "gearshape.fill", tint: LokaColor.textSecondary, title: "Settings")
        }
    }

    private var signOutButton: some View {
        LokaButton(title: "Sign out", systemImage: "rectangle.portrait.and.arrow.right", style: .ghost) {
            showSignOutConfirm = true
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AppSessionManager())
        .environmentObject(AppRouter())
}
