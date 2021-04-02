# XCGrapher 
`xcgrapher` is a framework-level dependency graph generator for Xcode projects.
It works by reading local clones of the source, so it's not a problem if your project relies on internal/unpublished frameworks.

## Usage
To produce a graph of imported Cocoapods and Swift Package Manager modules for the target `SomeApp` in the project `SomeApp.xcodeproj`:
```sh
xcgrapher --project SomeApp.xcodeproj --target SomeApp --pods --spm
```
This produces the following image:

<img src="https://github.com/maxchuquimia/xcgrapher/blob/master/Marketting/xcgrapher.png?raw=true" width="500"/>

You could also pass `--apple` to include native frameworks in the graph. See `xcgrapher --help` for more options.

### Installation
Clone the project, run `swift build` and find the binary in the created `.build` directory. 
TODO: add to `homebrew`.

## How it works

### Main Project Target
`xcgrapher` uses `xcodeproj` to find all the source files of the given target. It then reads them and creates a list of  `import`s to look search for in `--pods`, `--spm` and/or `--apple`

### Swift Package Manager
`xcgrapher` builds the `--project` so that all it's SPM dependencies are cloned. It parses the build output to find the location of these clones and calls `swift package describe` on each. Finally, it loops through all the source files of the package and adds their `import` lines to the graph.

### Cocoapods
`xcgrapher` uses the Podfile.lock to discover what each pod's dependencies are. Change the location of the lockfile with the `--podlock` option if needed. As source files are not currently searched, graphing links to imported Apple frameworks from a pod is unsupported.

### Apple
`xcgrapher` assumes `/System/Library/Frameworks` and another path (see _NativeDependencyManager.swift_) contains a finite list of frameworks belonging to Apple.

### Carthage
Carthage dependencies are currently unsupported. Need it? Add it! Conform to the `DependencyManager` protocol and add an instance to the `allDependencyManagers` array in _XCGrapherMain.swift_
