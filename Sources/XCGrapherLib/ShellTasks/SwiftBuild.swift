import Foundation

struct SwiftBuild: SwiftPackageDependencySource {
    let packagePath: FileManager.Path
    let product: String

    func computeCheckoutsDirectory() throws -> String {
        // Clone all the packages into the default checkout directory for Swift Packages
        let buildDirectory = try execute()
            .breakIntoLines()
            .dropLast()
            .last!
        // `URL(fileURLWithPath:)` adds a `file://` prefix, which the system can't locate for some reason.
        let checkoutsDirectory = URL(string: buildDirectory)!
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("checkouts")
        return checkoutsDirectory.absoluteString
    }

    func swiftPackageDependencies() throws -> [FileManager.Path] {
        let checkoutsDirectory = try computeCheckoutsDirectory()
        // Return the paths to every package clone
        let remoteDependencies = try FileManager.default.contentsOfDirectory(atPath: checkoutsDirectory)
            .map { checkoutsDirectory.appendingPathComponent($0) }
            .filter { FileManager.default.directoryExists(atPath: $0) }
            .appending(checkoutsDirectory) // We also need to check the checkouts directory itself - it seems Realm unpacks itself weirdly and puts it's Package.swift in the checkouts folder :eye_roll:
            .filter { FileManager.default.fileExists(atPath: $0.appendingPathComponent("Package.swift")) }

        let package = SwiftPackage(clone: packagePath)
        let localDependencies: [FileManager.Path] = try package
            .packageDescription()
            .localDependencies
            .map { $0.url.absoluteString }
        return remoteDependencies + localDependencies
    }
}

extension SwiftBuild: ShellTask {
    var stringRepresentation: String {
        // We need to first resolve the package dependencies, and then print the binary path via `--show-bin-path`
        "swift package resolve --package-path \"\(packagePath)\" && swift build --package-path \"\(packagePath)\" --product \"\(product)\" --show-bin-path"
    }

    var commandNotFoundInstructions: String {
        "Missing command 'swift'"
    }
}
