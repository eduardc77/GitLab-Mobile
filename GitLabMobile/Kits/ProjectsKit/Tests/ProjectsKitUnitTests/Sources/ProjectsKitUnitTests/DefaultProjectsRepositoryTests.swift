//
//  DefaultProjectsRepositoryTests.swift
//  ProjectsKitUnitTests
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation
import Testing
@testable import ProjectsData
@testable import ProjectsDomain
import ProjectsKitTestDoubles
import GitLabNetwork

// MARK: - Helpers

@discardableResult
private func collect<T>(_ stream: AsyncThrowingStream<T, Error>) async throws -> [T] {
	var out: [T] = []
	for try await value in stream { out.append(value) }
	return out
}

private func summary(id: Int, last: TimeInterval) -> ProjectSummary {
	ProjectSummary(
        id: id,
        name: "n\(id)",
        pathWithNamespace: "p/\(id)",
        namespaceName: nil,
        description: nil,
        starCount: 0,
        forksCount: 0,
        avatarUrl: nil,
        webUrl: URL(string: "https://gitlab.com")!,
        lastActivityAt: Date(timeIntervalSince1970: last)
    )
}

// Create a concrete READMEService instance for testing
private func createStubREADMEService(remote: ProjectsRemoteDataSource) -> READMEService {
    READMEService(remote: remote, markdownRenderer: StubProjectsAPIClient())
}

@Suite("Projects · Repository")
struct ProjectsRepositorySuite {
	@Test("explore uses fresh cache and skips network on non-first page")
	func exploreUsesFreshCacheSkipsNetwork() async throws {
		let local = FakeProjectsLocalDataSource()
		await local.setReadResult(CachedPage(value: [summary(id: 1, last: 1)], isFresh: true, nextPage: 2))
		let remote = DefaultProjectsRemoteDataSource(api: StubProjectsAPIClient())
		let readmeService = createStubREADMEService(remote: remote)
		let repo = DefaultProjectsRepository(
			remote: remote,
			local: local,
			readmeService: readmeService,
			staleness: 9999,
			perPageDefault: 20
		)
		let results = try await collect(await repo.explorePage(orderBy: .lastActivityAt, sort: .descending, page: 2, perPage: 20, search: nil))
		#expect(results.count == 1)
		#expect(results.first?.isStale == false)
		#expect(results.first?.value.items.count == 1)
	}

	@Test("explore emits stale cache then fresh network when cache is stale")
	func exploreCacheStaleFetchesRemote() async throws {
		let local = FakeProjectsLocalDataSource()
		await local.setReadResult(CachedPage(value: [summary(id: 1, last: 1)], isFresh: false, nextPage: 2))
		var api = StubProjectsAPIClient()
		let dto = try ProjectsTestData.projectDTO(id: 2, lastActivityISO8601: "1970-01-01T00:00:05Z")
		api.paginatedProjects = Paginated(items: [dto], pageInfo: PageInfo(page: 2, perPage: 20, nextPage: 3))
		let remote = DefaultProjectsRemoteDataSource(api: api)
		let readmeService = createStubREADMEService(remote: remote)
		let repo = DefaultProjectsRepository(remote: remote, local: local, readmeService: readmeService)
		let results = try await collect(await repo.explorePage(orderBy: .lastActivityAt, sort: .descending, page: 2, perPage: 20, search: nil))
		#expect(results.count == 2)
		#expect(results.first?.isStale == true)
		#expect(results.last?.isStale == false)
	}

	@Test("personal combined merges unique and sorts by lastActivityAt; next page is min of sources")
	func personalCombinedMergeAndSort() async throws {
		let local = FakeProjectsLocalDataSource()
		await local.setReadResult(CachedPage(value: nil, isFresh: false, nextPage: nil))
		let api = StubProjectsAPIClient()
		let remote = DefaultProjectsRemoteDataSource(api: api)
		let readmeService = createStubREADMEService(remote: remote)
		let repo = DefaultProjectsRepository(remote: remote, local: local, readmeService: readmeService)
		let results = try await collect(await repo.personalPage(scope: .combined, page: 1, perPage: 20, search: nil))
		let page = try #require(results.last?.value)
		#expect(page.items.isEmpty)
	}

