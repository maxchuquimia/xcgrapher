
import Foundation

protocol ShellTask {
    /// The raw shell representation of the command.
    var stringRepresentation: String { get }

    /// A localised string to be displayed when the command cannot be found.
    var commandNotFoundInstructions: String { get }

    /// Provides the opportunity to recover from an error
    func recover(from error: String, with terminationStatus: Int32) -> ErrorRecoveryResult
}

extension ShellTask {

    func recover(from error: String, with terminationStatus: Int32) -> ErrorRecoveryResult {
        .unableToRecover
    }

}

enum ErrorRecoveryResult {
    /// The program couldn't recover from the error and should be terminated.
    case unableToRecover

    /// The error was non-fatal and the program should continue with `newOutput` as the shell task's output
    case recovered(newOutput: String)
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
            let error = String(data: errorOutput, encoding: .utf8)!
            let recoveryOption = recover(from: error, with: task.terminationStatus)
            switch recoveryOption {
            case .unableToRecover:
                LogError("The command failed with exit code \(task.terminationStatus)")
                throw CommandError.failure(stderr: error)
            case let .recovered(newOutput):
                return newOutput
            }
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
