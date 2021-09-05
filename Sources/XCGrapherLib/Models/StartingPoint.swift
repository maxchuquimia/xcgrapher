import Foundation

public enum StartingPoint {

    case xcodeproj(path: FileManager.Path, target: String, xcworkspacePath: String?)
    case xcworkspace(path: FileManager.Path, scheme: String)
    case swiftPackage(path: String, target: String)

    /// A user-friendly description of the starting point.
    var localisedName: String {
        switch self {
        case .xcodeproj: return "Xcode project at path '\(path)' with target \(target), and matching workspace at \(xcworkspacePath ?? "N/A")"
        case .xcworkspace: return "Xcode workspace at path '\(path)', with scheme \(target)"
        case .swiftPackage: return "Swift Package at path '\(path)', with target \(target)"
        }
    }

    /// Whether the starting point is a Swift Package.
    var isSPM: Bool {
        switch self {
        case .xcodeproj, .xcworkspace: return false
        case .swiftPackage: return true
        }
    }

    /// The path of the project, workspace, or Swift Package directory.
    var path: String {
        switch self {
        case let .xcodeproj(projectPath, _, _): return projectPath
        case let .xcworkspace(workspacePath, _): return workspacePath
        case let .swiftPackage(packagePath, _): return packagePath
        }
    }

    /// The path to the .xcworkspace file, if available.
    var xcworkspacePath: String? {
        switch self {
        case let .xcodeproj(_, _, xcworkspacePath): return xcworkspacePath
        case let .xcworkspace(workspacePath, _): return workspacePath
        case .swiftPackage: return nil
        }
    }

    /// The target or scheme for the current starting point.
    var target: String {
        switch self {
        case let .xcodeproj(_, target, _): return target
        case let .xcworkspace(_, scheme): return scheme
        case let .swiftPackage(_, target): return target
        }
    }

}
