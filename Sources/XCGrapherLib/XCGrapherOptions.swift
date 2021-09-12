import Foundation

public protocol XCGrapherOptions {
    var startingPoint: StartingPoint { get }
    var target: String { get }
    var podlock: String { get }
    var output: String { get }
    var apple: Bool { get }
    var spm: Bool { get }
    var pods: Bool { get }
    var force: Bool { get }
    var plugin: String { get }
}

public enum StartingPoint {

    case xcodeProject(String)
    case swiftPackage(String)

    var localisedName: String {
        switch self {
        case let .xcodeProject(project): return "Xcode project at path '\(project)'"
        case let .swiftPackage(packagePath): return "Swift Package at path '\(packagePath)'"
        }
    }

    var isSPM: Bool {
        switch self {
        case .xcodeProject: return false
        case .swiftPackage: return true
        }
    }

    var path: String {
        switch self {
        case let .xcodeProject(projectPath): return projectPath
        case let .swiftPackage(packagePath): return packagePath
        }
    }

}
