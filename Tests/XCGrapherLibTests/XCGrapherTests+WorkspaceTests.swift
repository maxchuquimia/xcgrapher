
import XCTest

@testable import XCGrapherLib

/// `sut` fail to execute `dot`, however we don't care as we are just reading the output text file
final class XCGrapherWorkspaceTests: XCTestCase {

    private var sut: ((XCGrapherOptions) throws -> Void)!
    private var options: ConcreteGrapherOptions!
    let dotfile = "/tmp/xcgrapher.dot"

    override class func setUp() {
        super.setUp()

        if !FileManager.default.directoryExists(atPath: SUT.xcodeproj.parent.appendingPathComponent("Pods").path) {
            XCTFail("Run `pod install` in \(SUT.xcodeproj.parent) before running these tests.")
        }
    }

    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = XCGrapher.run
        options = ConcreteGrapherOptions()

        try? FileManager.default.removeItem(atPath: dotfile)
    }

    func testPodfileLock_shouldExist() {
        XCTAssert(FileManager.default.fileExists(atPath: options.podlock))
    }

    func testSomeAppPods() throws {
        // GIVEN we only pass --pods to xcgrapher
        options.pods = true

        // WHEN we generate a digraph
        try? sut(options)
        let digraph = try String(contentsOfFile: dotfile)

        // THEN the digraph only contains these edges
        let expectedEdges = KnownEdges.pods

        XCGrapherAssertDigraphIsMadeFromEdges(digraph, expectedEdges)
    }

    func testSomeAppSPM() throws {
        // GIVEN we only pass --spm to xcgrapher
        options.spm = true

        // WHEN we generate a digraph
        try? sut(options)
        let digraph = try String(contentsOfFile: dotfile)

        // THEN the digraph only contains these edges
        let expectedEdges = KnownEdges.spm

        XCGrapherAssertDigraphIsMadeFromEdges(digraph, expectedEdges)
    }

    func testSomeAppPodsAndSPM() throws {
        // GIVEN we pass both --spm and --pods to xcgrapher
        options.spm = true
        options.pods = true

        // WHEN we generate a digraph
        try? sut(options)
        let digraph = try String(contentsOfFile: dotfile)

        // THEN the digraph only contains these edges
        let expectedEdges = KnownEdges.spm + KnownEdges.pods

        XCGrapherAssertDigraphIsMadeFromEdges(digraph, expectedEdges)
    }

    func testSomeAppApple() throws {
        // GIVEN we only pass --apple to xcgrapher
        options.apple = true

        // WHEN we generate a digraph
        try? sut(options)
        let digraph = try String(contentsOfFile: dotfile)

        // THEN the digraph only contains these edges
        let expectedEdges = KnownEdges.apple

        XCGrapherAssertDigraphIsMadeFromEdges(digraph, expectedEdges)
    }

    func testSomeAppAppleAndSPM() throws {
        // GIVEN we pass --apple and --spm to xcgrapher
        options.apple = true
        options.spm = true

        // WHEN we generate a digraph
        try? sut(options)
        let digraph = try String(contentsOfFile: dotfile)

        // THEN the digraph only contains these edges
        let expectedEdges = KnownEdges.apple + KnownEdges.spm + KnownEdges.appleFromSPM

        XCGrapherAssertDigraphIsMadeFromEdges(digraph, expectedEdges)
    }

    func testSomeAppAppleAndSPMAndPods() throws {
        // GIVEN we pass --apple and --spm and --pods to xcgrapher
        options.apple = true
        options.spm = true
        options.pods = true

        // WHEN we generate a digraph
        try? sut(options)
        let digraph = try String(contentsOfFile: dotfile)

        // THEN the digraph only contains these edges
        let expectedEdges = KnownEdges.apple + KnownEdges.spm + KnownEdges.appleFromSPM + KnownEdges.pods + KnownEdges.appleFromPods

        XCGrapherAssertDigraphIsMadeFromEdges(digraph, expectedEdges)
    }

}

private struct ConcreteGrapherOptions: XCGrapherOptions {

    var startingPoint: StartingPoint = .xcworkspace(path: SUT.workspace.path, scheme: SUT.scheme)
    var podlock: String = SUT.workspace.parent.appendingPathComponent("Podfile.lock").path
    var output: String = "/tmp/xcgraphertests.png"
    var apple: Bool = false
    var spm: Bool = false
    var pods: Bool = false
    var force: Bool = false
    var plugin: String = defaultXCGrapherPluginLocation()

}

private enum KnownEdges {

    static let pods = [
        (SUT.scheme, "RxSwift"),
        (SUT.scheme, "RxCocoa"),
        (SUT.scheme, "Auth0"),
        (SUT.scheme, "Moya"),
        (SUT.scheme, "NSObject_Rx"),
        ("NSObject_Rx", "RxSwift"),
        ("RxCocoa", "RxSwift"),
        ("RxCocoa", "RxRelay"),
        ("RxRelay", "RxSwift"),
        ("Moya", "Moya/Core"),
        ("Moya/Core", "Alamofire"),
        ("Auth0", "JWTDecode"),
        ("Auth0", "SimpleKeychain"),
    ]

    static let spm = [
        (SUT.scheme, "Charts"),
        (SUT.scheme, "RealmSwift"),
        (SUT.scheme, "Lottie"),
        ("RealmSwift", "Realm"),
        ("Charts", "Algorithms"),
        ("Algorithms", "RealModule"),
        ("RealModule", "_NumericsShims"),
    ]

    static let apple = [
        (SUT.scheme, "Foundation"),
        (SUT.scheme, "AVFoundation"),
        (SUT.scheme, "UIKit"),
    ]

    static let appleFromSPM = [
        ("RealmSwift", "Combine"),
        ("RealmSwift", "SwiftUI"),
        ("RealmSwift", "Foundation"),
        ("Lottie", "Foundation"),
        ("Lottie", "AppKit"),
        ("Lottie", "CoreGraphics"),
        ("Lottie", "CoreText"),
        ("Lottie", "QuartzCore"),
        ("Lottie", "UIKit"),
        ("Charts", "Foundation"),
        ("Charts", "AppKit"),
        ("Charts", "CoreGraphics"),
        ("Charts", "QuartzCore"),
        ("Charts", "Cocoa"),
        ("Charts", "Quartz"),
        ("Charts", "UIKit"),
    ]

    static let appleFromPods: [(String, String)] = [
        // Unsupported at this time
    ]

}
