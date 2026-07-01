import SwiftUI

struct FeedView: View {
    @EnvironmentObject private var session: AppSessionManager
    @EnvironmentObject private var router: AppRouter
    @StateObject private var viewModel = FeedViewModel()
    @State private var filter: FeedFilter = .all

    var body: some View {
        NavigationStack(path: $router.feedPath) {
            VStack(spacing: 0) {
                header
                filterBar
                feed
            }
            .background(LokaColor.base)
            .navigationBarHidden(true)
            .navigationDestination(for: IssueRoute.self) { route in
                switch route {
                case .detail(let id): IssueDetailView(issueId: id)
                }
            }
            .task { if viewModel.nearby.isEmpty { await viewModel.load() } }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .center, spacing: LokaSpacing.md) {
            BrandMark(size: 40, onGradient: false)
            VStack(alignment: .leading, spacing: 1) {
                Text("Loka")
                    .font(LokaFont.headingMedium)
                    .foregroundStyle(LokaColor.textPrimary)
                HStack(spacing: 3) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 10))
                    Text(session.homeDistrict?.name ?? "All regions")
                }
                .font(LokaFont.caption)
                .foregroundStyle(LokaColor.textSecondary)
            }
            Spacer()
            circleButton(icon: "magnifyingglass") {
                Haptics.selection(); router.selectedTab = .search
            }
        }
        .padding(.horizontal, LokaSpacing.lg)
        .padding(.bottom, LokaSpacing.sm)
    }

    private func circleButton(icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: LokaSize.iconMedium, weight: .semibold))
                .foregroundStyle(LokaColor.textPrimary)
                .frame(width: 40, height: 40)
                .background(LokaColor.surface, in: Circle())
                .overlay(Circle().strokeBorder(LokaColor.border, lineWidth: 0.5))
        }
        .buttonStyle(PressableButtonStyle(scale: 0.9))
    }

    // MARK: - Filters

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: LokaSpacing.sm) {
                ForEach(FeedFilter.allCases) { item in
                    FilterChip(
                        title: item.title,
                        systemImage: item.systemImage,
                        isSelected: filter == item
                    ) {
                        withAnimation(LokaAnimation.snappy) { filter = item }
                    }
                }
            }
            .padding(.horizontal, LokaSpacing.lg)
            .padding(.vertical, LokaSpacing.sm)
        }
    }

    // MARK: - Feed

    private var feed: some View {
        ScrollView {
            LazyVStack(spacing: LokaSpacing.lg) {
                if viewModel.isLoading && viewModel.nearby.isEmpty {
                    ForEach(0..<4, id: \.self) { _ in IssueCardSkeleton() }
                } else {
                    let issues = viewModel.issues(for: filter)
                    if issues.isEmpty {
                        EmptyStateView(
                            systemImage: filter.systemImage,
                            title: "Nothing here yet",
                            message: "Issues in this section will appear as citizens raise them.",
                            actionTitle: "Raise an issue"
                        ) { router.selectedTab = .create }
                        .padding(.top, LokaSpacing.xxl)
                    } else {
                        ForEach(issues) { issue in
                            NavigationLink(value: IssueRoute.detail(id: issue.id)) {
                                IssueFeedCard(issue: issue)
                            }
                            .buttonStyle(PressableButtonStyle())
                        }
                    }
                }
            }
            .padding(.horizontal, LokaSpacing.lg)
            .padding(.top, LokaSpacing.xs)
            .padding(.bottom, LokaSize.tabBarClearance)
            .animation(LokaAnimation.smooth, value: viewModel.isLoading)
        }
        .scrollIndicators(.hidden)
        .refreshable { await viewModel.load() }
    }
}

#Preview {
    FeedView()
        .environmentObject(AppSessionManager())
        .environmentObject(AppRouter())
}
