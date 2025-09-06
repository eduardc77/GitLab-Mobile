//
//  ContributorsDTO.swift
//  GitLabNetwork
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation

public struct ContributorsDTO: Codable, Sendable, Equatable {
    public let name: String?
    public let email: String?
    public let commits: Int
    public let additions: Int
    public let deletions: Int

    public init(name: String?, email: String?, commits: Int, additions: Int, deletions: Int) {
        self.name = name
        self.email = email
        self.commits = commits
        self.additions = additions
        self.deletions = deletions
    }
}
