
import XCTest
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
