
import Foundation

struct Xcodeproj {
    let startingPoint: StartingPoint

    func compileSourcesList() throws -> [FileManager.Path] {
        try execute()
            .breakIntoLines()
            .filter { $0.hasSuffix(".swift") }
            .filter { FileManager.default.fileExists(atPath: $0) }
    }

    func localSwiftPackageDependencies() throws -> [FileManager.Path] {
        let projectLocalDependenciesCommand = ProjectLocalDependencies(startingPoint: startingPoint)
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
        switch startingPoint {
        case let .xcodeproj(path, target, _):
            return """
            ruby \
                -r xcodeproj \
                -e 'Xcodeproj::Project.open("\(path)").targets.filter do |t| t.name == "\(target)" end.first.source_build_phase.files.to_a.reject do |f| f.file_ref.nil? end.each do |f| puts f.file_ref.real_path.to_s end'
            """
        case let .xcworkspace(path, scheme):
            return """
            ruby \
                -r xcodeproj \
                -r find \
                -e 'workspace = Xcodeproj::Workspace.new_from_xcworkspace("\(path)")' \
                -e 'xcodeproj_path = workspace.schemes["\(scheme)"]' \
                -e 'proj = Xcodeproj::Project.open(xcodeproj_path)' \
                -e 'xcscheme_path = Find.find(xcodeproj_path).select { |path| path.end_with?("xcschemes/\(scheme).xcscheme") }.first' \
                -e 'xcscheme = Xcodeproj::XCScheme.new(xcscheme_path)' \
                -e 'target_name = xcscheme.build_action.entries.first.buildable_references.first.target_name' \
                -e 'target = proj.targets.select { |t| t.name == target_name }.first' \
                -e 'sources_files = target.source_build_phase.files.reject { |f| f.file_ref.nil? }' \
                -e 'sources_files.each { |f| puts(f.file_ref.real_path.to_s) }'
            """
        case .swiftPackage: preconditionFailure("We shouldn't start a \(Self.self) shell task with a Swift Package starting point.")
        }
    }

    var commandNotFoundInstructions: String {
        "Missing command 'xcodeproj' - install it with `gem install xcodeproj` or see https://github.com/CocoaPods/Xcodeproj"
    }
    
}

private struct ProjectLocalDependencies: ShellTask {
    let startingPoint: StartingPoint

    var stringRepresentation: String {
        switch startingPoint {
        case let .xcodeproj(path, _, xcworkspacePath):
            return """
            ruby \
                -r xcodeproj \
                -e 'project_path = File.absolute_path("\(path)")' \
                -e 'project = Xcodeproj::Project.open(project_path)' \
                -e 'local_spm_dependencies = project.objects.select { |o| o.isa == "XCSwiftPackageProductDependency" and o.package == nil }.map(&:product_name)' \
                -e 'relative_paths = project.files.select { |f| local_spm_dependencies.include?(f.name) }.map(&:path)' \
                -e 'absolute_paths = relative_paths.map { |p| File.expand_path(p, File.dirname(project_path)) }' \
                -e 'workspace_path = File.absolute_path("\(xcworkspacePath ?? "")")' \
                -e 'workspace = Xcodeproj::Workspace.new_from_xcworkspace(workspace_path)' \
                -e 'workspace_spm_dependencies = workspace.schemes.select { |s| local_spm_dependencies.include?(s) }.values' \
                -e 'puts("ProjectDependenciesPathsDivider")' \
                -e 'absolute_paths.each { |p| puts(p) }' \
                -e 'puts("WorkspaceDependenciesPathsDivider")' \
                -e 'workspace_spm_dependencies.each { |p| puts(p) }'
            """
        case let .xcworkspace(path, scheme):
            return """
                ruby \
                -r xcodeproj \
                -r find \
                -e 'workspace_path = File.absolute_path("\(path)")' \
                -e 'workspace = Xcodeproj::Workspace.new_from_xcworkspace(workspace_path)' \
                -e 'project_path = workspace.schemes["\(scheme)"]' \
                -e 'project = Xcodeproj::Project.open(project_path)' \
                -e 'local_spm_dependencies = project.objects.select { |o| o.isa == "XCSwiftPackageProductDependency" and o.package == nil }.map(&:product_name)' \
                -e 'relative_paths = project.files.select { |f| local_spm_dependencies.include?(f.name) }.map(&:path)' \
                -e 'absolute_paths = relative_paths.map { |p| File.expand_path(p, File.dirname(project_path)) }' \
                -e 'workspace_spm_dependencies = workspace.schemes.select { |s| local_spm_dependencies.include?(s) }.values' \
                -e 'puts("ProjectDependenciesPathsDivider")' \
                -e 'absolute_paths.each { |p| puts(p) }' \
                -e 'puts("WorkspaceDependenciesPathsDivider")' \
                -e 'workspace_spm_dependencies.each { |p| puts(p) }'
            """
        case .swiftPackage: preconditionFailure("We shouldn't start a \(Self.self) shell task with a Swift Package starting point.")
        }
    }

    var commandNotFoundInstructions: String {
        "Missing command 'xcodeproj' - install it with `gem install xcodeproj` or see https://github.com/CocoaPods/Xcodeproj"
    }
}
