//
//  XcodeprojTargets.swift
//  
//
//  Created by Max Chuquimia on 1/2/2023.
//

import Foundation

struct XcodeprojTargets {

    let projectFile: FileManager.Path

    func targetList() throws -> [String] {
        try execute()
            .breakIntoLines()
            .filter { !$0.isEmpty }
    }

}

extension XcodeprojTargets: ShellTask {

    var stringRepresentation: String {
        "ruby -r xcodeproj -e 'Xcodeproj::Project.open(\"\(projectFile)\").targets.each do |t| puts t.name end'"
    }

    var commandNotFoundInstructions: String {
        "Missing command 'xcodeproj' - install it with `gem install xcodeproj` or see https://github.com/CocoaPods/Xcodeproj"
    }

}
