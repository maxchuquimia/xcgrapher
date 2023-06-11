import Foundation

public protocol XCGrapherOptions {
    var startingPoint: StartingPoint { get }
    var podlock: String { get }
    var output: String { get }
    var apple: Bool { get }
    var spm: Bool { get }
    var pods: Bool { get }
    var force: Bool { get }
    var plugin: String { get }
}

public enum StartingPoint {

    case xcodeProject(String, String)
    case swiftPackage(String, String)
    case xcodeWorkspace(String, String)

    var localisedName: String {
        switch self {
        case let .xcodeProject(project, _): return "Xcode project at path '\(project)'"
        case let .swiftPackage(packagePath, _): return "Swift Package at path '\(packagePath)'"
        case let .xcodeWorkspace(workspace, _): return "Xcode workspace at path '\(workspace)'"
        }
    }

    var isSPM: Bool {
        switch self {
        case .xcodeProject, .xcodeWorkspace: return false
        case .swiftPackage: return true
        }
    }

    var path: String {
        switch self {
        case
            let .xcodeProject(path, _),
            let .swiftPackage(path, _),
            let .xcodeWorkspace(path, _): return path
        }
    }

}
