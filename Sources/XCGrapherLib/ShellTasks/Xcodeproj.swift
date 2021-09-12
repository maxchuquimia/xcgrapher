import Foundation

struct Xcodeproj {

    let projectFile: FileManager.Path
    let target: String

    func compileSourcesList() throws -> [FileManager.Path] {
        try execute()
            .breakIntoLines()
            .filter { $0.hasSuffix(".swift") }
            .filter { FileManager.default.fileExists(atPath: $0) }
    }

}

extension Xcodeproj: ShellTask {

    var stringRepresentation: String {
        "ruby -r xcodeproj -e 'Xcodeproj::Project.open(\"\(projectFile)\").targets.filter do |t| t.name == \"\(target)\" end.first.source_build_phase.files.to_a.reject do |f| f.file_ref.nil? end.each do |f| puts f.file_ref.real_path.to_s end'"
    }

    var commandNotFoundInstructions: String {
        "Missing command 'xcodeproj' - install it with `gem install xcodeproj` or see https://github.com/CocoaPods/Xcodeproj"
    }

}
