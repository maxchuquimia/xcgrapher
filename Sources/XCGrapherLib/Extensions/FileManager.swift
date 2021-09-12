import Foundation

public extension FileManager {

    typealias Path = String

    func directoryExists(atPath path: Path) -> Bool {
        var isDirectory: ObjCBool = false
        fileExists(atPath: path, isDirectory: &isDirectory)
        return isDirectory.boolValue
    }

}
