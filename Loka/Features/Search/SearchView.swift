import SwiftUI

struct SearchView: View {
    @EnvironmentObject private var router: AppRouter
    @StateObject private var viewModel = SearchViewModel()

    var body: some View {
        NavigationStack(path: $router.searchPath) {
            VStack(spacing: LokaSpacing.md) {
                searchBar
                filters
                Divider().padding(.horizontal, LokaSpacing.lg)
                resultsList
            }
            .padding(.top, LokaSpacing.md)
            .background(LokaColor.background)
            .navigationTitle("Search")
            .navigationDestination(for: IssueRoute.self) { route in
                switch route {
                case .detail(let id):
                    IssueDetailView(issueId: id)
                }
            }
            .task { await viewModel.search() }
        }
    }

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(LokaColor.textSecondary)
            TextField("Search issues", text: $viewModel.query)
                .textInputAutocapitalization(.never)
                .submitLabel(.search)
                .onSubmit { Task { await viewModel.search() } }
        }
        .padding(LokaSpacing.md)
        .background(LokaColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: LokaCorner.md))
        .padding(.horizontal, LokaSpacing.lg)
    }

    private var filters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: LokaSpacing.sm) {
                Menu {
                    Button("All districts") { viewModel.selectedDistrict = nil; Task { await viewModel.search() } }
                    ForEach(LokaRegion.sampleDistricts) { district in
                        Button(district.name) {
                            viewModel.selectedDistrict = district
                            Task { await viewModel.search() }
                        }
                    }
                } label: {
                    chip(label: viewModel.selectedDistrict?.name ?? "Any district", systemImage: "mappin.and.ellipse")
                }
                Menu {
                    Button("All categories") { viewModel.selectedCategory = nil; Task { await viewModel.search() } }
                    ForEach(IssueCategory.allCases) { category in
                        Button(category.displayName) {
                            viewModel.selectedCategory = category
                            Task { await viewModel.search() }
                        }
                    }
                } label: {
                    chip(label: viewModel.selectedCategory?.displayName ?? "Any category", systemImage: "square.grid.2x2")
                }
            }
            .padding(.horizontal, LokaSpacing.lg)
        }
    }

    private func chip(label: String, systemImage: String) -> some View {
        HStack(spacing: LokaSpacing.xs) {
            Image(systemName: systemImage)
            Text(label)
        }
        .font(LokaFont.caption)
        .foregroundStyle(LokaColor.textPrimary)
        .padding(.horizontal, LokaSpacing.md)
        .padding(.vertical, LokaSpacing.sm)
        .background(LokaColor.surface)
        .clipShape(Capsule())
    }

    @ViewBuilder
    private var resultsList: some View {
        if viewModel.isLoading {
            ProgressView().padding()
            Spacer()
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
                            IssueCard(issue: issue)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(LokaSpacing.lg)
            }
        }
    }
}