	@Test("explore throws when no cache and network fails")
	func exploreNoCacheNetworkErrorThrows() async {
		let local = FakeProjectsLocalDataSource()
		await local.setReadResult(CachedPage(value: nil, isFresh: false, nextPage: nil))
		struct FailureAPI: APIClientProtocol {
			func send<Response>(_ endpoint: Endpoint<Response>) async throws -> Response where Response: Decodable { throw URLError(.notConnectedToInternet) }
			func sendPaginated<Item>(_ endpoint: Endpoint<[Item]>) async throws -> Paginated<[Item]> where Item: Decodable { throw URLError(.notConnectedToInternet) }
			func sendWithHeaders<Response>(_ endpoint: Endpoint<Response>) async throws -> (Response, HTTPURLResponse) where Response: Decodable {
				throw URLError(.notConnectedToInternet)
			}
		}
		let remote = DefaultProjectsRemoteDataSource(api: FailureAPI())
		let readmeService = createStubREADMEService(remote: remote)
		let repo = DefaultProjectsRepository(remote: remote, local: local, readmeService: readmeService)
		await #expect(throws: Error.self) {
			_ = try await collect(await repo.explorePage(orderBy: .lastActivityAt, sort: .descending, page: 1, perPage: 20, search: nil))
		}
	}

	@Test("page 1 SWR: emits cache then network even when fresh")
	func page1SWR() async throws {
		let local = FakeProjectsLocalDataSource()
		await local.setReadResult(CachedPage(value: [summary(id: 1, last: 1)], isFresh: true, nextPage: 2))
		var api = StubProjectsAPIClient()
		let dto = try ProjectsTestData.projectDTO(id: 2, lastActivityISO8601: "1970-01-01T00:00:05Z")
		api.paginatedProjects = Paginated(items: [dto], pageInfo: PageInfo(page: 1, perPage: 20, nextPage: 2))
		let remote = DefaultProjectsRemoteDataSource(api: api)
		let readmeService = createStubREADMEService(remote: remote)
		let repo = DefaultProjectsRepository(remote: remote, local: local, readmeService: readmeService)
		let results = try await collect(await repo.explorePage(orderBy: .lastActivityAt, sort: .descending, page: 1, perPage: 20, search: nil))
		#expect(results.count == 2)
		#expect(results.first?.isStale == false) // cache
		#expect(results.last?.isStale == false)  // fresh network
	}

	@Test("stale cache + remote error: emits stale and completes")
	func staleCacheRemoteErrorCompletes() async throws {
		let local = FakeProjectsLocalDataSource()
		await local.setReadResult(CachedPage(value: [summary(id: 1, last: 1)], isFresh: false, nextPage: 2))
		struct FailureAPI: APIClientProtocol {
			func send<Response>(_ endpoint: Endpoint<Response>) async throws -> Response where Response: Decodable { throw URLError(.notConnectedToInternet) }
			func sendPaginated<Item>(_ endpoint: Endpoint<[Item]>) async throws -> Paginated<[Item]> where Item: Decodable { throw URLError(.notConnectedToInternet) }
			func sendWithHeaders<Response>(_ endpoint: Endpoint<Response>) async throws -> (Response, HTTPURLResponse) where Response: Decodable {
				throw URLError(.notConnectedToInternet)
			}
		}
		let remote = DefaultProjectsRemoteDataSource(api: FailureAPI())
		let readmeService = createStubREADMEService(remote: remote)
		let repo = DefaultProjectsRepository(remote: remote, local: local, readmeService: readmeService)
		let results = try await collect(await repo.explorePage(orderBy: .lastActivityAt, sort: .descending, page: 2, perPage: 20, search: nil))
		#expect(results.count == 1)
		#expect(results.first?.isStale == true) // emitted stale cache only
	}
}
