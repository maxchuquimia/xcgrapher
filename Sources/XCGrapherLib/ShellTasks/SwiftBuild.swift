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

}

extension SwiftBuild: ShellTask {

    var stringRepresentation: String {
        // We need to first build the package (which implicitly resolves its dependencies), and then print the binary path via `--show-bin-path`
        "swift build --package-path \"\(packagePath)\" --product \"\(product)\" && swift build --package-path \"\(packagePath)\" --product \"\(product)\" --show-bin-path"
    }

    var commandNotFoundInstructions: String {
        "Missing command 'swift'"
    }

}
