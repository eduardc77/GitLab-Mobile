//
//  SignInView.swift
//  AuthFeature
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import SwiftUI
import GitLabDesignSystem

public struct SignInView: View {
    @Environment(AuthenticationStore.self) private var authStore

    public init() {}

    public var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "globe")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)
            Text(.AuthL10n.connectTitle)
                .font(.headline)

            switch authStore.status {
            case .authenticating:
                LoadingView()
            case .unauthenticated, .authenticated:
                Button {
                    authStore.signIn()
                } label: {
                    Label(String(localized: .AuthL10n.signInWithGitLab), systemImage: "person.crop.circle.badge.plus")
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .alert(String(localized: .AuthL10n.errorTitle), isPresented: .constant(authStore.errorMessage != nil), actions: {
            Button(String(localized: .AuthL10n.okButtonTitle)) { authStore.clearError() }
        }, message: { Text(authStore.errorMessage ?? "") })
    }
}
