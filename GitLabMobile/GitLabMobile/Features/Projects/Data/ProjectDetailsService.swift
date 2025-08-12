import Foundation

public protocol ProjectDetailsServiceProtocol: Sendable {
    func getProject(id: Int) async throws -> ProjectSummary
}

public struct ProjectDetailsService: ProjectDetailsServiceProtocol, Sendable {
    private let api: APIClient

    public init(api: APIClient) { self.api = api }

    public func getProject(id: Int) async throws -> ProjectSummary {
        try await api.send(ProjectsAPI.project(id: id))
    }
}
