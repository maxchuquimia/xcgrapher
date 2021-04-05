
import Foundation

public enum XCGrapher {

    public static func run(with options: XCGrapherOptions) throws {
        let pluginHandler: PluginSupport
        if let plugin = options.plugin {
            Log("Loading plugin \(plugin)...")
            pluginHandler = try PluginSupport(pluginPath: plugin)
            Log("... success!")
        } else {
            pluginHandler = PluginSupport(plugin: DefaultPlugin())
        }
        
        Log("Generating list of source files in \(options.target)")
        let xcodeproj = Xcodeproj(projectFile: options.project, target: options.target)
        let allSourceFiles = try xcodeproj.compileSourcesList()

        // MARK: - Create dependency manager lookups

        if options.spm {
            Log("Building Swift Package list")
            let xcodebuild = Xcodebuild(projectFile: options.project, target: options.target)
            let swiftPackageClones = try xcodebuild.swiftPackageDependencies()
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
            projectSourceFiles: allSourceFiles
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
