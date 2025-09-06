//
//  BranchDTO.swift
//  GitLabNetwork
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation

public struct BranchDTO: Decodable, Sendable, Equatable {
    public let name: String
    public let commit: BranchCommitDTO?
    public let `protected`: Bool
    public let `default`: Bool

    enum CodingKeys: String, CodingKey {
        case name, commit, protected, `default`
    }

    public var isProtected: Bool { `protected` }
    public var isDefault: Bool { `default` }
}

public struct BranchCommitDTO: Decodable, Sendable, Equatable {
    public let id: String?
    public let shortId: String?
    public let title: String?
    public let authorName: String?
    public let authoredDate: Date?
    public let createdAt: Date?
    public let parentIds: [String]?

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Decode only the fields we care about, ignore unknown fields
        id = try container.decodeIfPresent(String.self, forKey: .id)
        shortId = try container.decodeIfPresent(String.self, forKey: .shortId)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        authorName = try container.decodeIfPresent(String.self, forKey: .authorName)
        authoredDate = try container.decodeIfPresent(Date.self, forKey: .authoredDate)
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
        parentIds = try container.decodeIfPresent([String].self, forKey: .parentIds)
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case shortId = "short_id"
        case title
        case authorName = "author_name"
        case authoredDate = "authored_date"
        case createdAt = "created_at"
        case parentIds = "parent_ids"
    }
}
