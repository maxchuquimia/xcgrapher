import Foundation
import XCGrapherPluginSupport

protocol DependencyManager {
    /// Asks the dependency manager if it is responsible for managing the framework named `module`.
    func isManaging(module: String) -> Bool

    /// Produces a list of the direct dependencies of `module`. Call it again with a single element
    /// from the returned list to discover it's dependencies ad infinitum.
    func dependencies(of module: String) -> [String]

    /// The type of dependencies this DependencyManager managers
    var pluginModuleType: XCGrapherImport.ModuleType { get }
}

extension Array where Element == DependencyManager {
    func manager(of module: String) -> DependencyManager? {
        first { $0.isManaging(module: module) }
    }
}
