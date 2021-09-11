
import XCTest
import Foundation
@testable import XCGrapherLib

final class XcodebuildTests: XCTestCase {

    func testCheckoutsDirectory_whenStartingPointIsXcodeproj() throws {
        let sut = Xcodebuild(startingPoint: .xcodeproj(path: SUT.xcodeproj.path, target: SUT.target, xcworkspacePath: nil))
        let directoryString = try sut.computeCheckoutsDirectory()
        let directory = URL(fileURLWithPath: directoryString)
        XCTAssert(directory.isFileURL)
        var isDirectory: ObjCBool = false
        XCTAssert(FileManager.default.fileExists(atPath: directoryString, isDirectory: &isDirectory))
        XCTAssert(isDirectory.boolValue)
    }

    func testCheckoutsDirectory_whenStartingPointIsXcworkspace() throws {
        let sut = Xcodebuild(startingPoint: .xcworkspace(path: SUT.workspace.path, scheme: SUT.scheme))
        let directoryString = try sut.computeCheckoutsDirectory()
        let directory = URL(fileURLWithPath: directoryString)
        XCTAssert(directory.isFileURL)
        var isDirectory: ObjCBool = false
        XCTAssert(FileManager.default.fileExists(atPath: directoryString, isDirectory: &isDirectory))
        XCTAssert(isDirectory.boolValue)
    }

}
