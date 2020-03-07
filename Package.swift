// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "StatusView",
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
