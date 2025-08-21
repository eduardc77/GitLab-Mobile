//
//  UsersRepositoryTests.swift
//  UsersKitUnitTests
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation
import Testing
@testable import UsersDomain
@testable import UsersData
import UsersKitTestDoubles
import GitLabNetwork

@Suite("Users · Repository")
struct UsersRepositorySuite {
	@Test("currentUser maps DTO to domain correctly")
	func currentUserMapsDto() async throws {
		let dto = try UsersTestData.userDTO()
		let repo = DefaultUsersRepository(api: StubUsersAPIClient(user: dto))
		let user = try await repo.currentUser()
		#expect(user.id == dto.id)
		#expect(user.username == dto.username)
		#expect(user.name == dto.name)
	}
}
