// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "xcgrapher",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .executable(name: "xcgrapher", targets: ["xcgrapher"]),
        .library(name: "XCGrapherPluginSupport", type: .dynamic, targets: ["XCGrapherPluginSupport"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMinor(from: "0.4.0"))
    ],
    targets: [
        .target(
            name: "xcgrapher",
            dependencies: [
                "XCGrapherLib",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        ),
        .target(
            name: "XCGrapherPluginSupport",
            dependencies: [],
            exclude: [
                "README.md"
            ]
        ),
        .target(
            name: "XCGrapherLib", // Main source added to a separate framework for testability reasons
            dependencies: [
                "XCGrapherPluginSupport",
//                .product(name: "XCGrapherPluginSupport", package: "xcgrapher")
            ]
        ),
        .testTarget(
            name: "XCGrapherLibTests",
            dependencies: ["XCGrapherLib"]
        ),
    ]
)
