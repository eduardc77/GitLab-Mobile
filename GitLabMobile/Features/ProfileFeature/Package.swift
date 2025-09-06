// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ProfileFeature",
    platforms: [
        .iOS("17.1"),
        .macOS(.v14),
        .watchOS(.v9),
        .tvOS(.v16)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "ProfileFeature",
            targets: ["ProfileFeature"])
    ],
    dependencies: [
        .package(path: "../../Features/AuthFeature"),
        .package(path: "../../Core/GitLabDesignSystem"),
        .package(path: "../../Core/GitLabUtilities"),
        .package(path: "../../Core/GitLabLogging"),
        .package(path: "../../Kits/UsersKit"),
        .package(path: "../../Kits/ProjectsKit"),
        .package(path: "../../Features/UserProjectsFeature")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "ProfileFeature",
            dependencies: [
                .product(name: "AuthFeature", package: "AuthFeature"),
                .product(name: "GitLabDesignSystem", package: "GitLabDesignSystem"),
                .product(name: "GitLabUtilities", package: "GitLabUtilities"),
                .product(name: "GitLabLogging", package: "GitLabLogging"),
                .product(name: "UsersData", package: "UsersKit"),
                .product(name: "UsersDomain", package: "UsersKit"),
                .product(name: "ProjectsDomain", package: "ProjectsKit"),
                .product(name: "ProjectsCache", package: "ProjectsKit"),
                .product(name: "UserProjectsFeature", package: "UserProjectsFeature")
            ],
            resources: [
                .process("Resources")
            ]),
        .testTarget(
            name: "ProfileFeatureTests",
            dependencies: ["ProfileFeature"]
        )
    ]
)
