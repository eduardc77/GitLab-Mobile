import Foundation
import ProjectsDomain
import GitLabNetwork
import GitLabLogging

/// Implementation of IssuesRepository with separated cache
public actor IssuesRepository: IssuesRepository {
    private let networkClient: APIClient
    private var cache: IssuesCacheProviding?

    public init(networkClient: APIClient) {
        self.networkClient = networkClient
    }

    public func configureLocalCache(makeCache: @escaping @Sendable @MainActor () -> IssuesCacheProviding) async {
        let cacheInstance = await makeCache()
        self.cache = cacheInstance
    }

    public func issues(for projectId: Int, page: Int = 1, perPage: Int = 20) async throws -> [Issue] {
        // Try cache first
        if let cachedIssues = try await loadCachedIssues(for: projectId) {
            AppLog.issues.debug("✅ Loaded \(cachedIssues.count) issues from cache for project \(projectId)")
            return cachedIssues
        }

        // Fetch from network
        AppLog.issues.debug("🌐 Fetching issues from network for project \(projectId)")
        let issues = try await fetchIssuesFromNetwork(projectId: projectId, page: page, perPage: perPage)

        // Cache the results
        await cacheIssues(issues, for: projectId)

        return issues
    }

    public func issue(id: Int, in projectId: Int) async throws -> Issue {
        // Try to find in cache first
        if let cachedIssues = try await loadCachedIssues(for: projectId),
           let cachedIssue = cachedIssues.first(where: { $0.id == id }) {
            AppLog.issues.debug("✅ Loaded issue \(id) from cache")
            return cachedIssue
        }

        // Fetch from network
        AppLog.issues.debug("🌐 Fetching issue \(id) from network")
        return try await fetchIssueFromNetwork(id: id, projectId: projectId)
    }

    public func createIssue(_ request: IssueCreateRequest, in projectId: Int) async throws -> Issue {
        AppLog.issues.debug("📝 Creating new issue in project \(projectId)")

        // This would use GitLab API to create the issue
        // For now, return a mock implementation
        throw IssuesRepositoryError.notImplemented("Issue creation not yet implemented")
    }

    public func updateIssue(id: Int, with request: IssueUpdateRequest, in projectId: Int) async throws -> Issue {
        AppLog.issues.debug("📝 Updating issue \(id) in project \(projectId)")

        // This would use GitLab API to update the issue
        // For now, return a mock implementation
        throw IssuesRepositoryError.notImplemented("Issue update not yet implemented")
    }

    public func closeIssue(id: Int, in projectId: Int) async throws -> Issue {
        AppLog.issues.debug("🔒 Closing issue \(id) in project \(projectId)")

        let updateRequest = IssueUpdateRequest(state: .closed)
        return try await updateIssue(id: id, with: updateRequest, in: projectId)
    }

    public func reopenIssue(id: Int, in projectId: Int) async throws -> Issue {
        AppLog.issues.debug("🔓 Reopening issue \(id) in project \(projectId)")

        let updateRequest = IssueUpdateRequest(state: .reopened)
        return try await updateIssue(id: id, with: updateRequest, in: projectId)
    }

    // MARK: - Private Helpers

    private func loadCachedIssues(for projectId: Int) async throws -> [Issue]? {
        guard let cache = cache else { return nil }
        return try await MainActor.run {
            try cache.loadIssues(for: projectId, limit: 50)
        }
    }

    private func cacheIssues(_ issues: [Issue], for projectId: Int) async {
        guard let cache = cache else { return }
        await MainActor.run {
            try? cache.saveIssues(issues, for: projectId)
        }
    }

    private func fetchIssuesFromNetwork(projectId: Int, page: Int, perPage: Int) async throws -> [Issue] {
        // This would use GitLab API endpoints
        // For now, return mock data
        AppLog.issues.warning("⚠️ Using mock data for issues - GitLab API integration needed")

        // Mock implementation - replace with actual API calls
        return [
            Issue(
                id: 1,
                number: 1,
                title: "Sample Issue",
                body: "This is a sample issue for testing",
                state: .open,
                assignee: nil,
                author: User(id: 1, username: "testuser", name: "Test User", avatarUrl: nil),
                labels: [],
                createdAt: Date(),
                updatedAt: Date(),
                closedAt: nil
            ),
        ]
    }

    private func fetchIssueFromNetwork(id: Int, projectId: Int) async throws -> Issue {
        // This would use GitLab API to fetch single issue
        // For now, throw not implemented
        throw IssuesRepositoryError.notImplemented("Single issue fetch not yet implemented")
    }
}

/// Errors for the issues repository
public enum IssuesRepositoryError: Error, LocalizedError {
    case notImplemented(String)
    case networkError(Error)
    case cacheError(Error)
    case invalidData

    public var errorDescription: String? {
        switch self {
        case .notImplemented(let message):
            return "Not implemented: \(message)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .cacheError(let error):
            return "Cache error: \(error.localizedDescription)"
        case .invalidData:
            return "Invalid data received"
        }
    }
}
