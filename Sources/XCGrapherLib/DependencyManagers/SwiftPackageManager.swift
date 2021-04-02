
import Foundation

struct SwiftPackageManager {

    let knownSPMTargets: [PackageDescription.Target]

    /// - Parameter packageClones: A list of directories, each a cloned SPM dependency.
    init(packageClones: [FileManager.Path]) throws {
        knownSPMTargets = try packageClones.flatMap {
            try SwiftPackage(clone: $0).targets()
        }
    }

}

extension SwiftPackageManager: DependencyManager {

    func isManaging(module: String) -> Bool {
        knownSPMTargets.contains { $0.name == module }
    }

    func dependencies(of module: String) -> [String] {
        guard let target = knownSPMTargets.first(where: { $0.name == module }) else { return [] }
        return ImportFinder(fileList: target.allSourceFiles).allImportedModules()
    }

    var interfaceTraits: DependencyManagerTraits {
        .init(edgeColor: "#F05138") // The Swift logo colour
    }

}
