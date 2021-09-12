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
