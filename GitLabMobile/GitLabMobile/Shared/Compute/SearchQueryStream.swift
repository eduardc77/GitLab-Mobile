//
//  SearchQueryStream.swift
//  GitLabMobile
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation
import AsyncAlgorithms

///  A lightweight helper to manage a debounced + de-duplicated text stream
///  using Swift Async Algorithms. Designed for SwiftUI search fields.
@MainActor
public final class SearchQueryStream {
    private var continuation: AsyncStream<String>.Continuation?
    private var task: Task<Void, Never>?

    public init() {}

    public func start(
        debounceMilliseconds: Int = 250,
        onEvent: @MainActor @Sendable @escaping (String) async -> Void
    ) {
        task?.cancel()
        let stream = AsyncStream(String.self, bufferingPolicy: .bufferingNewest(1)) { continuation in
            self.continuation = continuation
        }
        let clock = ContinuousClock()
        task = Task {
            for await trimmed in (stream
                .map { (source: String) in source.trimmingCharacters(in: .whitespacesAndNewlines) }
                .removeDuplicates()
                .debounce(for: .milliseconds(debounceMilliseconds), clock: clock)) {
                if Task.isCancelled { return }
                await onEvent(trimmed)
            }
        }
    }

    public func yield(_ text: String) {
        continuation?.yield(text)
    }

    deinit {
        continuation?.finish()
        task?.cancel()
    }
}
