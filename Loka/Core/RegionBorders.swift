import Foundation
import CoreLocation

/// Loads the bundled Andhra Pradesh + Telangana boundary rings (dissolved from
/// district GeoJSON, simplified) used to shade the map outside the two states.
enum RegionBorders {
    /// One coordinate ring per state.
    static let rings: [[CLLocationCoordinate2D]] = load()

    private struct Payload: Decodable { let rings: [[[Double]]] }

    private static func load() -> [[CLLocationCoordinate2D]] {
        guard let url = Bundle.main.url(forResource: "RegionBorders", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let payload = try? JSONDecoder().decode(Payload.self, from: data) else {
            return []
        }
        // Each point is [latitude, longitude].
        return payload.rings.map { ring in
            ring.compactMap { p in
                p.count == 2 ? CLLocationCoordinate2D(latitude: p[0], longitude: p[1]) : nil
            }
        }
    }
}
