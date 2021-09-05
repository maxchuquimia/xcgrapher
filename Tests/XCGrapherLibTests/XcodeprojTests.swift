import XCTest
@testable import XCGrapherLib

final class XcodeprojTests: XCTestCase {

    func testCompileSourcesList_whenStartingPointIsXcodeproj() throws {
        let sut = Xcodeproj(startingPoint: .xcodeproj(path: SUT.xcodeproj.path, target: SUT.target, xcworkspacePath: SUT.workspace.path))
        let sourceList = try sut.compileSourcesList().sorted()
        let dir = SUT.xcodeproj.parent.appendingPathComponent("SomeApp")
        let expectedSources = [
            dir.appendingPathComponent("AppDelegate.swift").path,
            dir.appendingPathComponent("Imports/Apple/AVFoundationImports.swift").path,
            dir.appendingPathComponent("Imports/Apple/FoundationImportrs.swift").path,
            dir.appendingPathComponent("Imports/Apple/UIKitImports.swift").path,
            dir.appendingPathComponent("Imports/Pods/Auth0Imports.swift").path,
            dir.appendingPathComponent("Imports/Pods/MoyaImports.swift").path,
            dir.appendingPathComponent("Imports/Pods/RxImports.swift").path,
            dir.appendingPathComponent("Imports/SPM/ChartsImports.swift").path,
            dir.appendingPathComponent("Imports/SPM/LottieImports.swift").path,
            dir.appendingPathComponent("Imports/SPM/RealmImports.swift").path,
            dir.appendingPathComponent("SceneDelegate.swift").path,
        ].sorted()
        for (source, expectedSource) in zip(sourceList, expectedSources) {
            XCTAssertEqual(source, expectedSource)
        }
    }

    func testLocalSwiftPackageDependencies_whenStartingPointIsXcodeproj() throws {
        let sut = Xcodeproj(startingPoint: .xcodeproj(path: SUT.xcodeproj.path, target: SUT.target, xcworkspacePath: SUT.workspace.path))
        let localDependencies = try sut.localSwiftPackageDependencies()
        XCTAssertEqual(localDependencies, [SUT.someDependencyDirectory.path])
    }

    func testCompileSourcesList_whenStartingPointIsXcworkspace() throws {
        let sut = Xcodeproj(startingPoint: .xcworkspace(path: SUT.workspace.path, scheme: SUT.scheme))
        let sourceList = try sut.compileSourcesList().sorted()
        let dir = SUT.workspace.parent.appendingPathComponent("SomeApp")
        let expectedSources = [
            dir.appendingPathComponent("AppDelegate.swift").path,
            dir.appendingPathComponent("Imports/Apple/AVFoundationImports.swift").path,
            dir.appendingPathComponent("Imports/Apple/FoundationImportrs.swift").path,
            dir.appendingPathComponent("Imports/Apple/UIKitImports.swift").path,
            dir.appendingPathComponent("Imports/Pods/Auth0Imports.swift").path,
            dir.appendingPathComponent("Imports/Pods/MoyaImports.swift").path,
            dir.appendingPathComponent("Imports/Pods/RxImports.swift").path,
            dir.appendingPathComponent("Imports/SPM/ChartsImports.swift").path,
            dir.appendingPathComponent("Imports/SPM/LottieImports.swift").path,
            dir.appendingPathComponent("Imports/SPM/RealmImports.swift").path,
            dir.appendingPathComponent("SceneDelegate.swift").path,
        ].sorted()
        for (source, expectedSource) in zip(sourceList, expectedSources) {
            XCTAssertEqual(source, expectedSource)
        }
    }

    func testLocalSwiftPackageDependencies_whenStartingPointIsXcworkspace() throws {
        let sut = Xcodeproj(startingPoint: .xcworkspace(path: SUT.workspace.path, scheme: SUT.scheme))
        let localDependencies = try sut.localSwiftPackageDependencies()
        XCTAssertEqual(localDependencies, [SUT.someDependencyDirectory.path])
    }
}
