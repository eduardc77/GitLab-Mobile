//
//  ProjectsTestData.swift
//  ProjectsKitTestDoubles
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation
import GitLabNetwork

private struct ProjectDTOJSON: Encodable {
    let id: Int
    let name: String
    let pathWithNamespace: String
    let description: String?
    let starCount: Int?
    let forksCount: Int?
    let avatarUrl: String?
    let webUrl: String
    let lastActivityAt: String // ISO8601
}

public enum ProjectsTestData {
    // Generic builder
    public static func projectDTO(
        id: Int = 1,
        name: String = "Example Project",
        pathWithNamespace: String = "org/example",
        description: String? = "Sample description",
        starCount: Int? = 10,
        forksCount: Int? = 2,
        avatarUrl: String? = nil,
        webUrl: String = "https://gitlab.com/org/example",
        lastActivityISO8601: String = "2024-01-01T12:00:00Z"
    ) throws -> ProjectDTO {
        let json = ProjectDTOJSON(
            id: id,
            name: name,
            pathWithNamespace: pathWithNamespace,
            description: description,
            starCount: starCount,
            forksCount: forksCount,
            avatarUrl: avatarUrl,
            webUrl: webUrl,
            lastActivityAt: lastActivityISO8601
        )
        let data = try JSONEncoder().encode(json)
        return try JSONDecoder.gitLab.decode(ProjectDTO.self, from: data)
    }

    // Named fixtures
    public static func tinyProject() throws -> ProjectDTO {
        try projectDTO(
            id: 1,
            name: "Tiny",
            pathWithNamespace: "org/tiny",
            description: nil,
            starCount: 0,
            forksCount: 0
        )
    }

    public static func largeCountsProject() throws -> ProjectDTO {
        try projectDTO(
            id: 2,
            name: "Popular",
            pathWithNamespace: "org/popular",
            description: "Popular repo",
            starCount: 10000,
            forksCount: 500
        )
    }

    public static func missingDescription() throws -> ProjectDTO {
        try projectDTO(
            id: 3,
            name: "NoDesc",
            pathWithNamespace: "org/nodesc",
            description: nil
        )
    }

    public static func oldLastActivity() throws -> ProjectDTO {
        try projectDTO(
            id: 4,
            name: "Old",
            pathWithNamespace: "org/old",
            lastActivityISO8601: "1970-01-01T00:00:05Z"
        )
    }

    public static func paginatedDTOs(items: [ProjectDTO], page: Int = 1, perPage: Int = 20, nextPage: Int? = nil) -> Paginated<[ProjectDTO]> {
        Paginated(
            items: items,
            pageInfo: PageInfo(page: page, perPage: perPage, nextPage: nextPage)
        )
    }
}
