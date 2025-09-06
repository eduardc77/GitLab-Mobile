// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ProjectDetailsFeature",
    platforms: [
        .iOS("17.1"),
        .macOS(.v14),
        .watchOS(.v9),
        .tvOS(.v16)
    ],
    products: [
        .library(
            name: "ProjectDetailsFeature",
            targets: ["ProjectDetailsFeature"])
    ],
    dependencies: [
        .package(path: "../../Features/AuthFeature"),
        .package(path: "../../Kits/ProjectsKit"),
        .package(path: "../../Core/GitLabDesignSystem"),
        .package(path: "../../Core/GitLabUtilities"),
        .package(path: "../../Core/GitLabNavigation")
    ],
    targets: [
        .target(
            name: "ProjectDetailsFeature",
            dependencies: [
                .product(name: "AuthFeature", package: "AuthFeature"),
                .product(name: "ProjectsDomain", package: "ProjectsKit"),
                .product(name: "ProjectsData", package: "ProjectsKit"),
                .product(name: "ProjectsUI", package: "ProjectsKit"),
                .product(name: "GitLabDesignSystem", package: "GitLabDesignSystem"),
                .product(name: "GitLabUtilities", package: "GitLabUtilities"),
                .product(name: "GitLabNavigation", package: "GitLabNavigation")
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "ProjectDetailsFeatureTests",
            dependencies: ["ProjectDetailsFeature"]
        )
    ]
)
