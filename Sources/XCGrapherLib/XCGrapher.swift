
import Foundation

public enum XCGrapher {

    public static func run(with options: XCGrapherOptions) throws {

        // MARK: - Load the plugin

        Log("Loading plugin \(options.plugin)")
        let pluginHandler = try PluginSupport(pluginPath: options.plugin)

        // MARK: - Prepare the --target source file list
        Log("Generating list of source files in \(options.startingPoint.localisedName)")
        var sources: [FileManager.Path] = []
        switch options.startingPoint {
        case let .xcodeProject(project):
            let xcodeproj = Xcodeproj(projectFile: project, target: options.target)
            sources = try xcodeproj.compileSourcesList()
        case let .swiftPackage(packagePath):
            let package = SwiftPackage(clone: packagePath)
            guard let target = try package.targets().first(where: { $0.name == options.target }) else { die("Could not locate target '\(options.target)'") }
            sources = target.sources
        }

        // MARK: - Create dependency manager lookups

        if options.spm || options.startingPoint.isSPM {
            Log("Building Swift Package list")
            let swiftPackageDependencySource: SwiftPackageDependencySource = {
                if options.startingPoint.isSPM {
                    return SwiftBuild(packagePath: options.startingPoint.path, product: options.target)
                } else {
                    return Xcodebuild(projectFile: options.startingPoint.path, target: options.target)
                }
            }()
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
            target: options.target,
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
