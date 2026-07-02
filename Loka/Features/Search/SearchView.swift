import SwiftUI

struct SearchView: View {
    @EnvironmentObject private var router: AppRouter
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = SearchViewModel()

    var body: some View {
        NavigationStack(path: $router.searchPath) {
            VStack(spacing: LokaSpacing.md) {
                LokaTextField(
                    placeholder: "Search issues",
                    text: $viewModel.query,
                    systemImage: "magnifyingglass",
                    submitLabel: .search,
                    onSubmit: { Task { await viewModel.search() } }
                )
                .padding(.horizontal, LokaSpacing.lg)

                filters
                results
            }
            .padding(.top, LokaSpacing.sm)
            .background(LokaColor.base)
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .navigationDestination(for: IssueRoute.self) { route in
                switch route {
                case .detail(let id): IssueDetailView(issueId: id)
                }
            }
            .task { if viewModel.results.isEmpty { await viewModel.search() } }
        }
    }

    // MARK: - Filters

    private var filters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: LokaSpacing.sm) {
                Menu {
                    Button("All districts") { setDistrict(nil) }
                    ForEach(LokaRegion.sampleDistricts) { district in
                        Button(district.name) { setDistrict(district) }
                    }
                } label: {
                    FilterChipLabel(
                        title: viewModel.selectedDistrict?.name ?? "Any district",
                        systemImage: "mappin.and.ellipse",
                        isActive: viewModel.selectedDistrict != nil
                    )
                }
                Menu {
                    Button("All categories") { setCategory(nil) }
                    ForEach(IssueCategory.allCases) { category in
                        Button(category.displayName) { setCategory(category) }
                    }
                } label: {
                    FilterChipLabel(
                        title: viewModel.selectedCategory?.displayName ?? "Any category",
                        systemImage: "square.grid.2x2",
                        isActive: viewModel.selectedCategory != nil
                    )
                }
            }
            .padding(.horizontal, LokaSpacing.lg)
        }
    }

    private func setDistrict(_ district: District?) {
        Haptics.selection()
        viewModel.selectedDistrict = district
        Task { await viewModel.search() }
    }

    private func setCategory(_ category: IssueCategory?) {
        Haptics.selection()
        viewModel.selectedCategory = category
        Task { await viewModel.search() }
    }

    // MARK: - Results

    @ViewBuilder
    private var results: some View {
        if viewModel.isLoading {
            ScrollView {
                VStack(spacing: LokaSpacing.md) {
                    ForEach(0..<5, id: \.self) { _ in
                        SkeletonBlock(cornerRadius: LokaCorner.lg).frame(height: 76)
                    }
                }
                .padding(.horizontal, LokaSpacing.lg)
            }
        } else if viewModel.results.isEmpty {
            EmptyStateView(
                systemImage: "magnifyingglass",
                title: "No results",
                message: "Try a different keyword, district, or category."
            )
            Spacer()
        } else {
            ScrollView {
                LazyVStack(spacing: LokaSpacing.md) {
                    ForEach(viewModel.results) { issue in
                        NavigationLink(value: IssueRoute.detail(id: issue.id)) {
                            IssueCompactRow(issue: issue)
                        }
                        .buttonStyle(PressableButtonStyle())
                    }
                }
                .padding(.horizontal, LokaSpacing.lg)
                .padding(.bottom, LokaSize.tabBarClearance)
            }
            .scrollIndicators(.hidden)
        }
    }
}

/// Menu-triggering pill styled like a `FilterChip` but non-toggling.
private struct FilterChipLabel: View {
    let title: String
    let systemImage: String
    let isActive: Bool

    var body: some View {
        HStack(spacing: LokaSpacing.xs) {
            Image(systemName: systemImage).font(.system(size: LokaSize.iconSmall, weight: .semibold))
            Text(title).font(LokaFont.captionEmphasized)
            Image(systemName: "chevron.down").font(.system(size: 9, weight: .bold))
        }
        .foregroundStyle(isActive ? LokaColor.onBrand : LokaColor.textSecondary)
        .padding(.horizontal, LokaSpacing.md)
        .padding(.vertical, LokaSpacing.sm)
        .background {
            if isActive {
                Capsule().fill(LokaColor.brand)
            } else {
                Capsule().fill(LokaColor.surface).overlay(Capsule().strokeBorder(LokaColor.border, lineWidth: 1))
            }
        }
    }
}

#Preview {
    SearchView().environmentObject(AppRouter())
}
