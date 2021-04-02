
import Foundation

/// A dependency manager that always claims to be managing modules passed into it
/// but never knows what their dependencies are.
struct UnmanagedDependencyManager {

}

extension UnmanagedDependencyManager: DependencyManager {

    func isManaging(module: String) -> Bool {
        true
    }

    func dependencies(of module: String) -> [String] {
        []
    }

    var interfaceTraits: DependencyManagerTraits {
        .init(edgeColor: "#FF0000") // Red because... something probably went wrong?
    }

}
