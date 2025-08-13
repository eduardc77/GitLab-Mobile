import Foundation

public struct PageInfo: Sendable, Equatable {
    public let page: Int
    public let perPage: Int
    public let nextPage: Int?
    public let prevPage: Int?
    public let total: Int?
    public let totalPages: Int?
}

public enum PaginationParser {
    public static func parse(from response: HTTPURLResponse) -> PageInfo? {
        let headers = response.allHeaderFields
        let page = (headers["x-page"] as? String ?? headers["X-Page"] as? String).flatMap(Int.init)
        let perPage = (headers["x-per-page"] as? String ?? headers["X-Per-Page"] as? String).flatMap(Int.init)
        if page == nil && perPage == nil { return nil }
        return PageInfo(
            page: page ?? 1,
            perPage: perPage ?? 20,
            nextPage: ((headers["x-next-page"] as? String)
                ?? (headers["X-Next-Page"] as? String)).flatMap(Int.init),
            prevPage: ((headers["x-prev-page"] as? String)
                ?? (headers["X-Prev-Page"] as? String)).flatMap(Int.init),
            total: ((headers["x-total"] as? String)
                ?? (headers["X-Total"] as? String)).flatMap(Int.init),
            totalPages: ((headers["x-total-pages"] as? String)
                ?? (headers["X-Total-Pages"] as? String)).flatMap(Int.init)
        )
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
