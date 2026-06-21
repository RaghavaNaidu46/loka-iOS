import SwiftUI

struct FeedView: View {
    @EnvironmentObject private var session: AppSessionManager
    @EnvironmentObject private var router: AppRouter
    @StateObject private var viewModel = FeedViewModel()

    var body: some View {
        NavigationStack(path: $router.feedPath) {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: LokaSpacing.xl) {
                    locationHeader
                    section(title: "Nearby Issues", subtitle: "Issues in your district", issues: viewModel.nearby)
                    section(title: "New Issues", subtitle: "Recently submitted", issues: viewModel.fresh)
                    section(title: "Community Priority", subtitle: "Highest participation", issues: viewModel.priority)
                    section(title: "Resolved Issues", subtitle: "Outcomes from your area", issues: viewModel.resolved)
                }
                .padding(LokaSpacing.lg)
            }
            .background(LokaColor.background)
            .navigationTitle("Loka")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(for: IssueRoute.self) { route in
                switch route {
                case .detail(let id):
                    IssueDetailView(issueId: id)
                }
            }
            .task { await viewModel.load() }
            .refreshable { await viewModel.load() }
        }
    }

    private var locationHeader: some View {
        HStack {
            Image(systemName: "mappin.and.ellipse")
                .foregroundStyle(LokaColor.accent)
            Text(session.homeDistrict?.name ?? "All regions")
                .font(LokaFont.bodyEmphasized)
                .foregroundStyle(LokaColor.textPrimary)
            Spacer()
            Image(systemName: "magnifyingglass")
                .foregroundStyle(LokaColor.textSecondary)
                .onTapGesture { router.selectedTab = .search }
        }
    }

    @ViewBuilder
    private func section(title: String, subtitle: String, issues: [Issue]) -> some View {
        VStack(alignment: .leading, spacing: LokaSpacing.md) {
            SectionHeader(title: title, subtitle: subtitle)
            if issues.isEmpty {
                if viewModel.isLoading {
                    ProgressView().frame(maxWidth: .infinity).padding()
                } else {
                    EmptyStateView(
                        systemImage: "tray",
                        title: "No issues yet",
                        message: "Issues in this section will appear here as they are submitted."
                    )
                }
            } else {
                ForEach(issues) { issue in
                    NavigationLink(value: IssueRoute.detail(id: issue.id)) {
                        IssueCard(issue: issue)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

#Preview {
    FeedView()
        .environmentObject(AppSessionManager())
        .environmentObject(AppRouter())
}
