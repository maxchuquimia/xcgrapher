
import XCTest
@testable import XCGrapherLib

final class SwiftPackageManagerTests: XCTestCase {
    private var sut: SwiftPackageManager!
    private var swiftPackageDependencySource: SwiftPackageDependencySource!

    override func tearDown() {
        swiftPackageDependencySource = nil
        sut = nil
        super.tearDown()
    }

    func testKnownSPMTargets_whenStartingPointIsXcodeproj() throws {
        // Given
        let startingPoint = StartingPoint.xcodeproj(path: SUT.xcodeproj.path, target: SUT.target, xcworkspacePath: SUT.workspace.path)
        swiftPackageDependencySource = Xcodebuild(startingPoint: startingPoint)
        // When
        try setUpSUT()
        // Then
        XCTAssertEqual(sut.knownSPMTargets.count, 35)
    }

    func testKnownSPMTargets_whenStartingPointIsXcworkspace() throws {
        // Given
        let startingPoint = StartingPoint.xcworkspace(path: SUT.workspace.path, scheme: SUT.scheme)
        swiftPackageDependencySource = Xcodebuild(startingPoint: startingPoint)
        // When
        try setUpSUT()
        // Then
        XCTAssertEqual(sut.knownSPMTargets.count, 35)
    }

    func testKnownSPMTargets_whenStartingPointIsSwiftPackage() throws {
        // Given
        let startingPoint = StartingPoint.swiftPackage(path: SUT.somePackageDirectory.path, target: SUT.target)
        swiftPackageDependencySource = SwiftBuild(packagePath: startingPoint.path, product: startingPoint.target)
        // When
        try setUpSUT()
        // Then
        XCTAssertEqual(sut.knownSPMTargets.count, 44)
    }

    private func setUpSUT() throws {
        let swiftPackageClones = try swiftPackageDependencySource.swiftPackageDependencies()
        sut = try SwiftPackageManager(packageClones: swiftPackageClones)
    }

}
