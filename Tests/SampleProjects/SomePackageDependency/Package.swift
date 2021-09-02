// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "SomePackageDependency",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        .library(name: "SomePackageDependency", targets: ["SomePackageDependency"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "SomePackageDependency",
            dependencies: [],
            path: "Sources"
        ),
    ]
)
