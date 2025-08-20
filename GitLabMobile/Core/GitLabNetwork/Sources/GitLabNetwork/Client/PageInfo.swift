//
//  PageInfo.swift
//  GitLabNetwork
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation

public struct PageInfo: Sendable, Equatable {
    public let page: Int
    public let perPage: Int
    public let nextPage: Int?
    public let prevPage: Int?
    public let total: Int?
    public let totalPages: Int?

    public init(
        page: Int,
        perPage: Int,
        nextPage: Int? = nil,
        prevPage: Int? = nil,
        total: Int? = nil,
        totalPages: Int? = nil
    ) {
        self.page = page
        self.perPage = perPage
        self.nextPage = nextPage
        self.prevPage = prevPage
        self.total = total
        self.totalPages = totalPages
    }
}

public enum PaginationParser {
    public static func parse(from response: HTTPURLResponse) -> PageInfo? {
        let headers = response.allHeaderFields
        let page = (headers["x-page"] as? String ?? headers["X-Page"] as? String).flatMap(Int.init)
        let perPage = (headers["x-per-page"] as? String ?? headers["X-Per-Page"] as? String).flatMap(Int.init)
        let linkHeader = (headers["link"] as? String) ?? (headers["Link"] as? String)
        // Fallback: derive next/prev page numbers from Link header when X-Next-Page / X-Prev-Page are absent
        let linkNextPage = parsePageNumberFromLink(linkHeader, rel: "next")
        let linkPrevPage = parsePageNumberFromLink(linkHeader, rel: "prev")
        if page == nil && perPage == nil && linkHeader == nil {
            return nil
        }
        return PageInfo(
            page: page ?? 1,
            perPage: perPage ?? 20,
            nextPage: (((headers["x-next-page"] as? String)
                ?? (headers["X-Next-Page"] as? String)).flatMap(Int.init)) ?? linkNextPage,
            prevPage: (((headers["x-prev-page"] as? String)
                ?? (headers["X-Prev-Page"] as? String)).flatMap(Int.init)) ?? linkPrevPage,
            total: ((headers["x-total"] as? String)
                ?? (headers["X-Total"] as? String)).flatMap(Int.init),
            totalPages: ((headers["x-total-pages"] as? String)
                ?? (headers["X-Total-Pages"] as? String)).flatMap(Int.init)
        )
    }

    private static func parsePageNumberFromLink(_ linkHeader: String?, rel: String) -> Int? {
        guard let linkHeader, !linkHeader.isEmpty else { return nil }
        let parts = linkHeader.split(separator: ",")
        for part in parts {
            let trimmed = part.trimmingCharacters(in: .whitespacesAndNewlines)
            guard trimmed.contains("rel=\"\(rel)\"") else { continue }
            guard let urlStart = trimmed.firstIndex(of: "<"), let urlEnd = trimmed.firstIndex(of: ">") else { continue }
            let urlString = String(trimmed[trimmed.index(after: urlStart)..<urlEnd])
            if let components = URLComponents(string: urlString),
               let pageString = components.queryItems?.first(where: { $0.name == "page" })?.value,
               let page = Int(pageString) {
                return page
            }
        }
        return nil
    }
}

public struct Paginated<Response: Sendable>: Sendable, Equatable where Response: Equatable {
    public let items: Response
    public let pageInfo: PageInfo?
    public init(items: Response, pageInfo: PageInfo?) {
        self.items = items
        self.pageInfo = pageInfo
    }
}
