//
//  AuthenticationStore.swift
//  AuthFeature
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Observation
import AuthenticationServices
import GitLabNetwork

@MainActor
@Observable
public final class AuthenticationStore {
    public enum Status: Equatable { case unauthenticated, authenticating, authenticated }

    private let oauthService: OAuthServicing
    private let authManager: AuthorizationManagerProtocol
    private let oauthConfig: OAuthAppConfig
    private var authSession: ASWebAuthenticationSession?
    private let presentationProvider = WebAuthPresentationProvider()
    private var pendingCodeVerifier: String?
    private var pendingState: String?

    private(set) public var status: Status = .authenticating
    private(set) public var errorMessage: String?
    private var didAttemptRestore = false

    public init(oauthService: OAuthServicing, authManager: AuthorizationManagerProtocol, oauthConfig: OAuthAppConfig) {
        self.oauthService = oauthService
        self.authManager = authManager
        self.oauthConfig = oauthConfig
    }

    public func signIn() {
        errorMessage = nil
        status = .authenticating
        guard !oauthConfig.clientId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            status = .unauthenticated
            errorMessage = """
            Missing ClientID. Set Info.plist → GitLabOAuth → ClientID to your GitLab OAuth application ID.
            """
            return
        }
        let verifier = PKCE.generateCodeVerifier()
        let challenge = PKCE.generateCodeChallenge(from: verifier)
        let state = UUID().uuidString.replacingOccurrences(of: "-", with: "")
        pendingCodeVerifier = verifier
        pendingState = state

        guard let authURL = oauthService.authorizationURL(
            clientId: oauthConfig.clientId,
            redirectURI: oauthConfig.redirectURI,
            scopes: oauthConfig.scopes,
            codeChallenge: challenge,
            state: state
        ) else {
            status = .unauthenticated
            errorMessage = "Invalid OAuth configuration"
            return
        }

        let session = ASWebAuthenticationSession(
            url: authURL,
            callbackURLScheme: URL(string: oauthConfig.redirectURI)?.scheme
        ) { [weak self] url, error in
            guard let self else { return }
            if let error { self.finishAsFailed(error.localizedDescription); return }
            guard let url else { self.finishAsFailed("Missing callback URL"); return }
            Task { await self.handleCallback(url) }
        }
        session.prefersEphemeralWebBrowserSession = false
        session.presentationContextProvider = presentationProvider
        authSession = session
        _ = session.start()
    }

    public func signOut() async {
        do {
            try await authManager.signOut()
        } catch {
            // Non-fatal; ensure UI resets
        }
        status = .unauthenticated
        errorMessage = nil
    }

    public func restoreIfPossible() async {
        if didAttemptRestore { return }
        didAttemptRestore = true
        if status == .authenticated { return }
        do {
            _ = try await authManager.getValidToken()
            status = .authenticated
        } catch {
            status = .unauthenticated
        }
    }

    private func handleCallback(_ url: URL) async {
        guard let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems else {
            finishAsFailed("Invalid callback components")
            return
        }
        if let error = items.first(where: { $0.name == "error" })?.value {
            finishAsFailed(error)
            return
        }
        guard let code = items.first(where: { $0.name == "code" })?.value,
              let returnedState = items.first(where: { $0.name == "state" })?.value,
              let verifier = pendingCodeVerifier else {
            finishAsFailed("Missing code or verifier")
            return
        }
        guard returnedState == pendingState else {
            finishAsFailed("State mismatch")
            return
        }
        do {
            let dto = try await oauthService.exchangeCode(
                code: code,
                redirectURI: oauthConfig.redirectURI,
                clientId: oauthConfig.clientId,
                codeVerifier: verifier
            )
            try await authManager.store(dto)
            status = .authenticated
            pendingCodeVerifier = nil
            pendingState = nil
        } catch {
            finishAsFailed(error.localizedDescription)
        }
    }

    private func finishAsFailed(_ message: String) {
        errorMessage = message
        status = .unauthenticated
        pendingCodeVerifier = nil
        pendingState = nil
    }

    public func getValidToken() async throws -> AuthToken {
        let dto = try await authManager.getValidToken()
        return AuthToken.from(dto)
    }

    public func clearError() { errorMessage = nil }
}

private final class WebAuthPresentationProvider: NSObject, ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        #if os(iOS)
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = scene.windows.first { return window }
        return ASPresentationAnchor()
        #elseif os(macOS)
        if let window = NSApplication.shared.mainWindow { return window }
        return ASPresentationAnchor()
        #else
        return ASPresentationAnchor()
        #endif
    }
}
