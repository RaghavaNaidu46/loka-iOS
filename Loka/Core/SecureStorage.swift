import Foundation
import Security

protocol SecureStorage {
    var accessToken: String? { get }
    var refreshToken: String? { get }
    func saveAccessToken(_ token: String)
    func saveRefreshToken(_ token: String)
    func clear()
}

final class KeychainSecureStorage: SecureStorage {
    private let service = "com.loka.app.session"
    private let accessTokenKey = "accessToken"
    private let refreshTokenKey = "refreshToken"

    var accessToken: String? {
        read(key: accessTokenKey)
    }

    var refreshToken: String? {
        read(key: refreshTokenKey)
    }

    func saveAccessToken(_ token: String) {
        write(key: accessTokenKey, value: token)
    }

    func saveRefreshToken(_ token: String) {
        write(key: refreshTokenKey, value: token)
    }

    func clear() {
        delete(key: accessTokenKey)
        delete(key: refreshTokenKey)
    }

    private func read(key: String) -> String? {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess, let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    private func write(key: String, value: String) {
        let data = Data(value.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
        var attributes = query
        attributes[kSecValueData as String] = data
        SecItemAdd(attributes as CFDictionary, nil)
    }

    private func delete(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }
}
