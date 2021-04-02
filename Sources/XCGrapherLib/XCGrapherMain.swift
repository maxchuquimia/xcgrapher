
import Foundation

public enum XCGrapherMain {

    public static func run(with options: XCGrapherOptions) throws {
        Log("Generating list of source files in \(options.target)")
        let xcodeproj = Xcodeproj(projectFile: options.project, target: options.target)
        let allSourceFiles = try xcodeproj.compileSourcesList()

        // MARK: - Create dependency manager lookups

        var allDependencyManagers: [DependencyManager] = []

        if options.spm {
            Log("Building Swift Package list")
            let xcodebuild = Xcodebuild(projectFile: options.project, target: options.target)
            let swiftPackageClones = try xcodebuild.swiftPackageDependencies()
            let swiftPackageManager = try SwiftPackageManager(packageClones: swiftPackageClones)
            allDependencyManagers.append(swiftPackageManager)
        }

        if options.pods {
            Log("Building Cocoapod list")
            let cocoapods = try Cocoapods(lockFile: options.podlock)
            allDependencyManagers.append(cocoapods)
        }

        if options.apple {
            Log("Building Apple framework list")
            allDependencyManagers.append(try NativeDependencyManager())
        }

        if options.force {
            Log("Ensuring all additional modules are graphed")
            // Don't ignore unknown dependencies - add a manager that claims it is reponsible for them being there.
            // MUST be last in `allDependencyManagers`.
            allDependencyManagers.append(UnmanagedDependencyManager())
        }

        // MARK: - Graphing
        Log("Graphing dependencies...")
        let grapher = XCGrapher(
            target: options.target,
            projectSourceFiles: allSourceFiles,
            dependencyManagers: allDependencyManagers
        )

        // MARK: - Writing

        let digraph = grapher.generateGraph()
        let digraphOutput = "/tmp/xcgrapher.dot"

        try digraph.build()
            .data(using: .utf8)!
            .write(to: URL(fileURLWithPath: digraphOutput))

        try Graphviz(input: digraphOutput, output: options.output).execute()

        Log("Result written to", options.output)
    }

}
