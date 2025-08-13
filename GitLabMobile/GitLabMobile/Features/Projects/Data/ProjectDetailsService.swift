import Foundation

public protocol ProjectDetailsServiceProtocol: Sendable {
    func getProject(id: Int) async throws -> ProjectDTO
}

public struct ProjectDetailsService: ProjectDetailsServiceProtocol {
    private let api: APIClient

    public init(api: APIClient) { self.api = api }

    public func getProject(id: Int) async throws -> ProjectDTO {
        try await api.send(ProjectsAPI.project(id: id))
    }
}
