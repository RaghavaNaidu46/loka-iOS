#if DEBUG
import SwiftUI

/// Debug-only preferences. Compiled only into Debug builds — release builds
/// contain no reference to this or the sample data it gates.
final class DebugSettings: ObservableObject {
    static let shared = DebugSettings()

    private static let sampleDataKey = "loka.debug.useSampleData"

    /// When on, the feed / issue detail serve `SampleFeed` instead of the backend.
    @Published var useSampleData: Bool {
        didSet { UserDefaults.standard.set(useSampleData, forKey: Self.sampleDataKey) }
    }

    private init() {
        useSampleData = UserDefaults.standard.bool(forKey: Self.sampleDataKey)
    }
}
#endif
