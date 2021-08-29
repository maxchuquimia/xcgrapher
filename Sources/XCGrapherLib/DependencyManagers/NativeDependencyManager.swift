
import Foundation
import XCGrapherPluginSupport

struct NativeDependencyManager {
    let allNativeFrameworks: [String]

    init() throws {
        let standardList = try FileManager.default
            .contentsOfDirectory(atPath: "/System/Library/Frameworks")

        // It seems the above does not contain UIKit.framework though... so let's use another list that does
        let backupList = try FileManager.default
            .contentsOfDirectory(atPath: "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/System/iOSSupport/System/Library/Frameworks")

        allNativeFrameworks = (standardList + backupList)
            .map { $0.replacingOccurrences(of: ".framework", with: "") }
            .unique()
    }
}

extension NativeDependencyManager: DependencyManager {
    var pluginModuleType: XCGrapherImport.ModuleType {
        .apple
    }

    func isManaging(module: String) -> Bool {
        allNativeFrameworks.contains(module)
    }

    func dependencies(of _: String) -> [String] {
        [] // Obviously we don't know how Apple's frameworks work internally
    }
}
