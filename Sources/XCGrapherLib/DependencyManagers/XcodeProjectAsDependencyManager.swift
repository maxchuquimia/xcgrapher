//
//  XcodeProjectAsDependencyManager.swift
//  
//
//  Created by Max Chuquimia on 1/2/2023.
//

import Foundation
import XCGrapherPluginSupport

struct XcodeProjectAsDependencyManager {

    let allCustomFrameworks: [String: [FileManager.Path]]

    init(projects: [FileManager.Path]) throws {
        var allCustomFrameworks: [String: [FileManager.Path]] = [:]
        for project in projects {
            let targets = try XcodeprojTargets(projectFile: project).targetList()
            for target in targets {
                allCustomFrameworks[target] = try Xcodeproj(projectFile: project, target: target).compileSourcesList()
            }
        }
        self.allCustomFrameworks = allCustomFrameworks
    }

}

extension XcodeProjectAsDependencyManager: DependencyManager {

    var pluginModuleType: XCGrapherImport.ModuleType {
        .target
    }

    func isManaging(module: String) -> Bool {
        allCustomFrameworks.keys.contains(module)
    }

    func dependencies(of module: String) -> [String] {
        guard let files = allCustomFrameworks[module] else { return [] }
        return ImportFinder(fileList: files).allImportedModules()
    }

}
