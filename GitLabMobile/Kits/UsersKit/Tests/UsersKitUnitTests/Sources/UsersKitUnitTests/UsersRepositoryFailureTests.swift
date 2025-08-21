//
//  UsersRepositoryFailureTests.swift
//  UsersKitUnitTests
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation
import Testing
@testable import UsersData
@testable import UsersDomain
import UsersKitTestDoubles
import GitLabNetwork

@Suite("Users · Repository (Failures)")
struct UsersRepositoryFailureSuite {
	@Test("currentUser propagates network errors")
	func currentUserPropagatesErrors() async {
		let error = NetworkError.transport(URLError(.notConnectedToInternet))
		let repo = DefaultUsersRepository(api: StubUsersAPIClient(user: nil, error: error))
		await #expect(throws: Error.self) {
			_ = try await repo.currentUser()
		}
	}
}
