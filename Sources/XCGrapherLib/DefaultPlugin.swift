
import Foundation
import XCGrapherPluginSupport

class DefaultPlugin: XCGrapherPlugin {

    func process(file: XCGrapherFile) throws -> [Any] {
        [] // We don't care about files for this default plugin
    }

    func process(library: XCGrapherImport) throws -> [Any] {
        let importInfo = ImportInfo(
            importedModuleName: library.moduleName,
            importerModuleName: library.importerName,
            color: color(for: library.moduleType)
        )

        return [importInfo]
    }

    func makeEdges(from nodes: [Any]) throws -> [XCGrapherEdge] {
        nodes
            .compactMap { $0 as? ImportInfo }
            .map(map(info:))
    }

}

private struct ImportInfo {
    let importedModuleName: String
    let importerModuleName: String
    let color: String
}

private extension DefaultPlugin {

    func map(info: ImportInfo) -> XCGrapherEdge {
        XCGrapherEdge(
            origin: info.importerModuleName,
            destination: info.importedModuleName,
            color: info.color
        )
    }

    func color(for moduleType: XCGrapherImport.ModuleType) -> String {
        switch moduleType {
        case .target: return "#000000"
        case .apple: return "#0071E3"
        case .spm: return "#F05138"
        case .cocoapods: return "#380200"
        case .other: return "#FF0000"
        }
    }

}
