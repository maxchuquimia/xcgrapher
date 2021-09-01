
import XCTest
import Foundation
@testable import XCGrapherLib

extension URL {
    static func /(lhs: URL, rhs: String) -> URL {
        return lhs.appendingPathComponent(rhs)
    }

    static func /(lhs: URL, rhs: String) -> String {
        return lhs.appendingPathComponent(rhs).absoluteString
    }
}

final class PackageDescriptionTests: XCTestCase {
    func testInitialization() throws {
        let data = try Data(fromResourceNamed: "sample-package-description", extension: "json")
        let package = try JSONDecoder().decode(PackageDescription.self, from: data)
        let testsDirectory = URL(string: #file.description)!
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let expectedDependencies: [PackageDescription.Dependency] = [
            PackageDescription.Dependency(url: URL(string: "https://github.com/onevcat/Kingfisher.git")!),
            PackageDescription.Dependency(url: URL(string: "https://github.com/Moya/Moya.git")!),
            PackageDescription.Dependency(url: URL(string: "https://github.com/Alamofire/Alamofire.git")!),
            PackageDescription.Dependency(url: testsDirectory/"SampleProjects/SomePackageDependency"),
        ]
        XCTAssertEqual(package.name, "SomePackage")
        XCTAssertEqual(package.path, testsDirectory/"SampleProjects/SomePackage")
        XCTAssertEqual(package.targets.count, 2)
        XCTAssertEqual(package.dependencies, expectedDependencies)
    }
}
