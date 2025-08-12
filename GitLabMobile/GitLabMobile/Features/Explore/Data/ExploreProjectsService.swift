import Foundation

public protocol ExploreProjectsServiceProtocol: Sendable {
    func getTrending(page: Int, perPage: Int) async throws -> [ProjectSummary]
    func getMostStarred(page: Int, perPage: Int) async throws -> [ProjectSummary]
    func search(_ query: String, page: Int, perPage: Int) async throws -> [ProjectSummary]
}

public struct ExploreProjectsService: ExploreProjectsServiceProtocol, Sendable {
    private let api: APIClient

    public init(api: APIClient) { self.api = api }

    public func getTrending(page: Int = 1, perPage: Int = 20) async throws -> [ProjectSummary] {
        try await api.send(ProjectsAPI.trending(page: page, perPage: perPage))
    }

    public func getMostStarred(page: Int = 1, perPage: Int = 20) async throws -> [ProjectSummary] {
        try await api.send(ProjectsAPI.mostStarred(page: page, perPage: perPage))
    }

    public func search(_ query: String, page: Int = 1, perPage: Int = 20) async throws -> [ProjectSummary] {
        try await api.send(ProjectsAPI.search(query, page: page, perPage: perPage))
    }
}
