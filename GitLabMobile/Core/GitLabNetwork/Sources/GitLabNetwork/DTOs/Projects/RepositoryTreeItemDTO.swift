//
//  RepositoryTreeItemDTO.swift
//  GitLabNetwork
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation

public struct RepositoryTreeItemDTO: Decodable, Sendable, Equatable {
    public let id: String?
    public let name: String
    public let type: String // "tree" or "blob"
    public let path: String
    public let mode: String?
}
