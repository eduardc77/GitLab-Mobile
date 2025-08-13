import Foundation

public struct ProjectDTO: Decodable, Sendable, Equatable {
    public let id: Int
    public let name: String
    public let pathWithNamespace: String
    public let description: String?
    public let starCount: Int?
    public let forksCount: Int?
    public let avatarUrl: String?
    public let webUrl: String
    public let lastActivityAt: Date?
}

public extension ProjectDTO {
    func toDomain() -> ProjectSummary {
        ProjectSummary(
            id: id,
            name: name,
            pathWithNamespace: pathWithNamespace,
            description: description,
            starCount: starCount ?? 0,
            forksCount: forksCount ?? 0,
            avatarUrl: avatarUrl.flatMap(URL.init),
            webUrl: URL(string: webUrl) ?? URL(string: "https://gitlab.com") ?? URL(fileURLWithPath: "/"),
            lastActivityAt: lastActivityAt
        )
    }
}
