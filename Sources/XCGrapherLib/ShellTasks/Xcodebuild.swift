import Foundation

struct Xcodebuild: SwiftPackageDependencySource {

    let commandArgs: String

    init(projectFile: FileManager.Path, target: String) {
        commandArgs = "-project \"\(projectFile)\" -target \"\(target)\""
    }

    init(workspaceFile: FileManager.Path, scheme: String) {
        commandArgs = "-workspace \"\(workspaceFile)\" -scheme \"\(scheme)\""
    }

    func computeCheckoutsDirectory() throws -> String {
        // Clone all the packages into $DERIVED_DATA/SourcePackages/checkouts
        let output = try execute()
            .breakIntoLines()

        // Find the $DERIVED_DATA path
        let derivedDataDir = output
            .first(where: { $0.contains(" BUILD_DIR = ") })!
            .replacingOccurrences(of: "BUILD_DIR =", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .scan {
                $0.scanAndStoreUpToAndIncluding(string: "DerivedData/")
                $0.scanAndStoreUpTo(string: "/")
            }
        return derivedDataDir.appending("/SourcePackages/checkouts")
    }

}

extension Xcodebuild: ShellTask {

    var stringRepresentation: String {
        "xcodebuild \(commandArgs) -showBuildSettings"
    }

    var commandNotFoundInstructions: String {
        "Missing command 'xcodebuild'"
    }

}
