import Foundation

public protocol AuthProviding: Sendable {
    /// Return full Authorization header value, e.g. "Bearer <token>"
    func authorizationHeader() async -> String?
}
