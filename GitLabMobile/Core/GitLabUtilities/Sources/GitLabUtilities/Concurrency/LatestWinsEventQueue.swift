//
//  LatestWinsEventQueue.swift
//  GitLabUtilities
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation

public final class LatestWinsEventQueue<Event: Equatable & Sendable> {
    public typealias Handler = @MainActor @Sendable (Event) async -> Void

    // Use a separate holder to avoid retain cycles
    private final class ContinuationHolder {
        var continuation: AsyncStream<Event>.Continuation?

        func finish() {
            continuation?.finish()
            continuation = nil
        }
    }

    private let continuationHolder = ContinuationHolder()
    private var driver: Task<Void, Never>?

    public init() {}

    deinit {
        driver?.cancel()
        continuationHolder.finish()
    }

    public func start(handler: @escaping Handler) {
        // Cancel existing driver and finish old continuation
        driver?.cancel()
        continuationHolder.finish()

        // Create new stream using the holder to avoid retain cycle
        let stream = AsyncStream(Event.self, bufferingPolicy: .bufferingNewest(1)) { continuation in
            continuationHolder.continuation = continuation
        }

        // Start the driver task - handler is already @MainActor
        driver = Task { @MainActor in
            for await event in stream {
                // Call handler directly since we're on main actor
                await handler(event)
            }
        }
    }

    public func send(_ event: Event) {
        continuationHolder.continuation?.yield(event)
    }
}
