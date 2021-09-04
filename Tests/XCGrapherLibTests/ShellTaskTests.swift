
import XCTest
@testable import XCGrapherLib

final class ShellTaskTests: XCTestCase {

    private var sut: ShellTask! { mock }
    private var mock: ConcreteShellTask!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mock = ConcreteShellTask()
    }

    func testCommandNotFound() {
        mock.stringRepresentation = "not_a_command123"
        mock.commandNotFoundInstructions = UUID().uuidString

        do {
            try sut.execute()
            XCTFail("sut.execute() should throw and never reach here")
        } catch let CommandError.commandNotFound(message) {
            XCTAssertEqual(message, mock.commandNotFoundInstructions)
        } catch {
            XCTFail("Unexpected error \(error)")
        }
    }

    func testCommandFailed() {
        mock.stringRepresentation = "which"
        do {
            try sut.execute()
            XCTFail("sut.execute() should throw and never reach here")
        } catch let CommandError.failure(stderr) {
            XCTAssertEqual(stderr, "usage: which [-as] program ...\n")
        } catch {
            XCTFail("Unexpected error \(error)")
        }
    }

    func testCommandSuccess() {
        mock.stringRepresentation = "which bash"
        do {
            let output = try sut.execute()
            XCTAssertEqual(output, "/bin/bash\n")
        } catch {
            XCTFail("Unexpected error \(error)")
        }
    }

    func testRecoveringFromError() {
        mock.stringRepresentation = "grep -ERROR" // This results in grep exitting with code 2
        mock.errorRecoveryHandler = { error, status in
            XCTAssertTrue(error.starts(with: "usage: grep"))
            XCTAssertEqual(status, 2)
            return .recovered(newOutput: "new output")
        }
        do {
            let output = try sut.execute()
            XCTAssertEqual(output, "new output")
        } catch {
            XCTFail("Unexpected error \(error)")
        }
    }

}

private class ConcreteShellTask: ShellTask {

    var stringRepresentation: String = ""
    var commandNotFoundInstructions: String = ""
    var errorRecoveryHandler: ((String, Int32) -> ShellTaskErrorRecovery)?

    func recover(from error: String, with terminationStatus: Int32) -> ShellTaskErrorRecovery {
        errorRecoveryHandler?(error, terminationStatus) ?? .unableToRecover
    }

}
