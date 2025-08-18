//
//  ProfileStore.swift
//  GitLabMobile
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Observation

@MainActor
@Observable
public final class ProfileStore {
    private let authStore: AuthenticationStore
    private let service: ProfileService

    private(set) var user: GitLabUser?
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    public init(authStore: AuthenticationStore, service: ProfileService) {
        self.authStore = authStore
        self.service = service
    }

    public func loadIfNeeded() async {
        guard user == nil, authStore.status == .authenticated, !isLoading else { return }
        await reload()
    }

    public func reload() async {
        guard authStore.status == .authenticated else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            user = try await service.loadCurrentUser()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    public func onAppForegrounded() async {
        // Lightweight revalidation: relies on ETag to be 304 if unchanged
        await reload()
    }
}
