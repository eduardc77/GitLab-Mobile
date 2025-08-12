import Foundation

public struct Endpoint<Response: Decodable> {
    // Relative path by default; can be absolute when `isAbsolutePath == true`
    public var path: String
    public var method: HTTPMethod
    public var queryItems: [URLQueryItem]
    public var headers: [String: String]
    public var body: Data?

    // If true, `path` is treated as absolute and no prefix will be applied
    public var isAbsolutePath: Bool

    public init(
        path: String,
        method: HTTPMethod = .get,
        queryItems: [URLQueryItem] = [],
        headers: [String: String] = [:],
        body: Data? = nil,
        isAbsolutePath: Bool = false
    ) {
        self.path = path
        self.method = method
        self.queryItems = queryItems
        self.headers = headers
        self.body = body
        self.isAbsolutePath = isAbsolutePath
    }
}
