// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "xcgrapher",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .executable(name: "xcgrapher", targets: ["xcgrapher"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMinor(from: "0.4.0")),
        .package(url: "https://github.com/maxchuquimia/XCGrapherPluginSupport", .upToNextMinor(from: "0.0.1"))
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
            name: "XCGrapherLib", // Main source added to a separate framework for testability reasons
            dependencies: [
                "XCGrapherPluginSupport",
            ]
        ),
        .testTarget(
            name: "XCGrapherLibTests",
            dependencies: ["XCGrapherLib"]
        ),
    ]
)
