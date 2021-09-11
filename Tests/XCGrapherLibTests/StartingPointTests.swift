
import XCTest
import Foundation
@testable import XCGrapherLib

final class StartingPointTests: XCTestCase {
    
    func testIsSPM() throws {
        XCTAssertFalse(StartingPoint.xcodeproj(path: "", target: "", xcworkspacePath: nil).isSPM)
        XCTAssertFalse(StartingPoint.xcworkspace(path: "", scheme: "").isSPM)
        XCTAssert(StartingPoint.swiftPackage(path: "", target: "").isSPM)
    }

    func testPath() {
        let xcodeprojPath = "xcodeproj/test/path"
        let xcworkspacePath = "xcworkspace/test/path"
        let swiftPackagePath = "swift/package/test/path"
        XCTAssertEqual(StartingPoint.xcodeproj(path: xcodeprojPath, target: "", xcworkspacePath: nil).path, xcodeprojPath)
        XCTAssertEqual(StartingPoint.xcworkspace(path: xcworkspacePath, scheme: "").path, xcworkspacePath)
        XCTAssertEqual(StartingPoint.swiftPackage(path: swiftPackagePath, target: "").path, swiftPackagePath)
    }

    func testXcworkspacePath() {
        let xcodeprojWorkspacePath = "xcodeproj/test/path"
        let xcworkspacePath = "xcworkspace/test/path"
        XCTAssertEqual(StartingPoint.xcodeproj(path: "", target: "", xcworkspacePath: xcodeprojWorkspacePath).xcworkspacePath, xcodeprojWorkspacePath)
        XCTAssertEqual(StartingPoint.xcworkspace(path: xcworkspacePath, scheme: "").xcworkspacePath, xcworkspacePath)
        XCTAssertNil(StartingPoint.swiftPackage(path: "", target: "").xcworkspacePath)
    }

    func testTarget() {
        let xcodeprojTarget = "xcodeproj-target"
        let xcworkspaceScheme = "xcworkspace-scheme"
        let swiftPackageTarget = "swift-package-target"
        XCTAssertEqual(StartingPoint.xcodeproj(path: "", target: xcodeprojTarget, xcworkspacePath: nil).target, xcodeprojTarget)
        XCTAssertEqual(StartingPoint.xcworkspace(path: "", scheme: xcworkspaceScheme).target, xcworkspaceScheme)
        XCTAssertEqual(StartingPoint.swiftPackage(path: "", target: swiftPackageTarget).target, swiftPackageTarget)
    }

}
