//
//  ProjectLicenseView.swift
//  ProjectDetailsFeature
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//
//  View for displaying project license content
//

import SwiftUI
import ProjectsDomain
import GitLabLogging
import GitLabDesignSystem

public struct ProjectLicenseView: View {
    public let projectId: Int
    public let projectPath: String
    public let repository: any ProjectsRepository

    @State private var licenseText: String?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var didInitialLoad = false

    public init(projectId: Int, projectPath: String, repository: any ProjectsRepository) {
        self.projectId = projectId
        self.projectPath = projectPath
        self.repository = repository
    }

    public var body: some View {
        Group {
            if let licenseText {
                CodeWebContainer(text: licenseText, fileName: "LICENSE")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .overlay {
            if isLoading {
                LoadingView()
            }
        }
        .task { await initialLoadIfNeeded() }
        .navigationTitle(String(localized: ProjectDetailsL10n.license))
        .navigationBarTitleDisplayMode(.inline)
        .alert("Error", isPresented: Binding(get: { errorMessage != nil }, set: { _ in errorMessage = nil })) {
            Button(String(localized: ProjectDetailsL10n.okButtonTitle), role: .cancel) {}
        } message: { Text(errorMessage ?? "") }
    }

    @MainActor
    private func initialLoadIfNeeded() async {
        guard !didInitialLoad else { return }
        didInitialLoad = true
        await loadLicense()
    }

    private func loadLicense() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let licenseData = try await repository.license(projectId: projectId)
            let rawText = String(data: licenseData, encoding: .utf8) ?? ""
            licenseText = rawText
        } catch {
            AppLog.projects.error("License load failed for project \(projectId): \(String(describing: error))")
            errorMessage = error.localizedDescription
        }
    }
}
