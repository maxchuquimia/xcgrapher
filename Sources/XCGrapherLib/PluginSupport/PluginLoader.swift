import Foundation
import XCGrapherPluginSupport

// Adapted from https://theswiftdev.com/building-and-loading-dynamic-libraries-at-runtime-in-swift/ (removed need for the builder pattern / simplified what is needed within the plugin itself)
enum PluginLoader {
    enum LoadError: LocalizedError {
        case libraryNotFound(path: FileManager.Path)
        case unableToOpen(reason: String)
        case symbolNotFound(symbol: String)

        var errorDescription: String? {
            let prefix = "Error opening lib: "
            switch self {
            case let .libraryNotFound(path): return prefix + "\(path) does not exist."
            case let .unableToOpen(reason): return prefix + reason
            case let .symbolNotFound(symbol): return prefix + "symbol \(symbol) not found."
            }
        }
    }

    private typealias MakeFunction = @convention(c) () -> UnsafeMutableRawPointer

    static func plugin(at path: FileManager.Path) throws -> XCGrapherPlugin {
        guard FileManager.default.fileExists(atPath: path) else { throw LoadError.libraryNotFound(path: path) }

        let openResult = dlopen(path, RTLD_NOW | RTLD_LOCAL)

        guard openResult != nil else { throw LoadError.unableToOpen(reason: String(format: "%s", dlerror() ?? "??")) }

        defer { dlclose(openResult) }

        let symbolName = "makeXCGrapherPlugin"
        let sym = dlsym(openResult, symbolName)

        guard sym != nil else { throw LoadError.symbolNotFound(symbol: symbolName) }

        let makeXCGrapherPlugin: MakeFunction = unsafeBitCast(sym, to: MakeFunction.self)
        let pluginPointer = makeXCGrapherPlugin()
        let plugin = Unmanaged<XCGrapherPlugin>.fromOpaque(pluginPointer).takeRetainedValue()
        return plugin // This is the custom subclass of XCGrapherPlugin
    }
}
