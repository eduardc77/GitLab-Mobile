//
//  MilestoneDTO.swift
//  GitLabNetwork
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation

public struct MilestoneDTO: Decodable, Sendable, Equatable {
    public let id: Int?
    public let iid: Int?
    public let projectId: Int?
    public let title: String?
    public let description: String?
    public let state: String?
    public let createdAt: Date?
    public let updatedAt: Date?
    public let dueDate: Date?
    public let startDate: Date?
    public let expired: Bool?
    public let webUrl: String?

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Decode only the fields we care about, ignore unknown fields
        id = try container.decodeIfPresent(Int.self, forKey: .id)
        iid = try container.decodeIfPresent(Int.self, forKey: .iid)
        projectId = try container.decodeIfPresent(Int.self, forKey: .projectId)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        state = try container.decodeIfPresent(String.self, forKey: .state)
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
        updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt)
        dueDate = try container.decodeIfPresent(Date.self, forKey: .dueDate)
        startDate = try container.decodeIfPresent(Date.self, forKey: .startDate)
        expired = try container.decodeIfPresent(Bool.self, forKey: .expired)
        webUrl = try container.decodeIfPresent(String.self, forKey: .webUrl)
    }

    private enum CodingKeys: String, CodingKey {
        case id, iid
        case projectId = "project_id"
        case title, description, state
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case dueDate = "due_date"
        case startDate = "start_date"
        case expired
        case webUrl = "web_url"
    }
}
