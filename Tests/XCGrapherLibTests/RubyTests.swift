
import XCTest
@testable import XCGrapherLib

final class RubyTests: XCTestCase {

    func testCommand() {
        let parameter = "myParam"
        let sut = Ruby(require: "xcodeproj", "find", script: """
        puts("Line with parameter: \(parameter)")
        puts("Random line")
        """)
        let expectedCommand = """
        ruby -r 'xcodeproj' -r 'find' -e 'puts("Line with parameter: \(parameter)")' -e 'puts("Random line")'
        """
        print(sut.command)
        XCTAssertEqual(sut.command, expectedCommand)
    }

}
