import Foundation

protocol SwiftPackageDependencySource {

    func computeCheckoutsDirectory() throws -> String
    func swiftPackageDependencies() throws -> [FileManager.Path]

}

extension SwiftPackageDependencySource {

    func swiftPackageDependencies() throws -> [FileManager.Path] {
        let checkoutsDirectory = try computeCheckoutsDirectory()
        // Return the paths to every package clone
        return try FileManager.default.contentsOfDirectory(atPath: checkoutsDirectory)
            .map { checkoutsDirectory.appendingPathComponent($0) }
            .filter { FileManager.default.directoryExists(atPath: $0) }
            .appending(checkoutsDirectory) // We also need to check the checkouts directory itself - it seems Realm unpacks itself weirdly and puts it's Package.swift in the checkouts folder :eye_roll:
            .filter { FileManager.default.fileExists(atPath: $0.appendingPathComponent("Package.swift")) }
    }

}
