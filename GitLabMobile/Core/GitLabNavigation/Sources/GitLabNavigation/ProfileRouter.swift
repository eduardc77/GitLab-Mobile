//
//  ProfileRouter.swift
//  GitLabNavigation
//
//  Navigation state for the Profile tab.
//

import SwiftUI
import Observation
import ProjectsDomain

@MainActor
@Observable
public final class ProfileRouter {
    public var path = NavigationPath()

    public init() {}

    public enum Destination: Hashable {
        case activity
        case personalProjects
        case contributedProjects
        case starredProjects
        case groups
        case snippets
        case followers
        case following
        case settings
        case projectDetail(ProjectSummary)
    }

    public func navigate(to destination: Destination) { path.append(destination) }
    public func navigateBack() { if !path.isEmpty { path.removeLast() } }
    public func navigateToRoot() { path.removeLast(path.count) }
}
