//
//  ProjectsCacheKey.swift
//  GitLabMobile
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation

// Key describing a cached context (sort/scope/query variations)
public struct ProjectsCacheKey: Hashable, Sendable {
    public let identifier: String
    public init(identifier: String) { self.identifier = identifier }
}
