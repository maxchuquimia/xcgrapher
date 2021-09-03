
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

    func localSwiftPackageDependencies() throws -> [FileManager.Path] {
        let projectLocalDependenciesCommand = ProjectLocalDependencies(projectFile: projectFile)
        let output = try projectLocalDependenciesCommand.execute()
            .breakIntoLines()
            .split { $0 == "ProjectDependenciesPathsDivider" || $0 == "WorkspaceDependenciesPathsDivider" }
        let projectDependenciesPaths = output[safe: 0] ?? []
        let workspaceDependenciesPaths = output[safe: 1] ?? []

        let result = Array(projectDependenciesPaths + workspaceDependenciesPaths)
        for path in result where !path.isEmpty {
            assert(FileManager.default.fileExists(atPath: path))
        }
        return result.filter { FileManager.default.fileExists(atPath: $0) }
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

private struct ProjectLocalDependencies: ShellTask {
    let projectFile: String

    var stringRepresentation: String {
        """
        ruby \
            -r xcodeproj \
            -e 'project_path = File.absolute_path("\(projectFile)")' \
            -e 'project = Xcodeproj::Project.open(project_path)' \
            -e 'local_spm_dependencies = project.objects.select { |o| o.isa == "XCSwiftPackageProductDependency" and o.package == nil }.map(&:product_name)' \
            -e 'relative_paths = project.files.select { |f| local_spm_dependencies.include?(f.name) }.map(&:path)' \
            -e 'absolute_paths = relative_paths.map { |p| File.expand_path(p, File.dirname(project_path)) }' \
            -e 'workspace_path = File.absolute_path("\(projectFile.replacingOccurrences(of: ".xcodeproj", with: ".xcworkspace"))")' \
            -e 'workspace = Xcodeproj::Workspace.new_from_xcworkspace(workspace_path)' \
            -e 'workspace_spm_dependencies = workspace.schemes.select { |s| local_spm_dependencies.include?(s) }.values' \
            -e 'puts("ProjectDependenciesPathsDivider")' \
            -e 'absolute_paths.each { |p| puts(p) }' \
            -e 'puts("WorkspaceDependenciesPathsDivider")' \
            -e 'workspace_spm_dependencies.each { |p| puts(p) }'
        """
    }

    var commandNotFoundInstructions: String {
        "Missing command 'xcodeproj' - install it with `gem install xcodeproj` or see https://github.com/CocoaPods/Xcodeproj"
    }
}
