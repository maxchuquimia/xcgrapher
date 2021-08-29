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
}

struct PackageDescription: Codable {
    struct Target: Codable {
        let name: String
        let path: String
        let sources: [String]
        let type: String

        var allSourceFiles: [FileManager.Path] {
            sources.map { path.appendingPathComponent($0) }
        }
    }

    let name: String
    let path: String
    let targets: [Target]
}
