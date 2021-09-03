
import XCTest
import class Foundation.Bundle
@testable import XCGrapherLib

/// Asserts that the `digraph` is made up of **ONLY** the `edges` and nothing more
func XCGrapherAssertDigraphIsMadeFromEdges(_ digraph: String, _ edges: [(String, String)], file: StaticString = #file, line: UInt = #line) {
    var digraphEdgeStrings = digraph
        .breakIntoLines()
        .filter { $0.contains("\" -> \"") } // We only care about the lines that contain `"X" -> "Y"`

    for (edgeFrom, edgeTo) in edges {
        let expectedEdge = "\"\(edgeFrom)\" -> \"\(edgeTo)\""
        guard let lineWithExpectedEdge = digraphEdgeStrings.firstIndex(where: { $0.contains(expectedEdge) } ) else {
            XCTFail("The digraph does not contain the edge \(expectedEdge)", file: file, line: line)
            continue
        }
        digraphEdgeStrings.remove(at: lineWithExpectedEdge)
    }

    if !digraphEdgeStrings.isEmpty {
        XCTFail("The digraph contains unexpected edges: \(digraphEdgeStrings)")
    }
}

/// Finds the location of the products that were built in order for the test to run
func productsDirectory() -> String {
    Bundle.allBundles
        .first { $0.bundlePath.hasSuffix(".xctest") }!
        .bundleURL
        .deletingLastPathComponent()
        .path
}

func defaultXCGrapherPluginLocation() -> String {
    productsDirectory()
        .appendingPathComponent("PackageFrameworks")
        .appendingPathComponent("XCGrapherModuleImportPlugin.framework")
        .appendingPathComponent("XCGrapherModuleImportPlugin")
}

let sampleProjectsDirectory = URL(string: #file.description)!
    .deletingLastPathComponent()
    .deletingLastPathComponent()
    .appendingPathComponent("SampleProjects")

extension Data {
    init(fromResourceNamed filename: String, extension: String) throws {
        let path = URL(fileURLWithPath: Bundle.module.path(forResource: filename, ofType: `extension`)!)
        try self.init(contentsOf: path)
    }
}
