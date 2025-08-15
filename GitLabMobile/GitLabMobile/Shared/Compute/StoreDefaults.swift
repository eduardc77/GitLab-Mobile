//
//  StoreDefaults.swift
//  GitLabMobile
//
//  Centralized defaults for list/pagination behavior used across stores.
//

import Foundation

public enum StoreDefaults {
    /// Number of rows from the end of the list at which we start prefetching the next page
    public static let prefetchDistance: Int = 5

    /// Throttle window for successive load-more triggers during fast scrolling
    public static let loadMoreThrottle: TimeInterval = 0.15
}
