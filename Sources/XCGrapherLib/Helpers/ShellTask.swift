import Foundation

protocol ShellTask {
    /// The raw shell representation of the command.
    var stringRepresentation: String { get }

    /// A localised string to be displayed when the command cannot be found.
    var commandNotFoundInstructions: String { get }
}

extension ShellTask {
    @discardableResult
    func execute() throws -> String {
        let task = Process()
        let stdout = Pipe()
        let stderr = Pipe()

        task.standardOutput = stdout
        task.standardError = stderr
        task.arguments = ["-c", stringRepresentation]
        task.launchPath = "/bin/bash"
        task.launch()

        Log(stringRepresentation, dim: true)

        let output = stdout.fileHandleForReading.readDataToEndOfFile()
        let errorOutput = stderr.fileHandleForReading.readDataToEndOfFile()

        task.waitUntilExit()

        if task.terminationStatus == 0 {
            return String(data: output, encoding: .utf8)!
        } else if task.terminationStatus == 127 {
            LogError(commandNotFoundInstructions)
            throw CommandError.commandNotFound(message: commandNotFoundInstructions)
        } else {
            throw CommandError.failure(stderr: String(data: errorOutput, encoding: .utf8)!)
        }
    }
}

enum CommandError: LocalizedError {
    case failure(stderr: String)
    case commandNotFound(message: String)

    var errorDescription: String? {
        switch self {
        case let .failure(stderr): return stderr
        case let .commandNotFound(message): return message
        }
    }
}
