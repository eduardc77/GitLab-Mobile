import Foundation

public extension OAuthTokenResponse {
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
