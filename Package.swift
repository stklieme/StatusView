// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "StatusView",
    platforms: [.macOS(.v10_10), .iOS(.v8)],
    products: [
        .library(name: "StatusView", targets: ["StatusView"]),
    ],
    targets: [
        .target(
            name: "StatusView"),
        .testTarget(
            name: "StatusViewTests",
            dependencies: ["StatusView"]),
    ]
)
