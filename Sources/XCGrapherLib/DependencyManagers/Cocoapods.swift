
import Foundation

struct Cocoapods {

    /// Contains something like:
    /// ```
    /// PODS:
    /// - Auth0 (1.32.0):
    ///   - JWTDecode
    ///   - SimpleKeychain
    /// - JWTDecode (2.6.0)
    /// - NSObject_Rx (5.2.0):
    ///   - RxSwift (~> 6.0.0)
    /// ... etc
    /// ```
    let lockfilePodList: String

    init(lockFile: FileManager.Path) throws {
        lockfilePodList =
            try String(contentsOfFile: lockFile)
            .scan {
                $0.scanUpTo(string: "PODS:")
                $0.scanAndStoreUpTo(string: "\n\n")
            }
            // Account for NSObject+Rx being quoted and actually being imported with a _ instead of +
            .replacingOccurrences(of: "+", with: "_")
            .replacingOccurrences(of: "\"", with: "")
    }

}

extension Cocoapods: DependencyManager {

    func isManaging(module: String) -> Bool {
        let podlockEntry = "\n  - ".appending(module).appending(" ")
        return lockfilePodList.contains(podlockEntry)
    }

    func dependencies(of module: String) -> [String] {
        // Parse the lockfile, looking for entries indented underneath `module`
        lockfilePodList
            .scan {
                $0.scanUpToAndIncluding(string: "\n  - ".appending(module).appending(" "))
                $0.scanAndStoreUpTo(string: "\n  - ")
            }
            .breakIntoLines()
            .dropFirst()
            .map { $0.trimmingCharacters(in: CharacterSet(charactersIn:  " -:\n")) }
            .filter { !$0.isEmpty }
            .map { $0.components(separatedBy: " ")[0] }
            .map { $0.replacingOccurrences(of: "\"", with: "") }
    }

    var interfaceTraits: DependencyManagerTraits {
        .init(
            edgeColor: "#380200" // Banner on cocoapods.org
        )
    }

}
