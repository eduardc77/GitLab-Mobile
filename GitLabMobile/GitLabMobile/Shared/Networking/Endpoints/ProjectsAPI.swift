import Foundation

public enum ProjectsAPI {
    // Public explore
    public static func trending(page: Int = 1, perPage: Int = 20) -> Endpoint<[ProjectSummary]> {
        Endpoint(
            path: "/projects",
            queryItems: [
                .init(name: "page", value: String(page)),
                .init(name: "per_page", value: String(perPage)),
                .init(name: "order_by", value: "last_activity_at"),
                .init(name: "sort", value: "desc"),
                .init(name: "visibility", value: "public")
            ]
        )
    }

    public static func mostStarred(page: Int = 1, perPage: Int = 20) -> Endpoint<[ProjectSummary]> {
        Endpoint(
            path: "/projects",
            queryItems: [
                .init(name: "page", value: String(page)),
                .init(name: "per_page", value: String(perPage)),
                .init(name: "order_by", value: "star_count"),
                .init(name: "sort", value: "desc"),
                .init(name: "visibility", value: "public")
            ]
        )
    }

    public static func search(_ query: String, page: Int = 1, perPage: Int = 20) -> Endpoint<[ProjectSummary]> {
        Endpoint(
            path: "/projects",
            queryItems: [
                .init(name: "page", value: String(page)),
                .init(name: "per_page", value: String(perPage)),
                .init(name: "search", value: query),
                .init(name: "visibility", value: "public")
            ]
        )
    }

    // Authenticated
    public static func owned(page: Int = 1, perPage: Int = 20) -> Endpoint<[ProjectSummary]> {
        Endpoint(
            path: "/projects",
            queryItems: [
                .init(name: "page", value: String(page)),
                .init(name: "per_page", value: String(perPage)),
                .init(name: "owned", value: "true")
            ]
        )
    }

    public static func starred(page: Int = 1, perPage: Int = 20) -> Endpoint<[ProjectSummary]> {
        Endpoint(
            path: "/projects",
            queryItems: [
                .init(name: "page", value: String(page)),
                .init(name: "per_page", value: String(perPage)),
                .init(name: "starred", value: "true")
            ]
        )
    }

    public static func membership(page: Int = 1, perPage: Int = 20) -> Endpoint<[ProjectSummary]> {
        Endpoint(
            path: "/projects",
            queryItems: [
                .init(name: "page", value: String(page)),
                .init(name: "per_page", value: String(perPage)),
                .init(name: "membership", value: "true")
            ]
        )
    }

    public static func project(id: Int) -> Endpoint<ProjectSummary> {
        Endpoint(path: "/projects/\(id)")
    }
}

