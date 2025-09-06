//
//  ExploreNavigationStack.swift
//  GitLabMobile
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import SwiftUI
import ExploreFeature
import ProjectsDomain
import ProjectDetailsFeature
import GitLabNavigation

struct ExploreNavigationStack: View {
    @Environment(ProjectsDependencies.self) private var projectsDependencies
    @Environment(AppRouter.self) private var appRouter
    @Environment(ExploreRouter.self) private var exploreRouter

    var body: some View {
        @Bindable var appRouter = appRouter
        NavigationStack(path: $appRouter.explorePath) {
            ExploreRootView()
                .navigationDestination(for: ExploreDestination.self) { destination in
                    switch destination {
                    case .projects:
                        ExploreProjectsView(repository: projectsDependencies.repository)
                    case .projectDetail(let project):
                        ProjectDetailsView(
                            projectId: project.id,
                            repository: projectsDependencies.repository,
                            router: exploreRouter,
                            tab: .explore
                        )
                    case .projectId(let id):
                        ProjectDetailsView(
                            projectId: id,
                            repository: projectsDependencies.repository,
                            router: exploreRouter, tab: .explore
                        )
                    case .projectReadme(let projectId, let projectPath):
                        ProjectREADMEView(
                            projectId: projectId,
                            projectPath: projectPath,
                            repository: projectsDependencies.repository
                        )
                    case .projectLicense(let projectId, let projectPath):
                        ProjectLicenseView(
                            projectId: projectId,
                            projectPath: projectPath,
                            repository: projectsDependencies.repository
                        )
                    case .projectFiles(let projectId, let ref, let path):
                        ProjectFilesView(
                            projectId: projectId,
                            repository: projectsDependencies.repository,
                            ref: ref,
                            path: path,
                            router: exploreRouter,
                            tab: .explore
                        )
                    case .projectFile(let projectId, let path, let ref, let blobSHA):
                        ProjectFileViewer(
                            projectId: projectId,
                            path: path,
                            ref: ref,
                            repository: projectsDependencies.repository,
                            blobSHA: blobSHA
                        )
                    case .users:
                        Text("Users feature coming soon")
                    case .groups:
                        Text("Groups feature coming soon")
                    case .topics:
                        Text("Topics feature coming soon")
                    case .snippets:
                        Text("Snippets feature coming soon")
                    }
                }
        }
    }
}
