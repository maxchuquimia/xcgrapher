
import Foundation
import XCGrapherPluginSupport

struct SwiftPackageManager {

    let knownSPMTargets: [PackageDescription.Target]

    /// - Parameter packageClones: A list of directories, each a cloned SPM dependency.
    init(packageClones: [FileManager.Path]) throws {
        func recursiveTargets(for path: String) throws -> [PackageDescription.Target] {
            let package = SwiftPackage(clone: path)
            let description = try package.packageDescription()
            let dependencyPaths = description.localDependencies.map(\.url.path)
            var results: [PackageDescription.Target] = description.targets
            for path in dependencyPaths {
                results += try recursiveTargets(for: path)
            }
            return results
        }
        knownSPMTargets = try packageClones
            .flatMap { try recursiveTargets(for: $0) }
            .unique()
    }

}

extension SwiftPackageManager: DependencyManager {

    var pluginModuleType: XCGrapherImport.ModuleType {
        .spm
    }

    func isManaging(module: String) -> Bool {
        knownSPMTargets.contains { $0.name == module }
    }

    func dependencies(of module: String) -> [String] {
        guard let target = knownSPMTargets.first(where: { $0.name == module }) else { return [] }
        return ImportFinder(fileList: target.sources).allImportedModules()
    }

}
