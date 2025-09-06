//
//  ReleaseDTO.swift
//  GitLabNetwork
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation

public struct ReleaseDTO: Decodable, Sendable, Equatable {
    public let tagName: String
    public let name: String?
    public let description: String?
    public let createdAt: Date
    public let releasedAt: Date?
}
