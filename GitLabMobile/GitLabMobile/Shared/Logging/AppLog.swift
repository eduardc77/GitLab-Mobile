//
//  AppLog.swift
//  GitLabMobile
//
//  Centralized os.Logger instances for structured logging across the app.
//

import Foundation
import OSLog

public enum AppLog {
    private static let subsystem: String = Bundle.main.bundleIdentifier ?? "GitLabMobile"
    // Feature-oriented categories (stable, easy to filter in Console)
    public static let explore = Logger(subsystem: subsystem, category: "Explore")
    public static let projects = Logger(subsystem: subsystem, category: "Projects")
    public static let auth = Logger(subsystem: subsystem, category: "Auth")
}
