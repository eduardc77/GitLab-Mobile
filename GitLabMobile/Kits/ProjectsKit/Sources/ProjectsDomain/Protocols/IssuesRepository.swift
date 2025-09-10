import Foundation

/// Repository protocol for issue operations
public protocol IssuesRepository: Sendable {
    /// Fetch issues for a specific project
    func issues(for projectId: Int, page: Int, perPage: Int) async throws -> [Issue]

    /// Fetch a specific issue
    func issue(id: Int, in projectId: Int) async throws -> Issue

    /// Create a new issue
    func createIssue(_ request: IssueCreateRequest, in projectId: Int) async throws -> Issue

    /// Update an existing issue
    func updateIssue(id: Int, with request: IssueUpdateRequest, in projectId: Int) async throws -> Issue

    /// Close an issue
    func closeIssue(id: Int, in projectId: Int) async throws -> Issue

    /// Reopen an issue
    func reopenIssue(id: Int, in projectId: Int) async throws -> Issue

    /// Configure local cache for this repository
    func configureLocalCache(makeCache: @escaping @Sendable @MainActor () -> IssuesCacheProviding) async
}

/// Request structure for creating issues
public struct IssueCreateRequest: Sendable {
    public let title: String
    public let description: String?
    public let assigneeId: Int?
    public let labels: [String]

    public init(
        title: String,
        description: String? = nil,
        assigneeId: Int? = nil,
        labels: [String] = []
    ) {
        self.title = title
        self.description = description
        self.assigneeId = assigneeId
        self.labels = labels
    }
}

/// Request structure for updating issues
public struct IssueUpdateRequest: Sendable {
    public let title: String?
    public let description: String?
    public let assigneeId: Int?
    public let labels: [String]?
    public let state: IssueState?

    public init(
        title: String? = nil,
        description: String? = nil,
        assigneeId: Int? = nil,
        labels: [String]? = nil,
        state: IssueState? = nil
    ) {
        self.title = title
        self.description = description
        self.assigneeId = assigneeId
        self.labels = labels
        self.state = state
    }
}

/// Cache protocol for issues
public protocol IssuesCacheProviding: Sendable {
    @MainActor func saveIssues(_ issues: [Issue], for projectId: Int) throws
    @MainActor func loadIssues(for projectId: Int, limit: Int) throws -> [Issue]?
    @MainActor func clearIssues(for projectId: Int) throws
}

