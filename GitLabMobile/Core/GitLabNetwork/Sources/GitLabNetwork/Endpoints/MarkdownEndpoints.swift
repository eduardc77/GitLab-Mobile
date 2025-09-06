//
//  MarkdownEndpoints.swift
//  GitLabNetwork
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation

public struct MarkdownHTMLResponse: Decodable, Sendable {
    public let html: String
}

public extension Endpoint where Response == MarkdownHTMLResponse {
    static func renderMarkdown(
        markdown: String,
        projectPath: String?,
        gfm: Bool = true,
        sanitized: Bool = true,
        attachAuthorization: Bool = true
    ) -> Endpoint {
        let body = ["text": markdown, "project": projectPath as Any, "gfm": gfm] as [String: Any]
        let data = try? JSONSerialization.data(withJSONObject: body, options: [])
        var headers = [String: String]()
        headers["Content-Type"] = "application/json"
        return Endpoint(
            path: "/markdown",
            method: .post,
            headers: headers,
            body: data,
            isAbsolutePath: false,
            options: RequestOptions(attachAuthorization: attachAuthorization)
        )
    }

    static func renderProjectMarkdown(
        projectId: Int,
        markdown: String,
        gfm: Bool = true,
        attachAuthorization: Bool = true
    ) -> Endpoint {
        // Try the general markdown endpoint first (more reliable)
        let body = ["text": markdown, "gfm": gfm] as [String: Any]
        let data = try? JSONSerialization.data(withJSONObject: body, options: [])
        var headers = [String: String]()
        headers["Content-Type"] = "application/json"
        return Endpoint(
            path: "/markdown",
            method: .post,
            headers: headers,
            body: data,
            isAbsolutePath: false,
            options: RequestOptions(attachAuthorization: attachAuthorization)
        )
    }
}
