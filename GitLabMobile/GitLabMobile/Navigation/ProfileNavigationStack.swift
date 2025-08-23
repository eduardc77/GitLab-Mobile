//
//  ProfileNavigationStack.swift
//  GitLabMobile
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import SwiftUI
import ProfileFeature
import GitLabNavigation
import ProjectsDomain
import UserProjectsFeature
import ProjectDetailsFeature

struct ProfileNavigationStack: View {
    @Environment(ProjectsDependencies.self) private var projectsDependencies
    @State private var router = ProfileRouter()

    var body: some View {
        NavigationStack(path: $router.path) {
            ProfileRootView()
                .navigationDestination(for: ProfileRouter.Destination.self) { destination in
                    switch destination {
                    case .activity:
                        Text("Activity")
                    case .personalProjects:
                        ProjectsListView(
                            repository: projectsDependencies.repository,
                            scope: .owned,
                            navigationContext: .profile(router))
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
                        ProjectDetailsView(projectId: project.id, repository: projectsDependencies.repository)
                    }
                }
        }
        .environment(router)
    }
}
