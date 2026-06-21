import Foundation

struct VerificationResult {
    let verificationId: String
    let isValid: Bool
}

protocol VerificationService {
    func submitAadhaarXML(data: Data, shareCode: String) async throws -> VerificationResult
}

final class HTTPVerificationService: VerificationService {
    private let client: APIClient

    init(client: APIClient = ServiceLocator.shared.client) {
        self.client = client
    }

    func submitAadhaarXML(data: Data, shareCode: String) async throws -> VerificationResult {
        let file = MultipartFile(
            field: "xmlFile",
            filename: "aadhaar.xml",
            mimeType: "application/xml",
            data: data
        )
        _ = try await client.upload(
            "verification/upload-xml",
            fields: ["shareCode": shareCode],
            files: [file],
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
