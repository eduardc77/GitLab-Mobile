// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ProjectsKit",
    platforms: [
        .iOS("17.1"),
        .macOS(.v14),
        .watchOS(.v9),
        .tvOS(.v16)
    ],
    products: [
        .library(name: "ProjectsDomain", targets: ["ProjectsDomain"]),
        .library(name: "ProjectsData", targets: ["ProjectsData"]),
        .library(name: "ProjectsCache", targets: ["ProjectsCache"]),
        .library(name: "ProjectsUI", targets: ["ProjectsUI"])
    ],
    dependencies: [
        .package(path: "../../Core/GitLabNetwork"),
        .package(path: "../../Core/GitLabUtilities"),
        .package(path: "../../Core/GitLabPersistence"),
        .package(path: "../../Core/GitLabDesignSystem")
    ],
    targets: [
        .target(
            name: "ProjectsDomain",
            dependencies: [
                .product(name: "GitLabNetwork", package: "GitLabNetwork")
            ],
            path: "Sources/ProjectsDomain"
        ),
        .target(
            name: "ProjectsCache",
            dependencies: [
                "ProjectsDomain",
                .product(name: "GitLabUtilities", package: "GitLabUtilities"),
                .product(name: "GitLabPersistence", package: "GitLabPersistence")
            ],
            path: "Sources/ProjectsCache"
        ),
        .target(
            name: "ProjectsData",
            dependencies: [
                "ProjectsDomain",
                "ProjectsCache",
                .product(name: "GitLabNetwork", package: "GitLabNetwork"),
                .product(name: "GitLabUtilities", package: "GitLabUtilities")
            ],
            path: "Sources/ProjectsData"
        ),
        .target(
            name: "ProjectsUI",
            dependencies: [
                "ProjectsDomain",
                .product(name: "GitLabDesignSystem", package: "GitLabDesignSystem")
            ],
            path: "Sources/ProjectsUI"
        ),
        .target(
            name: "ProjectsKitTestDoubles",
            dependencies: ["ProjectsData", "ProjectsDomain"]
        ),
        .testTarget(
            name: "ProjectsKitUnitTests",
            dependencies: ["ProjectsData", "ProjectsDomain", "ProjectsKitTestDoubles"]
        )
    ]
)
