import Foundation

@MainActor
final class SearchViewModel: ObservableObject {
    @Published var query: String = ""
    @Published var selectedDistrict: District?
    @Published var selectedCategory: IssueCategory?
    @Published var results: [Issue] = []
    @Published var isLoading = false

    private let repository: IssueRepository

    init(repository: IssueRepository = HTTPIssueRepository()) {
        self.repository = repository
    }

    func search() async {
        isLoading = true
        do {
            results = try await repository.search(
                query: query,
                district: selectedDistrict,
                category: selectedCategory
            )
        } catch {
            results = []
        }
        isLoading = false
    }
}
