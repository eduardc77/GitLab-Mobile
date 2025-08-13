import Foundation

public struct OAuthTokenDTO: Codable, Sendable {
    public let accessToken: String
    public let tokenType: String
    public let refreshToken: String?
    public let expiresIn: Int?
    public let createdAt: TimeInterval?
    public let scope: String?

    func toDomain() -> AuthToken {
        AuthToken(
            accessToken: accessToken,
            tokenType: tokenType,
            refreshToken: refreshToken,
            expiresIn: expiresIn,
            createdAt: createdAt,
            scope: scope
        )
    }
}
