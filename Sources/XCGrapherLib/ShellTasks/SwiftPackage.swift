
import Foundation

struct SwiftPackage {

    let clone: FileManager.Path

    func targets() throws -> [PackageDescription.Target] {
        return try packageDescription().targets
    }

    func packageDescription() throws -> PackageDescription {
        do {
            let json = try execute()
            let jsonData = json.data(using: .utf8)!
            return try JSONDecoder().decode(PackageDescription.self, from: jsonData)
        } catch {
            LogError(error)
            throw error
        }
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
