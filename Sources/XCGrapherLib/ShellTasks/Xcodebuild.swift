
import Foundation

struct Xcodebuild: SwiftPackageDependencySource {
    let startingPoint: StartingPoint

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

    func swiftPackageDependencies() throws -> [FileManager.Path] {
        let checkoutsDirectory = try computeCheckoutsDirectory()
        // Return the paths to every package clone
        let remoteDependencies = try FileManager.default.contentsOfDirectory(atPath: checkoutsDirectory)
            .map { checkoutsDirectory.appendingPathComponent($0) }
            .filter { FileManager.default.directoryExists(atPath: $0) }
            .appending(checkoutsDirectory) // We also need to check the checkouts directory itself - it seems Realm unpacks itself weirdly and puts it's Package.swift in the checkouts folder :eye_roll:
            .filter { FileManager.default.fileExists(atPath: $0.appendingPathComponent("Package.swift")) }
        let xcodeproj = Xcodeproj(startingPoint: startingPoint)
        let localDependencies = try xcodeproj.localSwiftPackageDependencies()
        return remoteDependencies + localDependencies
    }

}

extension Xcodebuild: ShellTask {

    var stringRepresentation: String {
        switch startingPoint {
        case let .xcodeproj(path, target, _):
            return """
            xcodebuild -showBuildSettings -project "\(path)" -target "\(target)"
            """
        case let .xcworkspace(path, scheme):
            return """
            xcodebuild -showBuildSettings -workspace "\(path)" -scheme "\(scheme)"
            """
        case .swiftPackage: preconditionFailure("We shouldn't start a \(Self.self) shell task with a Swift Package starting point.")
        }

    }

    var commandNotFoundInstructions: String {
        "Missing command 'xcodebuild'"
    }

}
