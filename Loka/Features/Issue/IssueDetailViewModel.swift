import Foundation

@MainActor
final class IssueDetailViewModel: ObservableObject {
    @Published var issue: Issue?
    @Published var comments: [LokaComment] = []
    @Published var related: [Issue] = []
    @Published var participation: ParticipationRecord?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let issueRepository: IssueRepository
    private let commentRepository: CommentRepository
    private let participationRepository: ParticipationRepository

    init(
        issueRepository: IssueRepository = HTTPIssueRepository(),
        commentRepository: CommentRepository = HTTPCommentRepository(),
        participationRepository: ParticipationRepository = HTTPParticipationRepository()
    ) {
        self.issueRepository = issueRepository
        self.commentRepository = commentRepository
        self.participationRepository = participationRepository
    }

    func load(id: String) async {
        isLoading = true
        errorMessage = nil
        do {
            async let detailTask = issueRepository.detail(id: id)
            async let commentsTask = commentRepository.list(issueId: id)
            async let relatedTask = issueRepository.relatedIssues(to: id)
            async let participationTask = participationRepository.status(forIssue: id)
            issue = try await detailTask
            comments = try await commentsTask
            related = try await relatedTask
            participation = try await participationTask
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func support() async {
        guard let id = issue?.id, participation == nil else { return }
        do {
            participation = try await participationRepository.support(issueId: id)
            issue?.supportCount += 1
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func oppose(explanation: String) async {
        guard let id = issue?.id, participation == nil else { return }
        do {
            participation = try await participationRepository.oppose(issueId: id, explanation: explanation)
            issue?.opposeCount += 1
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
