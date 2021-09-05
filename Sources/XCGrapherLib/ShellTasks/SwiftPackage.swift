
import Foundation

struct SwiftPackage {

    let clone: FileManager.Path

    func targets() throws -> [PackageDescription.Target] {
        let json = try execute()
        let jsonData = json.data(using: .utf8)!
        let description = try JSONDecoder().decode(PackageDescription.self, from: jsonData)
        return description.targets
    }

}

extension SwiftPackage: ShellTask {

    var stringRepresentation: String {
        "swift package --package-path \"\(clone)\" describe --type json"
    }

    var commandNotFoundInstructions: String {
        "Missing command 'swift'"
    }

    func recover(from error: String, with terminationStatus: Int32) -> ErrorRecoveryResult {
        guard terminationStatus == 1 && error.contains("artifact not found for target") else { return .unableToRecover }
        LogError(error)
        LogError("This is a bug with the Swift Package Manager!")
        LogError("xcgrapher will attempt to continue, however some dependencies will not be included in the graph.")

        // Build a "mocked" json that simulates `stringRepresentation`'s output so that upstream parsing doesn't fail
        let emptyPackage = PackageDescription(name: clone.lastPathComponent(), path: clone, targets: [])
        let emptyPackageJSON = String(data: try! JSONEncoder().encode(emptyPackage), encoding: .utf8)!

        return .recovered(newOutput: emptyPackageJSON)
    }

}

