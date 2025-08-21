// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HomeFeature",
    platforms: [
        .iOS("17.1"),
        .macOS(.v14),
        .watchOS(.v9),
        .tvOS(.v16)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "HomeFeature",
            targets: ["HomeFeature"])
    ],
    dependencies: [
        .package(path: "../AuthFeature"),
        .package(path: "../UserProjectsFeature"),
        .package(path: "../../Core/GitLabDesignSystem"),
        .package(path: "../../Kits/ProjectsKit")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "HomeFeature",
            dependencies: [
                .product(name: "AuthFeature", package: "AuthFeature"),
                .product(name: "UserProjectsFeature", package: "UserProjectsFeature"),
                .product(name: "GitLabDesignSystem", package: "GitLabDesignSystem"),
                .product(name: "ProjectsDomain", package: "ProjectsKit")
            ],
            resources: [
                .process("Resources")
            ]),
        .testTarget(
            name: "HomeFeatureTests",
            dependencies: ["HomeFeature"]
        )
    ]
)
