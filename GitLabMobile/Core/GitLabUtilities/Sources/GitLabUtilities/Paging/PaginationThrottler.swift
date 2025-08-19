//
//  PaginationThrottler.swift
//  GitLabUtilities
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation

///  Small utility to throttle load-more triggers during fast flings.
@MainActor
public final class PaginationThrottler {
    private var lastTriggerAt: Date?

    public init() {}

    public func shouldLoadMore(now: Date = Date()) -> Bool {
        if let last = lastTriggerAt, now.timeIntervalSince(last) < StoreDefaults.loadMoreThrottle { return false }
        lastTriggerAt = now
        return true
    }
}
