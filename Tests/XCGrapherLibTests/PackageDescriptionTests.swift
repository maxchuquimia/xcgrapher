
import XCTest
import Foundation
@testable import XCGrapherLib

final class PackageDescriptionTests: XCTestCase {
    func testInitialization() throws {
        let data = try Data(fromResourceNamed: "sample-package-description", extension: "json")
        let package = try JSONDecoder().decode(PackageDescription.self, from: data)
        let expectedDependencies: [PackageDescription.Dependency] = [
            PackageDescription.Dependency(url: URL(string: "https://github.com/onevcat/Kingfisher.git")!),
            PackageDescription.Dependency(url: URL(string: "https://github.com/Moya/Moya.git")!),
            PackageDescription.Dependency(url: URL(string: "https://github.com/Alamofire/Alamofire.git")!),
            PackageDescription.Dependency(url: sampleProjectsDirectory.appendingPathComponent("SomePackageDependency")),
        ]
        XCTAssertEqual(package.name, "SomePackage")
        XCTAssertEqual(package.path, sampleProjectsDirectory.appendingPathComponent("SomePackage").path)
        XCTAssertEqual(package.targets.count, 2)
        XCTAssertEqual(package.dependencies, expectedDependencies)
    }
}
