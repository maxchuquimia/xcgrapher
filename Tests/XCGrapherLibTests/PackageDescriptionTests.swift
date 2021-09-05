
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
            PackageDescription.Dependency(url: SUT.someDependencyDirectory),
        ]
        XCTAssertEqual(package.name, SUT.somePackageDirectory.lastPathComponent)
        XCTAssertEqual(package.path, SUT.somePackageDirectory.path)
        XCTAssertEqual(package.targets.count, 2)
        XCTAssertEqual(package.dependencies, expectedDependencies)
    }
}
