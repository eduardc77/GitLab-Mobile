//
//  ProjectsRemoteDataSourceTests.swift
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

@Suite("Projects · RemoteDataSource")
struct ProjectsRemoteDataSourceSuite {
    @Test("personalOwned maps DTO to domain and preserves pageInfo")
    func personalOwnedMapsDto() async throws {
        let dto = try ProjectsTestData.projectDTO(id: 1)
        let page = ProjectsTestData.paginatedDTOs(items: [dto], page: 1, perPage: 20, nextPage: 2)
        var client = StubProjectsAPIClient()
        client.paginatedProjects = page
        let remote = DefaultProjectsRemoteDataSource(api: client)
        let result = try await remote.fetchPersonalOwned(page: 1, perPage: 20, search: nil)
        #expect(result.items.count == 1)
        #expect(result.items.first?.id == 1)
        #expect(result.pageInfo?.nextPage == 2)
    }
}
