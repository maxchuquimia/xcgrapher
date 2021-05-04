// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "SomePackage",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        .library(
            name: "SomePackage",
            targets: ["SomePackage"]),
    ],
    dependencies: [
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "6.0.0"),
        .package(url: "https://github.com/Moya/Moya.git", .upToNextMajor(from: "14.0.0")),
    ],
    targets: [
        .target(
            name: "SomePackage",
            dependencies: [
                "Kingfisher",
                "Moya",
            ]
        ),
        .testTarget(
            name: "SomePackageTests",
            dependencies: ["SomePackage"]
        ),
    ]
)
