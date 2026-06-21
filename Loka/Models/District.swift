import Foundation

struct District: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let state: String
    let country: String
}

enum LokaRegion {
    static let supportedStates = ["Andhra Pradesh", "Telangana"]

    static let sampleDistricts: [District] = [
        District(id: "ap-vsg", name: "Visakhapatnam", state: "Andhra Pradesh", country: "India"),
        District(id: "ap-vja", name: "Vijayawada", state: "Andhra Pradesh", country: "India"),
        District(id: "ap-gnt", name: "Guntur", state: "Andhra Pradesh", country: "India"),
        District(id: "ap-tir", name: "Tirupati", state: "Andhra Pradesh", country: "India"),
        District(id: "tg-hyd", name: "Hyderabad", state: "Telangana", country: "India"),
        District(id: "tg-wgl", name: "Warangal", state: "Telangana", country: "India"),
        District(id: "tg-kmm", name: "Khammam", state: "Telangana", country: "India")
    ]
}
