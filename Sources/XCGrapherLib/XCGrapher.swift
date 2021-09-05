
import Foundation

public enum XCGrapher {

    public static func run(with options: XCGrapherOptions) throws {

        // MARK: - Load the plugin

        Log("Loading plugin \(options.plugin)")
        let pluginHandler = try PluginSupport(pluginPath: options.plugin)

        // MARK: - Prepare the --target source file list
        Log("Generating list of source files in \(options.startingPoint.localisedName)")
        let sources: [FileManager.Path]
        switch options.startingPoint {
        case .xcodeproj, .xcworkspace:
            let xcodeproj = Xcodeproj(startingPoint: options.startingPoint)
            sources = try xcodeproj.compileSourcesList()
        case let .swiftPackage(path, targetName):
            let package = SwiftPackage(clone: path)
            guard let target = try package.targets().first(where: { $0.name == targetName }) else { die("Could not locate target '\(targetName)'") }
            sources = target.sources
        }

        // MARK: - Create dependency manager lookups

        if options.spm {
            Log("Building Swift Package list")
            let swiftPackageDependencySource: SwiftPackageDependencySource
            switch options.startingPoint {
            case .xcodeproj, .xcworkspace: swiftPackageDependencySource = Xcodebuild(startingPoint: options.startingPoint)
            case let .swiftPackage(path, target): swiftPackageDependencySource = SwiftBuild(packagePath: path, product: target)
            }
            let swiftPackageClones = try swiftPackageDependencySource.swiftPackageDependencies()
            let swiftPackageManager = try SwiftPackageManager(packageClones: swiftPackageClones)
            pluginHandler.swiftPackageManager = swiftPackageManager
        }

        if options.pods {
            Log("Building Cocoapod list")
            let cocoapodsManager = try CocoapodsManager(lockFile: options.podlock)
            pluginHandler.cocoapodsManager = cocoapodsManager
        }

        if options.apple {
            Log("Building Apple framework list")
            let nativeManager = try NativeDependencyManager()
            pluginHandler.nativeManager = nativeManager
        }

        if options.force {
            Log("Ensuring all additional modules are graphed")
            // Don't ignore unknown dependencies - add a manager that claims it is reponsible for them being there.
            // MUST be last in `allDependencyManagers`.
            let unknownManager = UnmanagedDependencyManager()
            pluginHandler.unknownManager = unknownManager
        }

        // MARK: - Graphing

        Log("Graphing...")

        let digraph = try pluginHandler.generateDigraph(
            target: options.startingPoint.target,
            projectSourceFiles: sources
        )

        // MARK: - Writing

        let digraphOutput = "/tmp/xcgrapher.dot"

        try digraph.build()
            .data(using: .utf8)!
            .write(to: URL(fileURLWithPath: digraphOutput))

        try Graphviz(input: digraphOutput, output: options.output).execute()

        Log("Result written to", options.output)
    }

}
