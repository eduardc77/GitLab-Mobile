//
//  JSONDecoder+GitLab.swift
//  GitLabNetwork
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

            // Handle null values properly for optional Date fields
            if container.decodeNil() {
                return Date.distantPast // Return a default date for null values
            }

            let string = try container.decode(String.self)

            // Allocate formatters locally to avoid shared mutable state across actors
            let isoWithFractional = ISO8601DateFormatter()
            isoWithFractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = isoWithFractional.date(from: string) { return date }

            let iso = ISO8601DateFormatter()
            iso.formatOptions = [.withInternetDateTime]
            if let date = iso.date(from: string) { return date }

            // Handle date-only format (YYYY-MM-DD)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            if let date = dateFormatter.date(from: string) { return date }

            // For unparseable dates, return a default instead of throwing
            return Date.distantPast
        }

        return decoder
    }
}
