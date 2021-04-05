
import Foundation

struct Xcodebuild {

    let projectFile: FileManager.Path
    let target: String

    func swiftPackageDependencies() throws -> [FileManager.Path] {
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

        let checkoutsDir = derivedDataDir.appending("/SourcePackages/checkouts")

        // Return the paths to every package clone
        return try FileManager.default.contentsOfDirectory(atPath: checkoutsDir)
            .map { checkoutsDir.appendingPathComponent($0) }
            .filter { FileManager.default.directoryExists(atPath: $0) }
            .appending(checkoutsDir) // We also need to check the checkouts directory itself - it seems Realm unpacks itself weirdly and puts it's Package.swift in the checkouts folder :eye_roll:
            .filter { FileManager.default.fileExists(atPath: $0.appendingPathComponent("Package.swift")) }
    }

}

extension Xcodebuild: ShellTask {

    var stringRepresentation: String {
        "xcodebuild -project \"\(projectFile)\" -target \"\(target)\" -showBuildSettings"
    }

    var commandNotFoundInstructions: String {
        "Missing command 'xcodebuild'"
    }

}
