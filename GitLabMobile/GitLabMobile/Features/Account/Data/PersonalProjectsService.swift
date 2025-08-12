import Foundation

public protocol PersonalProjectsServiceProtocol: Sendable {
    func owned(page: Int, perPage: Int) async throws -> [ProjectSummary]
    func starred(page: Int, perPage: Int) async throws -> [ProjectSummary]
    func membership(page: Int, perPage: Int) async throws -> [ProjectSummary]
}

public struct PersonalProjectsService: PersonalProjectsServiceProtocol, Sendable {
    private let api: APIClient

    public init(api: APIClient) { self.api = api }

    public func owned(page: Int = 1, perPage: Int = 20) async throws -> [ProjectSummary] {
        try await api.send(ProjectsAPI.owned(page: page, perPage: perPage))
    }

    public func starred(page: Int = 1, perPage: Int = 20) async throws -> [ProjectSummary] {
        try await api.send(ProjectsAPI.starred(page: page, perPage: perPage))
    }

    public func membership(page: Int = 1, perPage: Int = 20) async throws -> [ProjectSummary] {
        try await api.send(ProjectsAPI.membership(page: page, perPage: perPage))
    }
}
