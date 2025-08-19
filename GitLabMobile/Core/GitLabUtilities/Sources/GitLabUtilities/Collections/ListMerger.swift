//
//  ListMerger.swift
//  GitLabUtilities
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation

/// A small utility actor to offload CPU work when merging paginated results.
/// - Deduplicates by `Identifiable.ID`
/// - Optionally trims to a maximum item count (keep newest suffix)
public actor ListMerger {
    public init() {}

    public func appendUniqueById<Item: Identifiable & Sendable>(
        existing: [Item],
        newItems: [Item],
        maxCount: Int? = nil
    ) -> [Item] where Item.ID: Hashable {
        let existingIDs = Set(existing.map { $0.id })
        var merged = existing
        merged.reserveCapacity(existing.count + newItems.count)
        for item in newItems where !existingIDs.contains(item.id) {
            merged.append(item)
        }
        if let max = maxCount, merged.count > max {
            merged = Array(merged.suffix(max))
        }
        return merged
    }
}
