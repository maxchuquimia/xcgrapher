
import Foundation
import ArgumentParser
import XCGrapherLib

typealias XCGrapherArguments = xcgrapher

/// Needs this name for `ParsableArguments`'s help text to be correct
struct xcgrapher: ParsableArguments {

    @Option(name: .long, help: "The path to the .xcodeproj")
    public var project: String?

    @Option(name: .long, help: "The name of the Xcode project target (or Swift Package product) to use as a starting point")
    public var target: String

    @Option(name: .long, help: "The path to a Swift Package directory")
    public var package: String?

    @Option(name: .long, help: "The path to the projects Podfile.lock")
    public var podlock: String = "./Podfile.lock"

    @Option(name: .shortAndLong, help: "The path to which the output PNG should be written")
    public var output: String = "/tmp/xcgrapher.png"

    @Option(name: .long, help: "The path to an XCGrapherPlugin-conforming dylib. Passing this option will override xcgrapher's default behaviour and use the plugin for consolidating the node tree instead.")
    public var plugin: String = DEFAULT_PLUGIN_LOCATION // If you're getting an error here run `make configure` to generate DEFAULT_PLUGIN_LOCATION

    @Flag(name: .long, help: "Include Apple frameworks in the graph (for --target and readable-source --spm packages)")
    public var apple: Bool = false

    @Flag(name: .long, help: "Include Swift Package Manager frameworks in the graph")
    public var spm: Bool = false

    @Flag(name: .long, help: "Include Cocoapods frameworks in the graph")
    public var pods: Bool = false

    @Flag(name: .long, help: "Show frameworks that no dependency manager claims to be managing (perhaps there are name discrepancies?). Using this option doesn't make sense unless you are also using all the other include flags relevant to your project.")
    public var force: Bool = false

    var startingPoint: StartingPoint {
        if let project = project {
            return .xcodeProject(project)
        } else {
            // Should be safe due to the implementation of validate() below
            return .swiftPackage(package!)
        }
    }

    public func validate() throws {
        var isRunningForXcodeProject = false

        if let project = project {
            isRunningForXcodeProject = true
            guard FileManager.default.directoryExists(atPath: project) else { die("'\(project)' is not a valid xcode project.") }
        }

        if !isRunningForXcodeProject {
            guard let package = package else { die("--project or --package must be provided.") }
            guard !package.isEmpty else { die("--package is invalid") }
            guard FileManager.default.fileExists(atPath: package.appendingPathComponent("Package.swift")) else { die("'\(package)' is not a valid Swift Package directory") }
        }

        guard !target.isEmpty else { die("--target must not be empty.") }
        
        if isRunningForXcodeProject {
            guard spm || apple || pods else { die("Must include at least one of --apple, --spm or --pods") }
        }
    }

}

extension XCGrapherArguments: XCGrapherOptions { }
