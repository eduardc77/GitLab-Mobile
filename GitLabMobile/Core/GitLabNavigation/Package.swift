// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GitLabNavigation",
    platforms: [
        .iOS("17.1"),
        .macOS(.v14),
        .watchOS(.v9),
        .tvOS(.v16)
    ],
    products: [
        .library(
            name: "GitLabNavigation",
            targets: ["GitLabNavigation"])
    ],
    dependencies: [
        .package(path: "../GitLabUtilities"),
        .package(path: "../GitLabLogging"),
        .package(path: "../GitLabDesignSystem"),
        .package(path: "../../Kits/ProjectsKit")
    ],
    targets: [
        .target(
            name: "GitLabNavigation",
            dependencies: [
                .product(name: "GitLabUtilities", package: "GitLabUtilities"),
                .product(name: "GitLabLogging", package: "GitLabLogging"),
                .product(name: "GitLabDesignSystem", package: "GitLabDesignSystem"),
                .product(name: "ProjectsDomain", package: "ProjectsKit")
            ]),
        // Temporarily disabled test target due to overlapping sources issue
        // .testTarget(
        //     name: "GitLabNavigationTests",
        //     dependencies: ["GitLabNavigation"]
        // )
    ]
)
