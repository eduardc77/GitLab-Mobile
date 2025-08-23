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
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "GitLabNavigation",
            targets: ["GitLabNavigation"]),
    ],
    dependencies: [
        .package(path: "../../Kits/ProjectsKit"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "GitLabNavigation",
            dependencies: [
                .product(name: "ProjectsDomain", package: "ProjectsKit")
            ]
        ),
        .testTarget(
            name: "GitLabNavigationTests",
            dependencies: ["GitLabNavigation"]
        ),
    ]
)
