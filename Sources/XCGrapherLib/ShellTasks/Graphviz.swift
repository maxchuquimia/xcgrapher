import Foundation

struct Graphviz {

    let input: FileManager.Path
    let output: FileManager.Path

}

extension Graphviz: ShellTask {

    var stringRepresentation: String {
        "dot -T png -o \"\(output)\" \"\(input)\" "
    }

    var commandNotFoundInstructions: String {
        "Missing command 'dot' - install it with `brew install graphviz` or see https://graphviz.org/download/"
    }

}
