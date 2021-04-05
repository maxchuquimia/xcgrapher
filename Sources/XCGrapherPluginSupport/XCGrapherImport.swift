
import Foundation

/// Describes an `import X`.
public struct XCGrapherImport {

    /// The type of module being imported.
    public enum ModuleType {
        /// The module is the main target from the --target argument
        case target

        /// The module `XCGrapherImport.name` is an Apple framework.
        case apple

        /// The module `XCGrapherImport.name` is a Cocoapods framework.
        case cocoapods

        /// The module `XCGrapherImport.name` is a Swift Package Manager framework.
        case spm

        /// It could not be determined where the module `XCGrapherImport.name` originates.
        case other
    }

    /// The name of the module that was imported.
    public let moduleName: String

    /// The name of the module doing the importing of `moduleName`.
    public let importerName: String

    /// The type of module being imported.
    public let moduleType: ModuleType

    /// The type of the module doing the importing of `moduleName`
    public let importerType: ModuleType

    public init(moduleName: String, importerName: String, moduleType: ModuleType, importerType: ModuleType) {
        self.moduleName = moduleName
        self.importerName = importerName
        self.moduleType = moduleType
        self.importerType = importerType
    }

}
