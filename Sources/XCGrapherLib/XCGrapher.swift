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
        case let .xcodeProject(project, target):
            let xcodeproj = Xcodeproj(projectFile: project, target: target)
            sources = try xcodeproj.compileSourcesList()
        case let .swiftPackage(packagePath, target):
            let package = SwiftPackage(clone: packagePath)
            guard let target = try package.targets().first(where: { $0.name == target }) else { die("Could not locate target '\(target)'") }
            sources = target.sources
        case let .xcodeWorkspace(workspace, _):
            sources = [try XCWorkspace(file: workspace, options: options).fakeHeaderFile()]
        }

        // MARK: - Create dependency manager lookups

        if options.spm || options.startingPoint.isSPM {
            Log("Building Swift Package list")
            var additionalPackages: [FileManager.Path] = []
            let swiftPackageDependencySource: SwiftPackageDependencySource
            switch options.startingPoint {
            case let .xcodeProject(path, target): swiftPackageDependencySource = Xcodebuild(projectFile: path, target: target)
            case let .swiftPackage(path, target): swiftPackageDependencySource = SwiftBuild(packagePath: path, product: target)
            case let .xcodeWorkspace(path, scheme):
                swiftPackageDependencySource = Xcodebuild(workspaceFile: path, scheme: scheme)
                additionalPackages = try XCWorkspace(file: path, options: options).swiftPackagesList()
            }
            let swiftPackageClones = try swiftPackageDependencySource.swiftPackageDependencies() + additionalPackages
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

        if case let .xcodeWorkspace(path, _) = options.startingPoint {
            Log("Building custom framework list")
            let projects = try XCWorkspace(file: path, options: options).xcodeProjectList()
            let customManager = try XcodeProjectAsDependencyManager(projects: projects)
            pluginHandler.customProjectManager = customManager
        }

        if options.force {
            Log("Ensuring all additional modules are graphed")
            // Don't ignore unknown dependencies - add a manager that claims it is responsible for them being there.
            // MUST be last in `allDependencyManagers`.
            let unknownManager = UnmanagedDependencyManager()
            pluginHandler.unknownManager = unknownManager
        }

        // MARK: - Graphing

        Log("Graphing...")

        let digraphTargetDisplayName: String
        switch options.startingPoint {
        case let .xcodeProject(_, target): digraphTargetDisplayName = target
        case let .swiftPackage(_, target): digraphTargetDisplayName = target
        case let .xcodeWorkspace(workspace, _): digraphTargetDisplayName = workspace.lastPathComponent()
        }

        let digraph = try pluginHandler.generateDigraph(
            target: digraphTargetDisplayName,
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
