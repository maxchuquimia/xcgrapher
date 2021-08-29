
import Foundation
import XCGrapherPluginSupport

/// A dependency manager that always claims to be managing modules passed into it
/// but never knows what their dependencies are.
struct UnmanagedDependencyManager {}

extension UnmanagedDependencyManager: DependencyManager {
    var pluginModuleType: XCGrapherImport.ModuleType {
        .other
    }

    func isManaging(module _: String) -> Bool {
        true
    }

    func dependencies(of _: String) -> [String] {
        []
    }
}
