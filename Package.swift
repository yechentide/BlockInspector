// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BlockInspector",
    platforms: [
        .macOS(.v11),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),
        .package(url: "https://github.com/yechentide/CoreBedrock.git", revision: "f24e53e7fc90dde4ea5dec211cf4cd968b74822c"),
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
