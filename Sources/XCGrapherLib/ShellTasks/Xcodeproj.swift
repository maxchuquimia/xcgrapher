
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
            .split { $0 == Constants.projectDependenciesPathsDivider || $0 == Constants.workspaceDependenciesPathsDivider }
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
            return Ruby(require: "xcodeproj", script: """
            proj = Xcodeproj::Project.open("\(path)")
            target = proj.targets.select { |t| t.name == "\(target)" }.first
            sources_files = target.source_build_phase.files.reject { |f| f.file_ref.nil? }
            sources_files.each { |f| puts(f.file_ref.real_path.to_s) }
            """).command
        case let .xcworkspace(path, scheme):
            return Ruby(require: "xcodeproj", "find", script: """
            workspace = Xcodeproj::Workspace.new_from_xcworkspace("\(path)")
            xcodeproj_path = workspace.schemes["\(scheme)"]
            proj = Xcodeproj::Project.open(xcodeproj_path)
            xcscheme_path = Find.find(xcodeproj_path).select { |path| path.end_with?("xcschemes/\(scheme).xcscheme") }.first
            xcscheme = Xcodeproj::XCScheme.new(xcscheme_path)
            target_name = xcscheme.build_action.entries.first.buildable_references.first.target_name
            target = proj.targets.select { |t| t.name == target_name }.first
            sources_files = target.source_build_phase.files.reject { |f| f.file_ref.nil? }
            sources_files.each { |f| puts(f.file_ref.real_path.to_s) }
            """).command
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
            return Ruby(require: "xcodeproj", script: """
            project_path = File.absolute_path("\(path)")
            project = Xcodeproj::Project.open(project_path)
            local_spm_dependencies = project.objects.select { |o| o.isa == "XCSwiftPackageProductDependency" and o.package == nil }.map(&:product_name)
            relative_paths = project.files.select { |f| local_spm_dependencies.include?(f.name) }.map(&:path)
            absolute_paths = relative_paths.map { |p| File.expand_path(p, File.dirname(project_path)) }
            workspace_path = File.absolute_path("\(xcworkspacePath ?? "")")
            workspace = Xcodeproj::Workspace.new_from_xcworkspace(workspace_path)
            workspace_spm_dependencies = workspace.schemes.select { |s| local_spm_dependencies.include?(s) }.values
            puts("\(Constants.projectDependenciesPathsDivider)")
            absolute_paths.each { |p| puts(p) }
            puts("\(Constants.workspaceDependenciesPathsDivider)")
            workspace_spm_dependencies.each { |p| puts(p) }
            """).command
        case let .xcworkspace(path, scheme):
            // Maybe  "find"
            return Ruby(require: "xcodeproj", "find", script: """
            workspace_path = File.absolute_path("\(path)")
            workspace = Xcodeproj::Workspace.new_from_xcworkspace(workspace_path)
            project_path = workspace.schemes["\(scheme)"]
            project = Xcodeproj::Project.open(project_path)
            local_spm_dependencies = project.objects.select { |o| o.isa == "XCSwiftPackageProductDependency" and o.package == nil }.map(&:product_name)
            relative_paths = project.files.select { |f| local_spm_dependencies.include?(f.name) }.map(&:path)
            absolute_paths = relative_paths.map { |p| File.expand_path(p, File.dirname(project_path)) }
            workspace_spm_dependencies = workspace.schemes.select { |s| local_spm_dependencies.include?(s) }.values
            puts("\(Constants.projectDependenciesPathsDivider)")
            absolute_paths.each { |p| puts(p) }
            puts("\(Constants.workspaceDependenciesPathsDivider)")
            workspace_spm_dependencies.each { |p| puts(p) }
            """).command
        case .swiftPackage: preconditionFailure("We shouldn't start a \(Self.self) shell task with a Swift Package starting point.")
        }
    }

    var commandNotFoundInstructions: String {
        "Missing command 'xcodeproj' - install it with `gem install xcodeproj` or see https://github.com/CocoaPods/Xcodeproj"
    }
}
