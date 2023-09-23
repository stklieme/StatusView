// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "StatusView",
    platforms: [
        .macOS(.v11), .iOS(.v15), .tvOS(.v15)
    ],
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
