import Foundation

// Must also handle `@testable import X`, `import class X.Y` etc
struct ImportFinder {

    let fileList: [FileManager.Path]

    /// Read each file in `fileList` and search for `import X`, `@testable import X`, `import class X.Y` etc.
    /// - Returns: A list of frameworks being imported by every file in `fileList`.
    func allImportedModules() -> [String] {
        fileList
            // swiftlint:disable force_try
            .map { try! String(contentsOfFile: $0) }
            .flatMap { $0.breakIntoLines() }
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { $0.hasPrefix("import ") || $0.hasPrefix("@testable import ") }
            .map {
                $0
                    .replacingOccurrences(of: "@testable ", with: "")
                    .replacingOccurrences(of: "@_exported ", with: "")
                    .replacingOccurrences(of: " class ", with: " ")
                    .replacingOccurrences(of: " struct ", with: " ")
                    .replacingOccurrences(of: " enum ", with: " ")
                    .replacingOccurrences(of: " protocol ", with: " ")
                    .replacingOccurrences(of: " var ", with: " ")
                    .replacingOccurrences(of: " let ", with: " ")
                    .replacingOccurrences(of: " func ", with: " ")
                    .replacingOccurrences(of: " typealias ", with: " ")
            }
            .filter { $0 != "import Swift" && !$0.hasPrefix("import Swift.") } // We should ignore "import Swift.Y" and "import Swift" - we can assume the project is dependent on Swift
            .map {
                $0.scan {
                    $0.scanUpToAndIncluding(string: "import ")
                    $0.scanAndStoreUpToCharacters(from: CharacterSet(charactersIn: " ."))
                }
            }
            .unique()
            .sortedAscendingCaseInsensitively()
    }

}
