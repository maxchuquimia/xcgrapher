
import Foundation

extension String {

    func scan(buildOperations: (Scanner.Builder) -> Void) -> String {
        let builder = Scanner.Builder()
        buildOperations(builder)
        return builder.execute(on: self)
    }

    func appendingPathComponent(_ component: String) -> String {
        var result = self
        let delimiter = "/"
        if !result.hasSuffix(delimiter) && !component.hasPrefix(delimiter) {
            result.append(delimiter)
        } else if result.hasSuffix(delimiter) && component.hasPrefix(delimiter) {
            result.removeLast()
        }
        result.append(component)
        return result
    }

    func breakIntoLines() -> [String] {
        components(separatedBy: .newlines)
    }

}
