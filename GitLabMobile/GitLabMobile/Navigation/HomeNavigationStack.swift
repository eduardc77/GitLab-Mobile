//
//  HomeNavigationStack.swift
//  GitLabMobile
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import SwiftUI
import HomeFeature
import ProjectsDomain
import UserProjectsFeature
import ProjectDetailsFeature
import GitLabNavigation

struct HomeNavigationStack: View {
    @Environment(ProjectsDependencies.self) private var projectsDependencies
    @Environment(AppRouter.self) private var appRouter
    @Environment(HomeRouter.self) private var homeRouter

    var body: some View {
        @Bindable var appRouter = appRouter
        NavigationStack(path: $appRouter.homePath) {
            HomeRootView()
                .navigationDestination(for: HomeDestination.self) { destination in
                    switch destination {
                    case .projects:
                        ProjectsListView(
                            repository: projectsDependencies.repository,
                            scope: .combined,
                            navigationContext: .home(homeRouter)
                        )
                    case .groups:
                        Text("Groups")
                    case .issues:
                        Text("Issues")
                    case .mergeRequests:
                        Text("Merge Requests")
                    case .todo:
                        Text("Todo")
                    case .milestones:
                        Text("Milestones")
                    case .snippets:
                        Text("Snippets")
                    case .activity:
                        Text("Activity")
                    case .projectDetail(let project):
                        ProjectDetailsView(
                            projectId: project.id,
                            repository: projectsDependencies.repository,
                            router: homeRouter,
                            tab: .home
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
                            router: homeRouter,
                            tab: .home
                        )
                    case .projectFile(let projectId, let path, let ref, let blobSHA):
                        ProjectFileViewer(
                            projectId: projectId,
                            path: path,
                            ref: ref,
                            repository: projectsDependencies.repository,
                            blobSHA: blobSHA
                        )
                    }
                }
        }
    }
}
