// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "SomePackage",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        .library(name: "SomePackage", targets: ["SomePackage"]),
    ],
    dependencies: [
        .package(name: "Kingfisher", url: "https://github.com/onevcat/Kingfisher.git", .upToNextMajor(from: "6.0.0")),
        .package(name: "Moya", url: "https://github.com/Moya/Moya.git", .upToNextMajor(from: "14.0.0")),
        .package(name: "Alamofire", url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.4.3")),
        .package(name: "SomePackageDependency", path: "../SomePackageDependency"),
    ],
    targets: [
        .target(
            name: "SomePackage",
            dependencies: [
                .product(name: "Kingfisher", package: "Kingfisher"),
                .product(name: "Moya", package: "Moya"),
                .product(name: "Alamofire", package: "Alamofire"),
                .product(name: "SomePackageDependency", package: "SomePackageDependency"),
            ]
        ),
        .testTarget(
            name: "SomePackageTests",
            dependencies: ["SomePackage"]
        ),
    ]
)
