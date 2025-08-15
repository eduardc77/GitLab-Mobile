//
//  JSONDecoder+GitLab.swift
//  GitLabMobile
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation

public extension JSONDecoder {
    static var gitLab: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let string = try container.decode(String.self)

            // Try fractional seconds first (reuse shared formatters to avoid heavy allocations)
            if let date = DateFormatters.isoWithFractional.date(from: string) { return date }
            if let date = DateFormatters.iso.date(from: string) { return date }

            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid ISO8601 date: \(string)")
        }
        return decoder
    }
}

private enum DateFormatters {
    static let isoWithFractional: ISO8601DateFormatter = {
        let isoWithFractional = ISO8601DateFormatter()
        isoWithFractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return isoWithFractional
    }()

    static let iso: ISO8601DateFormatter = {
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime]
        return iso
    }()
}
