// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BlockInspector",
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),
        .package(url: "https://github.com/yechentide/CoreBedrock.git", revision: "9b5cceb8a9a623fcb940ca3f3cf994b5eebdb589"),
    ],
    targets: [
        .executableTarget(
            name: "BlockInspector",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "CoreBedrock", package: "CoreBedrock")
            ]
        ),
    ]
)
