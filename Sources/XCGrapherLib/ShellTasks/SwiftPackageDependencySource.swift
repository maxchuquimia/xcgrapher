import Foundation

protocol SwiftPackageDependencySource {
    func computeCheckoutsDirectory() throws -> String
    func swiftPackageDependencies() throws -> [FileManager.Path]
}
