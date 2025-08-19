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

    private var continuation: AsyncStream<Event>.Continuation?
    private var driver: Task<Void, Never>?

    public init() {}

    deinit { driver?.cancel() }

    public func start(handler: @escaping Handler) {
        let stream = AsyncStream(Event.self, bufferingPolicy: .bufferingNewest(1)) { continuation in
            self.continuation = continuation
        }
        driver?.cancel()
        driver = Task {
            var active: Task<Void, Never>?
            for await event in stream {
                active?.cancel()
                active = Task { @MainActor in await handler(event) }
                _ = await active?.value
            }
        }
    }

    public func send(_ event: Event) { continuation?.yield(event) }
}
