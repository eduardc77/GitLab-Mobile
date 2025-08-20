// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GitLabImageLoading",
    platforms: [
        .iOS("17.1"),
        .macOS(.v14),
        .watchOS(.v9),
        .tvOS(.v16)
    ],
    products: [
        .library(name: "GitLabImageLoading", targets: ["GitLabImageLoading"]),
        .library(name: "GitLabImageLoadingKingfisher", targets: ["GitLabImageLoadingKingfisher"])        
    ],
    dependencies: [
        .package(url: "https://github.com/onevcat/Kingfisher", from: "8.5.0")
    ],
    targets: [
        .target(name: "GitLabImageLoading"),
        .target(
            name: "GitLabImageLoadingKingfisher",
            dependencies: [
                "GitLabImageLoading",
                .product(name: "Kingfisher", package: "Kingfisher")
            ]
        )
    ]
)
