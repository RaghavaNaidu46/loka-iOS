import Foundation

protocol UploadManager {
    func uploadEvidence(data: Data, filename: String) async throws -> URL
    func uploadAadhaarXML(data: Data, shareCode: String) async throws -> String
}

final class MockUploadManager: UploadManager {
    func uploadEvidence(data: Data, filename: String) async throws -> URL {
        try await Task.sleep(nanoseconds: 300_000_000)
        return URL(string: "https://media.locavoice.in/mock/\(filename)")!
    }

    func uploadAadhaarXML(data: Data, shareCode: String) async throws -> String {
        try await Task.sleep(nanoseconds: 600_000_000)
        return UUID().uuidString
    }
}
