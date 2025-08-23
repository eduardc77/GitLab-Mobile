//
//  HomeRouter.swift
//  GitLabNavigation
//
//  Navigation state for the Home tab.
//

import SwiftUI
import Observation
import ProjectsDomain

@MainActor
@Observable
public final class HomeRouter {
    public var path = NavigationPath()

    public init() {}

    public enum Destination: Hashable {
        case projects
        case groups
        case issues
        case mergeRequests
        case todo
        case milestones
        case snippets
        case activity
        case projectDetail(ProjectSummary)
    }

    public func navigate(to destination: Destination) { path.append(destination) }
    public func navigateBack() { if !path.isEmpty { path.removeLast() } }
    public func navigateToRoot() { path.removeLast(path.count) }
}
