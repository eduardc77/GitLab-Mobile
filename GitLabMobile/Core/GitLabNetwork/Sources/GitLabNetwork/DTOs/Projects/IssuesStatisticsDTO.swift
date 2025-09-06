//
//  IssuesStatisticsDTO.swift
//  GitLabNetwork
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation

public struct IssuesStatisticsDTO: Decodable, Sendable, Equatable {
    public let statistics: Statistics

    public struct Statistics: Decodable, Sendable, Equatable {
        public let counts: Counts
    }

    public struct Counts: Decodable, Sendable, Equatable {
        public let all: Int?
        public let closed: Int?
        public let opened: Int?
    }
}
