//
//  ProjectsAPI.swift
//  GitLabMobile
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation

public enum ProjectsAPI {

    public enum SortBy: String, CaseIterable {
        case starCount = "star_count"
        case lastActivityAt = "last_activity_at"
        case createdAt = "created_at"
        case name = "name"
    }

    public enum SortDirection: String, CaseIterable {
        case descending = "desc"
        case ascending = "asc"
    }

    // Public explore
    public static func trending(page: Int = 1, perPage: Int = 20, search: String? = nil) -> Endpoint<[ProjectDTO]> {
        Endpoint(
            path: "/projects",
            queryItems: [
                .init(name: "page", value: String(page)),
                .init(name: "per_page", value: String(perPage)),
                .init(name: "order_by", value: "last_activity_at"),
                .init(name: "sort", value: "desc"),
                .init(name: "visibility", value: "public"),
                .init(name: "simple", value: "true")
            ].appendingSearch(search),
            options: RequestOptions(cachePolicy: nil, timeout: 8, useETag: false, attachAuthorization: false)
        )
    }

    public static func mostStarred(page: Int = 1, perPage: Int = 20, search: String? = nil) -> Endpoint<[ProjectDTO]> {
        Endpoint(
            path: "/projects",
            queryItems: [
                .init(name: "page", value: String(page)),
                .init(name: "per_page", value: String(perPage)),
                .init(name: "order_by", value: "star_count"),
                .init(name: "sort", value: "desc"),
                .init(name: "visibility", value: "public"),
                .init(name: "simple", value: "true")
            ].appendingSearch(search),
            options: RequestOptions(cachePolicy: nil, timeout: 8, useETag: false, attachAuthorization: false)
        )
    }

    public static func search(_ query: String, page: Int = 1, perPage: Int = 20) -> Endpoint<[ProjectDTO]> {
        Endpoint(
            path: "/projects",
            queryItems: [
                .init(name: "page", value: String(page)),
                .init(name: "per_page", value: String(perPage)),
                .init(name: "search", value: query),
                .init(name: "visibility", value: "public")
            ],
            options: RequestOptions(cachePolicy: nil, timeout: 8, useETag: false, attachAuthorization: false)
        )
    }

    public static func active(page: Int = 1, perPage: Int = 20, search: String? = nil) -> Endpoint<[ProjectDTO]> {
        // Active == recently updated
        trending(page: page, perPage: perPage, search: search)
    }

    public static func inactive(page: Int = 1, perPage: Int = 20, search: String? = nil) -> Endpoint<[ProjectDTO]> {
        Endpoint(
            path: "/projects",
            queryItems: [
                .init(name: "page", value: String(page)),
                .init(name: "per_page", value: String(perPage)),
                .init(name: "order_by", value: "last_activity_at"),
                .init(name: "sort", value: "asc"),
                .init(name: "visibility", value: "public"),
                .init(name: "simple", value: "true")
            ].appendingSearch(search),
            options: RequestOptions(cachePolicy: nil, timeout: 8, useETag: false, attachAuthorization: false)
        )
    }

    public static func all(page: Int = 1, perPage: Int = 20, search: String? = nil) -> Endpoint<[ProjectDTO]> {
        Endpoint(
            path: "/projects",
            queryItems: [
                .init(name: "page", value: String(page)),
                .init(name: "per_page", value: String(perPage)),
                .init(name: "visibility", value: "public"),
                .init(name: "simple", value: "true")
            ].appendingSearch(search),
            options: RequestOptions(cachePolicy: nil, timeout: nil, useETag: false)
        )
    }

    // Authenticated
    public static func owned(page: Int = 1, perPage: Int = 20, search: String? = nil) -> Endpoint<[ProjectSummary]> {
        Endpoint(
            path: "/projects",
            queryItems: [
                .init(name: "page", value: String(page)),
                .init(name: "per_page", value: String(perPage)),
                .init(name: "owned", value: "true")
            ].appendingSearch(search),
            options: RequestOptions(cachePolicy: nil, timeout: nil, useETag: true)
        )
    }

    public static func starred(page: Int = 1, perPage: Int = 20, search: String? = nil) -> Endpoint<[ProjectSummary]> {
        Endpoint(
            path: "/projects",
            queryItems: [
                .init(name: "page", value: String(page)),
                .init(name: "per_page", value: String(perPage)),
                .init(name: "starred", value: "true")
            ].appendingSearch(search),
            options: RequestOptions(cachePolicy: nil, timeout: nil, useETag: true)
        )
    }

    public static func membership(page: Int = 1, perPage: Int = 20, search: String? = nil) -> Endpoint<[ProjectSummary]> {
        Endpoint(
            path: "/projects",
            queryItems: [
                .init(name: "page", value: String(page)),
                .init(name: "per_page", value: String(perPage)),
                .init(name: "membership", value: "true")
            ].appendingSearch(search),
            options: RequestOptions(cachePolicy: nil, timeout: nil, useETag: true)
        )
    }

    public static func project(id: Int) -> Endpoint<ProjectDTO> {
        Endpoint(path: "/projects/\(id)")
    }

    public static func list(
        orderBy: SortBy,
        sort: SortDirection,
        page: Int = 1,
        perPage: Int = 20,
        search: String? = nil,
        publicOnly: Bool = true
    ) -> Endpoint<[ProjectDTO]> {
        var items: [URLQueryItem] = [
            .init(name: "page", value: String(page)),
            .init(name: "per_page", value: String(perPage)),
            .init(name: "order_by", value: orderBy.rawValue),
            .init(name: "sort", value: sort.rawValue)
        ]
        if publicOnly { items.append(.init(name: "visibility", value: "public")) }
        if publicOnly { items.append(.init(name: "simple", value: "true")) }
        items = items.appendingSearch(search)
        return Endpoint(
            path: "/projects",
            queryItems: items,
            options: RequestOptions(
                cachePolicy: nil,
                timeout: 8,
                useETag: true,
                attachAuthorization: false
            )
        )
    }
}

public extension ProjectsAPI.SortBy {

    var displayTitle: String {
        switch self {
        case .starCount: return "Stars"
        case .lastActivityAt: return "Updated date"
        case .createdAt: return "Created date"
        case .name: return "Name"
        }
    }
}

public extension ProjectsAPI.SortDirection {
    var displayTitle: String {
        switch self {
        case .ascending: return "Ascending"
        case .descending: return "Descending"
        }
    }
}

private extension Array where Element == URLQueryItem {
    func appendingSearch(_ query: String?) -> [URLQueryItem] {
        guard let query, !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return self }
        var copy = self
        copy.append(URLQueryItem(name: "search", value: query))
        return copy
    }

    // No cursor param in offset pagination
}
