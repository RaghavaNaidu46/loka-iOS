import Foundation

/// Shared JSON coders configured for the Loka backend. Kept in one place so the
/// client, `Endpoints`, and any tests all encode/decode identically.
extension JSONDecoder {
    /// Decoder that understands the backend's `datetime.isoformat()` strings
    /// (see ``LokaDate``). Keys are decoded verbatim (backend already camelCases).
    static let loka: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let raw = try container.decode(String.self)
            if let date = LokaDate.parse(raw) {
                return date
            }
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Unsupported date format: \(raw)"
            )
        }
        return decoder
    }()
}

extension JSONEncoder {
    /// Encoder used for all request bodies. No key strategy — property names are
    /// emitted verbatim, so body structs must declare the exact JSON keys.
    static let loka: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()
}
