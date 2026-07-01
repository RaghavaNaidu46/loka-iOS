import Foundation

@MainActor
final class BecomeCitizenViewModel: ObservableObject {
    enum Step: Int, CaseIterable { case intro, upload, shareCode, processing, districts, complete }

    @Published var step: Step = .intro
    @Published var shareCode: String = "" { didSet { shareCodeError = nil } }
    @Published var homeDistrict: District?
    @Published var livingInDistrict: District?
    @Published var isLoading = false
    @Published var shareCodeError: String?
    @Published var errorMessage: String?

    private let service: VerificationService

    init(service: VerificationService = HTTPVerificationService()) {
        self.service = service
    }

    func next() {
        if let next = Step(rawValue: step.rawValue + 1) {
            step = next
        }
    }

    /// Validate the share code, then run verification. On failure, return to the
    /// share-code step so the error is visible (instead of a stuck spinner).
    func startVerification() async {
        guard !shareCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            shareCodeError = "Enter your share code"
            return
        }
        step = .processing
        await submitVerification()
        if errorMessage != nil { step = .shareCode }
    }

    func submitVerification() async {
        isLoading = true
        errorMessage = nil
        do {
            let mockData = Data("<mock-xml/>".utf8)
            let result = try await service.submitAadhaarXML(data: mockData, shareCode: shareCode)
            if result.isValid {
                step = .districts
            } else {
                errorMessage = "Verification could not be completed. Please try again."
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
