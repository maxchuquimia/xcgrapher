import XCTest

@testable import XCGrapherLib

/// `sut` fail to execute `dot`, however we don't care as we are just reading the output text file
final class XCGrapherXcodeprojectTests: XCTestCase {

    private var sut: ((XCGrapherOptions) throws -> Void)!
    private var options: ConcreteGrapherOptions!
    let dotfile = "/tmp/xcgrapher.dot"

    override class func setUp() {
        super.setUp()

        let someAppRoot = ConcreteGrapherOptions.someAppRoot
        if !FileManager.default.directoryExists(atPath: someAppRoot.appendingPathComponent("Pods")) {
            XCTFail("Run `pod install` in \(someAppRoot) before running these tests.")
        }
    }

    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = XCGrapher.run
        options = ConcreteGrapherOptions()

        try? FileManager.default.removeItem(atPath: dotfile)
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

    static let someAppRoot = URL(fileURLWithPath: #file)
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .appendingPathComponent("SampleProjects")
        .appendingPathComponent("SomeApp")
        .path

    var startingPoint: StartingPoint = .xcodeProject(someAppRoot.appendingPathComponent("SomeApp.xcodeproj"))
    var target: String = "SomeApp"
    var podlock: String = someAppRoot.appendingPathComponent("Podfile.lock")
    var output: String = "/tmp/xcgraphertests.png"
    var apple: Bool = false
    var spm: Bool = false
    var pods: Bool = false
    var force: Bool = false
    var plugin: String = defaultXCGrapherPluginLocation()

}

private enum KnownEdges {

    static let pods = [
        ("SomeApp", "RxSwift"),
        ("SomeApp", "RxCocoa"),
        ("SomeApp", "Auth0"),
        ("SomeApp", "Moya"),
        ("SomeApp", "NSObject_Rx"),
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
        ("SomeApp", "Charts"),
        ("SomeApp", "RealmSwift"),
        ("SomeApp", "Lottie"),
        ("RealmSwift", "Realm"),
        ("Charts", "Algorithms"),
        ("Algorithms", "RealModule"),
        ("RealModule", "_NumericsShims"),
    ]

    static let apple = [
        ("SomeApp", "Foundation"),
        ("SomeApp", "AVFoundation"),
        ("SomeApp", "UIKit"),
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
