import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var session: AppSessionManager
    @EnvironmentObject private var router: AppRouter

    private var profileName: String {
        let name = session.currentCitizen?.displayName ?? ""
        return name.isEmpty ? "Verified Citizen" : name
    }

    var body: some View {
        NavigationStack(path: $router.profilePath) {
            Group {
                if session.citizenState == .verified {
                    citizenView
                } else {
                    visitorView
                }
            }
            .background(LokaColor.background)
            .navigationTitle("Profile")
            .navigationDestination(for: IssueRoute.self) { route in
                switch route {
                case .detail(let id): IssueDetailView(issueId: id)
                }
            }
        }
    }

    private var visitorView: some View {
        List {
            Section {
                NavigationLink {
                    BecomeCitizenView()
                } label: {
                    Label {
                        VStack(alignment: .leading) {
                            Text("Become a Citizen").font(LokaFont.bodyEmphasized)
                            Text("Verify with Aadhaar to participate")
                                .font(LokaFont.caption)
                                .foregroundStyle(LokaColor.textSecondary)
                        }
                    } icon: {
                        Image(systemName: "checkmark.seal").foregroundStyle(LokaColor.accent)
                    }
                }
            }
            Section("About") {
                Label("About Loka", systemImage: "info.circle")
                Label("Policies", systemImage: "doc.text")
                Label("Settings", systemImage: "gear")
            }
        }
    }

    private var citizenView: some View {
        List {
            Section {
                HStack(spacing: LokaSpacing.md) {
                    Circle()
                        .fill(LokaColor.accent.opacity(0.15))
                        .frame(width: 56, height: 56)
                        .overlay(Image(systemName: "person.fill").foregroundStyle(LokaColor.accent))
                    VStack(alignment: .leading) {
                        Text(profileName).font(LokaFont.bodyEmphasized)
                        HStack(spacing: LokaSpacing.xs) {
                            Image(systemName: "checkmark.seal.fill").foregroundStyle(LokaColor.civicGreen)
                            Text("Verified Citizen").font(LokaFont.caption).foregroundStyle(LokaColor.textSecondary)
                        }
                    }
                }
            }
            Section("Participation regions") {
                LabeledContent("Home district", value: session.homeDistrict?.name ?? "—")
                LabeledContent("Living-in district", value: session.livingInDistrict?.name ?? "—")
            }
            Section("Participation") {
                Label("My issues", systemImage: "doc.plaintext")
                Label("My participation", systemImage: "hand.raised")
            }
            Section {
                Button(role: .destructive) {
                    session.signOut()
                } label: {
                    Label("Sign out", systemImage: "rectangle.portrait.and.arrow.right")
                }
            }
        }
    }
}
