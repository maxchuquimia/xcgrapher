
import XCTest
import Foundation
@testable import XCGrapherLib

final class SwiftBuildTests: XCTestCase {
    private var sut: SwiftBuild!

    override func setUp() {
        super.setUp()
        sut = SwiftBuild(packagePath: SUT.somePackageDirectory.path, product: SUT.somePackageDirectory.lastPathComponent)
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testCheckoutsDirectory() throws {
        let directoryString = try sut.computeCheckoutsDirectory()
        let directory = URL(fileURLWithPath: directoryString)
        XCTAssert(directory.isFileURL)
        var isDirectory: ObjCBool = false
        XCTAssert(FileManager.default.fileExists(atPath: directoryString, isDirectory: &isDirectory))
        XCTAssert(isDirectory.boolValue)
    }

    func testSwiftPackageDependencies() throws {
        let dependencies = try sut.swiftPackageDependencies()
        XCTAssert(dependencies.contains(where: { $0.hasSuffix("Moya") }))
        XCTAssert(dependencies.contains(where: { $0.hasSuffix("Alamofire") }))
        XCTAssert(dependencies.contains(where: { $0.hasSuffix("Logger") }))
        XCTAssert(dependencies.contains(where: { $0.hasSuffix("Yams") }))
        XCTAssert(dependencies.contains(where: { $0.hasSuffix("RxSwift") }))
        XCTAssert(dependencies.contains(where: { $0.hasSuffix("Quick") }))
        XCTAssert(dependencies.contains(where: { $0.hasSuffix("OHHTTPStubs") }))
        XCTAssert(dependencies.contains(where: { $0.hasSuffix("ReactiveSwift") }))
        XCTAssert(dependencies.contains(where: { $0.hasSuffix("SwiftShell") }))
        XCTAssert(dependencies.contains(where: { $0.hasSuffix("Kingfisher") }))
        XCTAssert(dependencies.contains(where: { $0.hasSuffix("Rocket") }))
        XCTAssert(dependencies.contains(where: { $0.hasSuffix("Nimble") }))
        XCTAssert(dependencies.contains(where: { $0.hasSuffix("PackageConfig") }))
    }

}
