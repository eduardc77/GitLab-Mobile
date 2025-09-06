//
//  ProfileNavigationStack.swift
//  GitLabMobile
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import SwiftUI
import ProfileFeature
import ProjectsDomain
import UserProjectsFeature
import ProjectDetailsFeature
import GitLabNavigation

struct ProfileNavigationStack: View {
    @Environment(ProjectsDependencies.self) private var projectsDependencies
    @Environment(AppRouter.self) private var appRouter
    @Environment(ProfileRouter.self) private var profileRouter

    var body: some View {
        @Bindable var appRouter = appRouter
        NavigationStack(path: $appRouter.profilePath) {
            ProfileRootView()
                .navigationDestination(for: ProfileDestination.self) { destination in
                    switch destination {
                    case .activity:
                        Text("Activity")
                    case .personalProjects:
                        ProjectsListView(
                            repository: projectsDependencies.repository,
                            scope: .owned,
                            navigationContext: .profile(profileRouter)
                        )
                    case .contributedProjects:
                        Text("Contributed Projects")
                    case .starredProjects:
                        Text("Starred Projects")
                    case .groups:
                        Text("Groups")
                    case .snippets:
                        Text("Snippets")
                    case .followers:
                        Text("Followers")
                    case .following:
                        Text("Following")
                    case .settings:
                        ProfileSettingsView()
                    case .projectDetail(let project):
                        ProjectDetailsView(
                            projectId: project.id,
                            repository: projectsDependencies.repository,
                            router: profileRouter, tab: .profile
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
                            router: profileRouter,
                            tab: .profile
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
