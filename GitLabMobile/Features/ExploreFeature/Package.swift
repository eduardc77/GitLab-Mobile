// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ExploreFeature",
    platforms: [
        .iOS("17.1"),
        .macOS(.v14),
        .watchOS(.v9),
        .tvOS(.v16)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "ExploreFeature",
            targets: ["ExploreFeature"])
    ],
    dependencies: [
        .package(path: "../../Core/GitLabUtilities"),
        .package(path: "../../Core/GitLabLogging"),
        .package(path: "../../Core/GitLabDesignSystem"),
        .package(path: "../../Kits/ProjectsKit")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "ExploreFeature",
            dependencies: [
                .product(name: "GitLabUtilities", package: "GitLabUtilities"),
                .product(name: "GitLabLogging", package: "GitLabLogging"),
                .product(name: "GitLabDesignSystem", package: "GitLabDesignSystem"),
                .product(name: "ProjectsDomain", package: "ProjectsKit"),
                .product(name: "ProjectsCache", package: "ProjectsKit"),
                .product(name: "ProjectsUI", package: "ProjectsKit")
            ]),
        .testTarget(
            name: "ExploreFeatureTests",
            dependencies: ["ExploreFeature"]
        )
    ]
)
