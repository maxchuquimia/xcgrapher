
import XCTest
@testable import XCGrapherLib

final class SwiftPackageTests: XCTestCase {
    private var sut: SwiftPackage!

    override func setUp() {
        super.setUp()
        sut = SwiftPackage(clone: SUT.somePackageDirectory.path)
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testTargets_shouldSucceed() throws {
        let targets = try sut.targets()
        XCTAssertEqual(targets.count, 2)
        XCTAssertEqual(targets[0].name, "SomePackageTests")
        XCTAssertEqual(targets[0].type, "test")
        XCTAssertEqual(targets[1].name, SUT.somePackageDirectory.lastPathComponent)
        XCTAssertEqual(targets[1].type, "library")
    }

    func testDescription_shouldSucceed() throws {
        let package = try sut.packageDescription()
        let expectedDependencies: [PackageDescription.Dependency] = [
            PackageDescription.Dependency(url: URL(string: "https://github.com/onevcat/Kingfisher.git")!),
            PackageDescription.Dependency(url: URL(string: "https://github.com/Moya/Moya.git")!),
            PackageDescription.Dependency(url: URL(string: "https://github.com/Alamofire/Alamofire.git")!),
            PackageDescription.Dependency(url: SUT.someDependencyDirectory),
        ]
        XCTAssertEqual(package.name, "SomePackage")
        XCTAssertEqual(package.path, SUT.somePackageDirectory.path)
        XCTAssertEqual(package.targets.count, 2)
        XCTAssertEqual(package.dependencies, expectedDependencies)
    }

    func testDescription_shouldThrow() throws {
        XCTAssertThrowsError(try SwiftPackage(clone: "some non-path").packageDescription())
    }

}
