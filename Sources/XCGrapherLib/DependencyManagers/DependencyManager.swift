
import Foundation

protocol DependencyManager {
    /// Asks the dependency manager if it is responsible for managing the framework named `module`.
    func isManaging(module: String) -> Bool

    /// Produces a list of the direct dependencies of `module`. Call it again with a single element
    /// from the returned list to discover it's dependencies ad infinitum.
    func dependencies(of module: String) -> [String]

    /// Info used when rendering the dependency graph image
    var interfaceTraits: DependencyManagerTraits { get }
}

struct DependencyManagerTraits {
    /// The color of the line, e.g. #FF0000
    let edgeColor: String

    static let `default` = DependencyManagerTraits(
        edgeColor: "#FF0000"
    )
}

extension Array where Element == DependencyManager {

    func manager(of module: String) -> DependencyManager? {
        first { $0.isManaging(module: module) }
    }

}
