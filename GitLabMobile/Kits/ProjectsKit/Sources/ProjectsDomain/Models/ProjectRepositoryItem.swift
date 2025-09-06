//
//  ProjectRepositoryItem.swift
//  ProjectsKit
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation

public struct ProjectRepositoryItem: Sendable, Equatable, Identifiable, Hashable {
    public var id: String { path }
    public let name: String
    public let path: String
    public let isDirectory: Bool
    public let blobSHA: String?

    public init(name: String, path: String, isDirectory: Bool, blobSHA: String? = nil) {
        self.name = name
        self.path = path
        self.isDirectory = isDirectory
        self.blobSHA = blobSHA
    }

    /// SF Symbol icon name for this repository item based on its file type
    public var iconName: String {
        if isDirectory { return "folder" }

        let lower = name.lowercased()

        // Hidden files (must check first)
        if lower.hasPrefix(".") { return "doc.text.magnifyingglass" }

        // Programming languages
        if lower.hasSuffix(".swift") { return "swift" }
        if lower.hasSuffix(".kt") || lower.hasSuffix(".kotlin") { return "k.square" }
        if lower.hasSuffix(".java") { return "cup.and.saucer" }
        if lower.hasSuffix(".py") { return "p.square" }
        if lower.hasSuffix(".js") { return "j.square" }
        if lower.hasSuffix(".ts") { return "t.square" }
        if lower.hasSuffix(".cpp") || lower.hasSuffix(".c++") { return "c.square" }
        if lower.hasSuffix(".c") { return "c.square" }
        if lower.hasSuffix(".h") { return "h.square" }
        if lower.hasSuffix(".cs") { return "c.square" }
        if lower.hasSuffix(".php") { return "p.square" }
        if lower.hasSuffix(".rb") { return "r.square" }
        if lower.hasSuffix(".go") { return "g.square" }
        if lower.hasSuffix(".rs") { return "r.square" }

        // Web files
        if lower.hasSuffix(".html") { return "globe" }
        if lower.hasSuffix(".css") { return "paintbrush" }
        if lower.hasSuffix(".scss") || lower.hasSuffix(".sass") { return "paintbrush.pointed" }

        // Data/Config files
        if lower.hasSuffix(".json") { return "curlybraces.square" }
        if lower.hasSuffix(".xml") { return "tag" }
        if lower.hasSuffix(".yml") || lower.hasSuffix(".yaml") { return "doc.text" }
        if lower.hasSuffix(".toml") { return "doc.text" }
        if lower.hasSuffix(".plist") { return "list.bullet" }

        // Images
        if lower.hasSuffix(".png") || lower.hasSuffix(".jpg") ||
           lower.hasSuffix(".jpeg") || lower.hasSuffix(".gif") ||
           lower.hasSuffix(".svg") || lower.hasSuffix(".webp") { return "photo" }

        // Documents
        if lower.hasSuffix(".md") { return "doc.plaintext" }
        if lower.hasSuffix(".txt") { return "doc.text" }
        if lower.hasSuffix(".rtf") { return "doc.richtext" }
        if lower.hasSuffix(".pdf") { return "doc" }

        // Archives
        if lower.hasSuffix(".zip") || lower.hasSuffix(".tar") ||
           lower.hasSuffix(".gz") || lower.hasSuffix(".rar") { return "doc.zipper" }

        // Executables/Libraries
        if lower.hasSuffix(".exe") || lower.hasSuffix(".app") ||
           lower.hasSuffix(".dylib") || lower.hasSuffix(".so") { return "terminal.fill" }

        // Default
        return "doc"
    }
}
