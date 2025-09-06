//
//  ProjectFileViewer.swift
//  ProjectDetailsFeature
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//
//  View for displaying project files and their contents
//

import SwiftUI
import ProjectsDomain
import GitLabLogging
import GitLabDesignSystem
import GitLabNetwork

public struct ProjectFileViewer: View {
    public let projectId: Int
    public let path: String
    public let ref: String?
    public let repository: any ProjectsRepository
    public let blobSHA: String?
    public var lineAnchor: String?

    @State private var text: String?
    @State private var fileURL: URL?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var didInitialLoad = false
    @Environment(\.colorScheme) private var colorScheme

    public init(projectId: Int, path: String, ref: String?, repository: any ProjectsRepository, blobSHA: String?, lineAnchor: String? = nil) {
        self.projectId = projectId
        self.path = path
        self.ref = ref
        self.repository = repository
        self.blobSHA = blobSHA
        self.lineAnchor = lineAnchor
    }

    public var body: some View {
        Group {
            if isImageFile, let url = fileURL {
                AsyncImageView(url: url, contentMode: .fit) { ProgressView() }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let text {
                CodeWebContainer(text: text, fileName: (path as NSString).lastPathComponent, lineAnchor: lineAnchor)
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
        .navigationTitle((path as NSString).lastPathComponent)
        .alert("Error", isPresented: Binding(get: { errorMessage != nil }, set: { _ in errorMessage = nil })) {
            Button("OK", role: .cancel) {}
        } message: { Text(errorMessage ?? "") }
    }

    @MainActor
    private func initialLoadIfNeeded() async {
        guard !didInitialLoad else { return }
        didInitialLoad = true

        if isImageFile {
            // Load URL for images
            fileURL = await rawFileURL(projectId: projectId, path: path, ref: ref)
            return
        }

        // Load text content for non-images
        await loadFile()
    }

    private func loadFile() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let data = try await fetchFileData()
            let rawText = String(data: data, encoding: .utf8) ?? ""
            text = rawText
        } catch {
            AppLog.projects.error("File load failed for path=\(path) ref=\(ref ?? "<none>"): \(String(describing: error))")
            errorMessage = error.localizedDescription
        }
    }

    private func fetchFileData() async throws -> Data {
        // Encode path components safely
        let encodedFilePath = path.split(separator: "/", omittingEmptySubsequences: false)
            .map { component -> String in
                let allowed = CharacterSet.urlPathAllowed.subtracting(CharacterSet(charactersIn: "/"))
                return String(component)
                    .addingPercentEncoding(withAllowedCharacters: allowed)?
                    .replacingOccurrences(of: ".", with: "%2E") ?? String(component)
            }
            .joined(separator: "%2F")

        AppLog.projects.debug("RAW path try project=\(projectId) path=\(path) encoded=\(encodedFilePath)")
        do {
            return try await repository.rawFile(projectId: projectId, path: path, ref: ref)
        } catch {
            AppLog.projects.error("RAW path failed, attempting blob SHA fallback")
            if let blobSHA {
                return try await repository.rawBlob(projectId: projectId, sha: blobSHA)
            } else {
                throw error
            }
        }
    }

    // MARK: - Helpers
    private var isImageFile: Bool {
        let ext = ((path as NSString).pathExtension.lowercased())
        return ["png", "jpg", "jpeg", "gif", "webp", "svg", "bmp", "tiff", "tif", "heic", "heif"].contains(ext)
    }

    private func rawFileURL(projectId: Int, path: String, ref: String?) async -> URL? {
        do {
            let config = try AppNetworkingConfig.loadFromInfoPlist()
            return try await repository.rawFileURL(projectId: projectId, path: path, ref: ref, networkingConfig: config)
        } catch {
            AppLog.projects.error("Failed to build raw file URL for project \(projectId), path: \(path): \(error.localizedDescription)")
            return nil
        }
    }
}
