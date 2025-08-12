import Foundation
import Security

public protocol TokenStorage: Sendable {
    func save(_ token: AuthToken) throws
    func load() throws -> AuthToken?
    func clear() throws
}

public final class KeychainTokenStorage: TokenStorage {
    private let service: String
    private let account: String

    public init(
        service: String = Bundle.main.bundleIdentifier ?? "GitLabMobile",
        account: String = "oauth_token"
    ) {
        self.service = service
        self.account = account
    }

    public func save(_ token: AuthToken) throws {
        let data = try JSONEncoder().encode(token)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data
        ]
        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            let error = NSError(domain: NSOSStatusErrorDomain, code: Int(status))
            throw NetworkError.transport(error)
        }
    }

    public func load() throws -> AuthToken? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        if status == errSecItemNotFound { return nil }
        guard status == errSecSuccess, let data = result as? Data else {
            throw NetworkError.transport(NSError(domain: NSOSStatusErrorDomain, code: Int(status)))
        }
        return try JSONDecoder().decode(AuthToken.self, from: data)
    }

    public func clear() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(query as CFDictionary)
    }
}
