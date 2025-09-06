//
//  CommitDTO.swift
//  GitLabNetwork
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation

public struct CommitDTO: Decodable, Sendable, Equatable {
    public let id: String?
    public let shortId: String?
    public let title: String?
    public let message: String?
    public let authorName: String?
    public let authorEmail: String?
    public let authoredDate: Date?
    public let committerName: String?
    public let committerEmail: String?
    public let committedDate: Date?
    public let parentIds: [String]?

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Decode only the fields we care about, ignore unknown fields
        id = try container.decodeIfPresent(String.self, forKey: .id)
        shortId = try container.decodeIfPresent(String.self, forKey: .shortId)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        message = try container.decodeIfPresent(String.self, forKey: .message)
        authorName = try container.decodeIfPresent(String.self, forKey: .authorName)
        authorEmail = try container.decodeIfPresent(String.self, forKey: .authorEmail)
        authoredDate = try container.decodeIfPresent(Date.self, forKey: .authoredDate)
        committerName = try container.decodeIfPresent(String.self, forKey: .committerName)
        committerEmail = try container.decodeIfPresent(String.self, forKey: .committerEmail)
        committedDate = try container.decodeIfPresent(Date.self, forKey: .committedDate)
        parentIds = try container.decodeIfPresent([String].self, forKey: .parentIds)
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case shortId = "short_id"
        case title, message
        case authorName = "author_name"
        case authorEmail = "author_email"
        case authoredDate = "authored_date"
        case committerName = "committer_name"
        case committerEmail = "committer_email"
        case committedDate = "committed_date"
        case parentIds = "parent_ids"
    }
}
