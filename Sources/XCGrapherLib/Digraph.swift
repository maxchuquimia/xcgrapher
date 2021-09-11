import Foundation

/// A class for generating a Digraph string file - e.g.
/// ```
/// digraph SomeApp {
///   "a" -> "b"
///   "b" -> "c"
/// }
/// ```
class Digraph {

    /// The name of the digraph structure
    let name: String

    private var edges: [Edge] = []

    init(name: String) {
        self.name = name
    }

    /// Adds an arrow line from `a` to `b` in the graph.
    /// - Parameters:
    ///   - a: The element the arrow should originate from
    ///   - b: The element the arrow should point to
    ///   - color: The color of the line, e.g. `#FF0000`
    func addEdge(from a: String, to b: String, color: String? = nil) {
        edges.append(Edge(a: a, b: b, color: color))
    }

    /// Removes any edge with the name `a`
    func removeEdges(referencing a: String) {
        edges.removeAll {
            $0.a == a || $0.b == a
        }
    }

    func build() -> String {
        var lines = ["digraph \(name) {"]
        lines.append("")
        lines.append("  graph [ nodesep = 0.5, ranksep = 4, overlap = false, splines = true ]") // splines=ortho,
        lines.append("  node [ shape = box ]")
        lines.append("")
        lines.append(contentsOf: indentedEdgeStrings)
        lines.append("")
        lines.append("}")
        return lines.joined(separator: "\n")
    }

}

private extension Digraph {

    struct Edge {
        let a: String
        let b: String
        let color: String?

        var string: String {
            let base = "\"\(a)\" -> \"\(b)\""
            var attributes: [String: String] = [:]
            if let color = color {
                attributes["color"] = "\"\(color)\""
            }
            return base + (attributes.isEmpty ? "" : " [ \(attributes.map { $0 + "=" + $1 }.joined(separator: ", ")) ]")
        }
    }

    var indentedEdgeStrings: [String] {
        edges
            .map { "  ".appending($0.string) }
            .sortedAscendingCaseInsensitively()
    }

}
