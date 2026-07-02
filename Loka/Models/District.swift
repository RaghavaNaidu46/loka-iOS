import Foundation
import CoreLocation

/// A geographic point.
struct Coordinate: Codable, Hashable {
    let latitude: Double
    let longitude: Double

    var clCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

struct District: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let state: String
    let country: String
    /// City-center coordinate, when known (used for the map).
    var coordinate: Coordinate? = nil
}

enum LokaRegion {
    static let supportedStates = ["Andhra Pradesh", "Telangana"]

    static let sampleDistricts: [District] = [
        District(id: "ap-vsg", name: "Visakhapatnam", state: "Andhra Pradesh", country: "India", coordinate: Coordinate(latitude: 17.6868, longitude: 83.2185)),
        District(id: "ap-vja", name: "Vijayawada", state: "Andhra Pradesh", country: "India", coordinate: Coordinate(latitude: 16.5062, longitude: 80.6480)),
        District(id: "ap-gnt", name: "Guntur", state: "Andhra Pradesh", country: "India", coordinate: Coordinate(latitude: 16.3067, longitude: 80.4365)),
        District(id: "ap-tir", name: "Tirupati", state: "Andhra Pradesh", country: "India", coordinate: Coordinate(latitude: 13.6288, longitude: 79.4192)),
        District(id: "tg-hyd", name: "Hyderabad", state: "Telangana", country: "India", coordinate: Coordinate(latitude: 17.3850, longitude: 78.4867)),
        District(id: "tg-wgl", name: "Warangal", state: "Telangana", country: "India", coordinate: Coordinate(latitude: 17.9689, longitude: 79.5941)),
        District(id: "tg-kmm", name: "Khammam", state: "Telangana", country: "India", coordinate: Coordinate(latitude: 17.2473, longitude: 80.1514))
    ]

    /// City-center coordinate for a known district id (fallback for issues that
    /// carry no explicit coordinate).
    static func coordinate(forDistrictId id: String) -> Coordinate? {
        sampleDistricts.first { $0.id == id }?.coordinate
    }

    /// A region that frames Andhra Pradesh + Telangana.
    static let mapCenter = Coordinate(latitude: 16.6, longitude: 79.9)
    static let mapSpanDegrees = 7.5
}
