
import Foundation

struct XCGrapher {

    /// The name of the target we are graphing
    let target: String

    /// The list of source files in the main project whose dependencies we are trying to graph
    let projectSourceFiles: [FileManager.Path]

    /// The list of dependency manager instances we should look through when trying to resolve dependencies
    let dependencyManagers: [DependencyManager]

    func generateGraph() -> Digraph {
        // All the `import x` modules from the `target`'s files
        let directTargetImports = ImportFinder(fileList: projectSourceFiles).allImportedModules()

        // Store a mutable todo list of imports that need their dependencies checked
        var importsNeedingResolving = directTargetImports
        var alreadyResolvedImports: Set<String> = []
        var unresolvableImports: Set<String> = [] // Modules that no dependency manager claimed to own

        let diagraph = Digraph(name: "XCGrapher")

        // Now comes the meat - loop through all dependencies and dependency managers and make links between them

        // First, make lines between the ARGV target and each of it's direct imports
        for moduleName in directTargetImports {
            for dependencyManager in dependencyManagers {
                if dependencyManager.isManaging(module: moduleName) {
                    diagraph.addEdge(from: target, to: moduleName, color: dependencyManager.interfaceTraits.edgeColor)
                    break // Move to the next item in `directTargetImports`
                }
            }
        }

        // Then, loop through every module and discover who is managing it
        while !importsNeedingResolving.isEmpty {
            let module = importsNeedingResolving.removeFirst()
            guard !alreadyResolvedImports.contains(module) else { continue }
            defer { alreadyResolvedImports.insert(module) }

            if let manager = dependencyManagers.manager(of: module) {
                // Ask the manager for all of it's dependencies
                for _module in manager.dependencies(of: module) {
                    guard _module != module else { continue } // Ignore when a module appears to be importing itself
                    // Add lines for them
                    let traits = dependencyManagers.manager(of: _module)?.interfaceTraits ?? .default
                    diagraph.addEdge(from: module, to: _module, color: traits.edgeColor)
                    // And add the sub-dependency to the list of dependencies we should check on
                    importsNeedingResolving.append(_module)
                }
            } else {
                // No manager claims to be managing this module
                unresolvableImports.insert(module)
            }
        }

        // Now remove any imports that couldn't be resolved
        // Note that if --force was passed then `unresolvableImports` will be empty because of the UnmanagedDependencyManager
        for unresolvedImport in unresolvableImports {
            diagraph.removeEdges(referencing: unresolvedImport)
        }

        return diagraph
    }
    
} 
