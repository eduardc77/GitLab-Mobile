import Foundation
import SwiftData
import ProjectsDomain
import GitLabLogging

/// SwiftData model for cached issues
@Model
public final class CachedIssue {
    @Attribute(.unique) public var id: Int
    public var projectId: Int
    public var number: Int
    public var title: String
    public var body: String?
    public var state: String // IssueState raw value
    public var assigneeId: Int?
    public var assigneeUsername: String?
    public var assigneeName: String?
    public var assigneeAvatarUrl: String?
    public var authorId: Int
    public var authorUsername: String
    public var authorName: String
    public var authorAvatarUrl: String?
    public var labelsData: Data? // JSON encoded labels
    public var createdAt: Date
    public var updatedAt: Date
    public var closedAt: Date?
    public var cachedAt: Date

    public init(
        id: Int,
        projectId: Int,
        number: Int,
        title: String,
        body: String?,
        state: String,
        assigneeId: Int?,
        assigneeUsername: String?,
        assigneeName: String?,
        assigneeAvatarUrl: String?,
        authorId: Int,
        authorUsername: String,
        authorName: String,
        authorAvatarUrl: String?,
        labelsData: Data?,
        createdAt: Date,
        updatedAt: Date,
        closedAt: Date?,
        cachedAt: Date = Date()
    ) {
        self.id = id
        self.projectId = projectId
        self.number = number
        self.title = title
        self.body = body
        self.state = state
        self.assigneeId = assigneeId
        self.assigneeUsername = assigneeUsername
        self.assigneeName = assigneeName
        self.assigneeAvatarUrl = assigneeAvatarUrl
        self.authorId = authorId
        self.authorUsername = authorUsername
        self.authorName = authorName
        self.authorAvatarUrl = authorAvatarUrl
        self.labelsData = labelsData
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.closedAt = closedAt
        self.cachedAt = cachedAt
    }

    public convenience init(from issue: Issue, projectId: Int, cachedAt: Date = Date()) {
        let labelsData = try? JSONEncoder().encode(issue.labels)

        self.init(
            id: issue.id,
            projectId: projectId,
            number: issue.number,
            title: issue.title,
            body: issue.body,
            state: issue.state.rawValue,
            assigneeId: issue.assignee?.id,
            assigneeUsername: issue.assignee?.username,
            assigneeName: issue.assignee?.name,
            assigneeAvatarUrl: issue.assignee?.avatarUrl?.absoluteString,
            authorId: issue.author.id,
            authorUsername: issue.author.username,
            authorName: issue.author.name,
            authorAvatarUrl: issue.author.avatarUrl?.absoluteString,
            labelsData: labelsData,
            createdAt: issue.createdAt,
            updatedAt: issue.updatedAt,
            closedAt: issue.closedAt,
            cachedAt: cachedAt
        )
    }
}

/// Cache implementation for issues
@MainActor
public final class IssuesCache: IssuesCacheProviding {
    private let modelContext: ModelContext

    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    public func saveIssues(_ issues: [Issue], for projectId: Int) throws {
        // Clear existing issues for this project
        let existingFetch = FetchDescriptor<CachedIssue>(
            predicate: #Predicate { $0.projectId == projectId }
        )
        if let existing = try? modelContext.fetch(existingFetch) {
            for cachedIssue in existing {
                modelContext.delete(cachedIssue)
            }
        }

        // Save new issues
        for issue in issues {
            let cachedIssue = CachedIssue(from: issue, projectId: projectId)
            modelContext.insert(cachedIssue)
        }

        try modelContext.save()
        AppLog.issues.debug("💾 Cached \(issues.count) issues for project \(projectId)")
    }

    public func loadIssues(for projectId: Int, limit: Int) throws -> [Issue]? {
        let fetch = FetchDescriptor<CachedIssue>(
            predicate: #Predicate { $0.projectId == projectId },
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )

        let cachedIssues = try modelContext.fetch(fetch)
        if cachedIssues.isEmpty {
            return nil
        }

        let issues = cachedIssues.prefix(limit).map { cachedIssue in
            // Convert back to Issue domain model
            let state = IssueState(rawValue: cachedIssue.state) ?? .open

            let assignee: User? = {
                guard let assigneeId = cachedIssue.assigneeId,
                      let username = cachedIssue.assigneeUsername,
                      let name = cachedIssue.assigneeName else {
                    return nil
                }
                let avatarUrl = cachedIssue.assigneeAvatarUrl.flatMap(URL.init(string:))
                return User(id: assigneeId, username: username, name: name, avatarUrl: avatarUrl)
            }()

            let authorAvatarUrl = cachedIssue.authorAvatarUrl.flatMap(URL.init(string:))
            let author = User(
                id: cachedIssue.authorId,
                username: cachedIssue.authorUsername,
                name: cachedIssue.authorName,
                avatarUrl: authorAvatarUrl
            )

            let labels: [Label] = {
                guard let labelsData = cachedIssue.labelsData else { return [] }
                return (try? JSONDecoder().decode([Label].self, from: labelsData)) ?? []
            }()

            return Issue(
                id: cachedIssue.id,
                number: cachedIssue.number,
                title: cachedIssue.title,
                body: cachedIssue.body,
                state: state,
                assignee: assignee,
                author: author,
                labels: labels,
                createdAt: cachedIssue.createdAt,
                updatedAt: cachedIssue.updatedAt,
                closedAt: cachedIssue.closedAt
            )
        }

        AppLog.issues.debug("✅ Loaded \(issues.count) cached issues for project \(projectId)")
        return Array(issues)
    }

    public func clearIssues(for projectId: Int) throws {
        let fetch = FetchDescriptor<CachedIssue>(
            predicate: #Predicate { $0.projectId == projectId }
        )

        if let issues = try? modelContext.fetch(fetch) {
            for issue in issues {
                modelContext.delete(issue)
            }
            try modelContext.save()
            AppLog.issues.debug("🗑️ Cleared cached issues for project \(projectId)")
        }
    }
}

