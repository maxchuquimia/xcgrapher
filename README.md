# XCGrapher 
`xcgrapher` is, by default, a framework-level dependency graph generator for Xcode projects.
It works by reading local clones of the source, so it's not a problem if your project relies on internal/unpublished frameworks.

However, it is so much more than just that. `xcgrapher` supports custom (Swift) plugins so you can easily parse your source code and quickly create graphs that are meaningful to you and your team!

## Basic Usage
To produce a graph of imported Cocoapods and Swift Package Manager modules for the target `SomeApp` in the project `SomeApp.xcodeproj`:
```sh
xcgrapher --project SomeApp.xcodeproj --target SomeApp --pods --spm
```
This produces the following image:

<img src="https://github.com/maxchuquimia/xcgrapher/blob/master/Marketting/xcgrapher.png?raw=true" width="500"/>

You could also pass `--apple` to include native frameworks in the graph. See `xcgrapher --help` for more options.

### Installation
```sh
brew tap maxchuquimia/scripts
brew install xcgrapher
gem install xcodeproj # If you use Cocoapods you probably don't need to do this
```

Or, just clone the project and `make install`. **Note that whilst the project does compile and tests pass in Xcode, it cannot be run directly as some environment variables are missing.** I recommend simply running `make install` when adding new features to this repo.

## Custom Graphs
What if (for example) your team has it's own property wrappers for dependency injection? You can graph it's usage that too!

Create yourself a new Swift Package and subclass `XCGrapherPlugin` from the package [maxchuquimia/XCGrapherPluginSupport](https://github.com/maxchuquimia/XCGrapherPluginSupport). You can override a function that will be called once with every source file in your project and it's (SPM) dependencies. Then you can parse each file as needed and generate an array of arrows that will be drawn.

In fact, `xcgrapher`'s default behaviour is [implemented as a plugin](https://github.com/maxchuquimia/xcgrapher/tree/master/Sources/XCGrapherModuleImportPlugin) too!

For full documentation take a look at the [XCGrapherPluginSupport](https://github.com/maxchuquimia/XCGrapherPluginSupport) repo.

## How it works

#### Main Project Target
`xcgrapher` uses `xcodeproj` (a Cocoapods gem) to find all the source files of the given target. It then reads them and creates a list of  `import`s to know which `--pods`, `--spm` and/or `--apple` modules are part of the target.

#### Swift Package Manager
`xcgrapher` builds the `--project` so that all it's SPM dependencies are cloned. It parses the build output to find the location of these clones and calls `swift package describe` on each. Then it iterates through all the source files of each package to find their `import` lines and repeats.

#### Cocoapods
`xcgrapher` uses the _Podfile.lock_ to discover what each pod's dependencies are. Change the location of the lockfile with the `--podlock` option if needed. Cocoapods source files are not currently searched so graphing links to imported Apple frameworks from a pod is unsupported, as is file-by-file processing in a custom plugin. `xcgrapher` is really geared towards Xcode projects and Swift Packages.

#### Apple
`xcgrapher` assumes `/System/Library/Frameworks` and another path (see _NativeDependencyManager.swift_) contains a finite list of frameworks belonging to Apple. This probably isn't ideal for some cases, so open a PR if you know a better way!

#### Carthage
Carthage dependencies are currently unsupported. Need it? Add it! Conform to the `DependencyManager` protocol and have a look at the usage of `SwiftPackageManager`.
