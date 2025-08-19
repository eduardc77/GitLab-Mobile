//
//  StoreDefaults.swift
//  GitLabUtilities
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation

///  Centralized defaults for list/pagination behavior used across stores.
public enum StoreDefaults {
    /// Number of rows from the end of the list at which we start prefetching the next page
    public static let prefetchDistance: Int = 5

    /// Throttle window for successive load-more triggers during fast scrolling
    public static let loadMoreThrottle: TimeInterval = 0.15

    /// Maximum number of recent search queries to retain
    public static let recentQueriesLimit: Int = 10

    /// Default page size for paginated project lists
    public static let perPage: Int = 20
    /// Cache freshness window (seconds) for SwiftData-backed project caches
    public static let cacheStaleInterval: TimeInterval = 300
}
