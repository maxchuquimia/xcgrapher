import XCTest
@testable import XCGrapherLib

final class XcodeprojTests: XCTestCase {
    private var sut: Xcodeproj!

    override func setUp() {
        super.setUp()
        let someAppXcodeProject = sampleProjectsDirectory
            .appendingPathComponent("SomeApp")
            .appendingPathComponent("SomeApp.xcodeproj")
            .path
        sut = Xcodeproj(projectFile: someAppXcodeProject, target: "SomeApp")
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testCompileSourcesList() throws {
        let sourceList = try sut.compileSourcesList().sorted()
        let someAppSourcesDirectory = sampleProjectsDirectory.appendingPathComponent("SomeApp/SomeApp")
        let expectedSources = [
            someAppSourcesDirectory.appendingPathComponent("AppDelegate.swift").path,
            someAppSourcesDirectory.appendingPathComponent("Imports/Apple/AVFoundationImports.swift").path,
            someAppSourcesDirectory.appendingPathComponent("Imports/Apple/FoundationImportrs.swift").path,
            someAppSourcesDirectory.appendingPathComponent("Imports/Apple/UIKitImports.swift").path,
            someAppSourcesDirectory.appendingPathComponent("Imports/Pods/Auth0Imports.swift").path,
            someAppSourcesDirectory.appendingPathComponent("Imports/Pods/MoyaImports.swift").path,
            someAppSourcesDirectory.appendingPathComponent("Imports/Pods/RxImports.swift").path,
            someAppSourcesDirectory.appendingPathComponent("Imports/SPM/ChartsImports.swift").path,
            someAppSourcesDirectory.appendingPathComponent("Imports/SPM/LottieImports.swift").path,
            someAppSourcesDirectory.appendingPathComponent("Imports/SPM/RealmImports.swift").path,
            someAppSourcesDirectory.appendingPathComponent("SceneDelegate.swift").path,
        ].sorted()
        for (source, expectedSource) in zip(sourceList, expectedSources) {
            XCTAssertEqual(source, expectedSource)
        }
    }

    func testLocalSwiftPackageDependencies() throws {
        let localDependencies = try sut.localSwiftPackageDependencies()
        let somePackageDependencyPath = sampleProjectsDirectory
            .appendingPathComponent("SomePackageDependency")
            .path
        XCTAssertEqual(localDependencies, [somePackageDependencyPath])
    }
}
