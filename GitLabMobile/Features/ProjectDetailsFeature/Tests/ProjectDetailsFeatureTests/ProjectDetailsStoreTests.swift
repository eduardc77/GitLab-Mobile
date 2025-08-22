import Testing
@testable import ProjectDetailsFeature
import ProjectsDomain

private actor FakeProjectsRepository: ProjectsRepository {
    var details: ProjectDetails
    init(details: ProjectDetails) { self.details = details }

    func configureLocalCache(makeCache: @escaping @Sendable @MainActor () -> ProjectsCacheProviding) async {}

    func explorePage(orderBy: ProjectSortField, sort: SortDirection, page: Int, perPage: Int, search: String?) async -> AsyncThrowingStream<RepositoryResult<RepositoryPage<[ProjectSummary]>>, Error> { .init({ $0.finish() }) }

    func personalPage(scope: PersonalProjectsScope, page: Int, perPage: Int, search: String?) async -> AsyncThrowingStream<RepositoryResult<RepositoryPage<[ProjectSummary]>>, Error> { .init({ $0.finish() }) }

    func projectDetails(id: Int) async throws -> ProjectDetails { details }
}

@Suite("Project Details · Store")
struct ProjectDetailsStoreTests {

    @Test("loads details successfully")
    func loadSuccess() async {
        // Given
        let model = ProjectDetails(
            id: 1,
            name: "GitLab",
            pathWithNamespace: "gitlab-org/gitlab",
            description: "DevOps platform",
            starCount: 1,
            forksCount: 2,
            avatarUrl: nil,
            webUrl: URL(string: "https://gitlab.com")!,
            lastActivityAt: Date(),
            defaultBranch: "main",
            visibility: "public",
            topics: ["devops", "gitlab"]
        )
        let repo = FakeProjectsRepository(details: model)
        let store = await ProjectDetailsStore(projectId: 1, repository: repo)

        // When
        await store.load()

        // Then
        #expect(store.details?.name == "GitLab")
        #expect(store.errorMessage == nil)
        #expect(store.isLoading == false)
    }
}


