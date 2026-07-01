import Foundation

struct VerificationResult {
    let verificationId: String
    let isValid: Bool
}

protocol VerificationService {
    func submitAadhaarXML(data: Data, shareCode: String) async throws -> VerificationResult
}

final class HTTPVerificationService: VerificationService {
    private let client: any APIClient

    init(client: any APIClient = ServiceLocator.shared.client) {
        self.client = client
    }

    func submitAadhaarXML(data: Data, shareCode: String) async throws -> VerificationResult {
        _ = try await client.send(
            Endpoints.uploadVerificationXML(data: data, shareCode: shareCode),
            decode: MessageResponseDTO.self
        )
        return VerificationResult(verificationId: UUID().uuidString, isValid: true)
    }
}

final class MockVerificationService: VerificationService {
    private let uploadManager: UploadManager

    init(uploadManager: UploadManager = MockUploadManager()) {
        self.uploadManager = uploadManager
    }

    func submitAadhaarXML(data: Data, shareCode: String) async throws -> VerificationResult {
        let id = try await uploadManager.uploadAadhaarXML(data: data, shareCode: shareCode)
        return VerificationResult(verificationId: id, isValid: true)
    }
}
