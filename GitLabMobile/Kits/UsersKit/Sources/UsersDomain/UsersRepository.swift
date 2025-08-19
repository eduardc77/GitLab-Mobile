//
//  UsersRepository.swift
//  UsersKit
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation

public protocol UsersRepository: Sendable {
    func currentUser() async throws -> GitLabUser
}
