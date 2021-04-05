
import Foundation
import XCGrapherPluginSupport

// Adapted from https://theswiftdev.com/building-and-loading-dynamic-libraries-at-runtime-in-swift/
enum PluginLoader {

    enum LoadError: LocalizedError {
        case opening(description: String)
        case symbolNotFound(description: String)

        var errorDescription: String? {
            let prefix = "Error opening lib: "
            switch self {
            case let .opening(description): return prefix + description
            case let .symbolNotFound(description): return prefix + description
            }
        }

    }

    private typealias InitFunction = @convention(c) () -> UnsafeMutableRawPointer

    static func plugin(at path: FileManager.Path) throws -> XCGrapherPlugin {
        let openResult = dlopen(path, RTLD_NOW|RTLD_LOCAL)

        guard openResult != nil else { throw LoadError.opening(description: "\(String(format: "%s", dlerror() ?? "??" )), path: \(path)") }

        defer { dlclose(openResult) }

        let symbolName = "createXCGrapherPlugin"
        let sym = dlsym(openResult, symbolName)

        guard sym != nil else { throw LoadError.symbolNotFound(description: "symbol \(symbolName) not found, path: \(path)") }

        let initialiser: InitFunction = unsafeBitCast(sym, to: InitFunction.self)
        let pluginPointer = initialiser()
        let builder = Unmanaged<XCGrapherPluginBuilder>.fromOpaque(pluginPointer).takeRetainedValue()

        return builder.build()
    }

}
