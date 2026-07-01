import Foundation

/// Parses the variety of ISO-8601 strings the backend emits via `datetime.isoformat()`.
///
/// Python's `isoformat()` produces 6-digit microseconds (e.g. `…:14.776435+00:00`),
/// which `ISO8601DateFormatter` cannot parse — so we use explicit `DateFormatter`s
/// covering microseconds/no-fraction × offset/naive.
enum LokaDate {
    private static func formatter(_ format: String) -> DateFormatter {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone(identifier: "UTC")
        f.dateFormat = format
        return f
    }

    // Order matters: most specific (fractional + offset) first.
    private static let formatters: [DateFormatter] = [
        formatter("yyyy-MM-dd'T'HH:mm:ss.SSSSSSXXXXX"), // 2026-06-21T11:26:14.776435+00:00
        formatter("yyyy-MM-dd'T'HH:mm:ssXXXXX"),        // 2026-06-21T11:26:14+00:00
        formatter("yyyy-MM-dd'T'HH:mm:ss.SSSSSS"),      // 2026-06-21T16:56:14.776610 (naive)
        formatter("yyyy-MM-dd'T'HH:mm:ss"),             // 2026-06-21T16:56:14 (naive)
    ]

    static func parse(_ string: String) -> Date? {
        for formatter in formatters {
            if let date = formatter.date(from: string) {
                return date
            }
        }
        return nil
    }
}
