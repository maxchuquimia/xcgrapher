
import Foundation

public func die(_ message: String? = nil, file: String = #file, function: String = #function, line: Int = #line) -> Never {
    if let message = message {
        LogError(message, file: file)
    } else {
        LogError("Fatal error: \(file):\(line) \(function)")
    }
    exit(1)
}

func Log(_ items: Any..., dim: Bool = false, file: String = #file) {
    let color = dim ? Colors.dim : ""
    print(items.reduce(color + logPrefix(file: file), { $0 + " \($1)" }) + Colors.reset)
}

func LogError(_ items: Any..., file: String = #file) {
    print(items.reduce(Colors.red + logPrefix(file: file), { $0 + " \($1)" }) + Colors.reset)
}

private func logPrefix(file: String) -> String {
    let name = file.components(separatedBy: "/").last?.replacingOccurrences(of: ".swift", with: "") ?? "???"
    return "[\(name)]"
}

private enum Colors {
    static let red = "\u{001B}[0;31m"
    static let dim = "\u{001B}[2m"
    static let reset = "\u{001B}[0;0m"
}
