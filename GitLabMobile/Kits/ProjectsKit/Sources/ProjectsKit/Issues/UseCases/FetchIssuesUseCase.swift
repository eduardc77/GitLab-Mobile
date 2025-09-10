import Foundation

/// Use case for fetching issues
public final class FetchIssuesUseCase {
    private let repository: IssueRepository

    public init(repository: IssueRepository) {
        self.repository = repository
    }

    /// Execute the use case to fetch issues for a project
    public func execute(projectId: Int) async throws -> [Issue] {
        // Validate input
        guard projectId > 0 else {
            throw IssuesError.invalidProjectId
        }

        // Fetch from repository
        let issues = try await repository.issues(for: projectId)

        // Apply any business rules (filtering, sorting, etc.)
        return issues.sorted { $0.updatedAt > $1.updatedAt }
    }

    /// Fetch a specific issue
    public func execute(issueId: Int, projectId: Int) async throws -> Issue {
        guard projectId > 0 else {
            throw IssuesError.invalidProjectId
        }

        guard issueId > 0 else {
            throw IssuesError.invalidIssueId
        }

        return try await repository.issue(id: issueId, in: projectId)
    }
}

/// Domain errors for issues
public enum IssuesError: Error, LocalizedError {
    case invalidProjectId
    case invalidIssueId
    case issueNotFound
    case permissionDenied
    case networkError(Error)

    public var errorDescription: String? {
        switch self {
        case .invalidProjectId:
            return "Invalid project ID"
        case .invalidIssueId:
            return "Invalid issue ID"
        case .issueNotFound:
            return "Issue not found"
        case .permissionDenied:
            return "Permission denied"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}

