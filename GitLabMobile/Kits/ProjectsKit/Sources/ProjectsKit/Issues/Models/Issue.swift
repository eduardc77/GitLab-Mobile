import Foundation

/// Represents an issue in the GitLab system
public struct Issue: Identifiable, Sendable {
    public let id: Int
    public let number: Int
    public let title: String
    public let body: String?
    public let state: IssueState
    public let assignee: User?
    public let author: User
    public let labels: [Label]
    public let createdAt: Date
    public let updatedAt: Date
    public let closedAt: Date?

    public init(
        id: Int,
        number: Int,
        title: String,
        body: String?,
        state: IssueState,
        assignee: User?,
        author: User,
        labels: [Label],
        createdAt: Date,
        updatedAt: Date,
        closedAt: Date?
    ) {
        self.id = id
        self.number = number
        self.title = title
        self.body = body
        self.state = state
        self.assignee = assignee
        self.author = author
        self.labels = labels
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.closedAt = closedAt
    }
}

public enum IssueState: String, Sendable {
    case open
    case closed
    case reopened
}

/// Represents a user in the GitLab system
public struct User: Identifiable, Sendable {
    public let id: Int
    public let username: String
    public let name: String
    public let avatarUrl: URL?

    public init(id: Int, username: String, name: String, avatarUrl: URL?) {
        self.id = id
        self.username = username
        self.name = name
        self.avatarUrl = avatarUrl
    }
}

/// Represents a label/tag on an issue
public struct Label: Identifiable, Sendable {
    public let id: Int
    public let name: String
    public let color: String

    public init(id: Int, name: String, color: String) {
        self.id = id
        self.name = name
        self.color = color
    }
}

