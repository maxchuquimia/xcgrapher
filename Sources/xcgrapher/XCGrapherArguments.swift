
import Foundation
import ArgumentParser
import XCGrapherLib

typealias XCGrapherArguments = xcgrapher

/// Needs this name for `ParsableArguments`'s help text to be correct
struct xcgrapher: ParsableArguments {

    @Option(name: .long, help: "The path to the .xcodeproj")
    public var project: String?

    @Option(name: .long, help: "The path to the .xcworkspace")
    public var workspace: String?

    @Option(name: .long, help: "The name of the Xcode project target (or Swift Package product) to use as a starting point")
    public var target: String?

    @Option(name: .long, help: "The scheme to use alongside the .xcworkspace informed.")
    public var scheme: String?

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

    // TODO: Consider making this computed variable evaluted only once (lazy var) somehow?
    // See also: https://stackoverflow.com/a/48062573/4075379
    var startingPoint: StartingPoint {
        // Force unwraps below are safe because the preconditions are validated in the `validate()` method.
        if let workspace = workspace {
            return .xcworkspace(path: workspace, scheme: scheme!)
        } else if let project = project {
            var workspacePath: String! = workspace ?? project.replacingOccurrences(of: ".xcodeproj", with: ".xcworkspace")
            if !workspacePath.hasSuffix(".xcworkspace") {
                // Add extension to the path if it wasn't informed because, although `xcodebuild` interprets the xcworkspace
                // path correctly, the `xcodeproj` Ruby gem we're using doesn't initialize the workspace object correctly if
                // the suffix isn't present.
                workspacePath.append(".xcworkspace")
            }
            if !FileManager.default.directoryExists(atPath: workspacePath) {
                workspacePath = nil
            }
            return .xcodeproj(path: project, target: target!, xcworkspacePath: workspacePath)
        } else {
            return .swiftPackage(path: package!, target: target!)
        }
    }

    public func validate() throws {
        if let workspace = workspace {
            guard FileManager.default.directoryExists(atPath: workspace) else { die("'\(workspace)' is not a valid xcode workspace.") }
            guard let scheme = scheme else { die("When --workspace option is present, --scheme is required.") }
            guard !scheme.isEmpty else { die("--scheme must not be empty.") }
            guard spm || apple || pods else { die("Must provide at least one of --apple, --spm or --pods") }
        } else if let project = project {
            guard FileManager.default.directoryExists(atPath: project) else { die("'\(project)' is not a valid xcode project.") }
            guard let target = target else { die("When --project option is present, --target is required.") }
            guard !target.isEmpty else { die("--target must not be empty.") }
            guard spm || apple || pods else { die("Must provide at least one of --apple, --spm or --pods") }
            if spm {
                print("--project and --spm options were provided, but --workspace wasn't. If your project has local Swift Packages, you should be providing your --workspace path as well.")
            }
        } else {
            guard let package = package else { die("--workspace, --project, or --package must be provided.") }
            guard FileManager.default.fileExists(atPath: package.appendingPathComponent("Package.swift")) else { die("'\(package)' is not a valid Swift Package directory.") }
            guard let target = target else { die("When --package option is present, --target is required.") }
            guard !target.isEmpty else { die("--target must not be empty.") }
        }
    }

}

extension XCGrapherArguments: XCGrapherOptions { }
