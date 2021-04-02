
import XCTest
@testable import XCGrapherLib

final class FileManagerExtensionTests: XCTestCase {

    func testDirectoryExists() {
        let sut = FileManager.default.directoryExists(atPath:)

        // This path always exists and is a directory
        XCTAssertTrue(sut("/Users"))

        // This path does not exist at all
        XCTAssertFalse(sut("/NotADirectoryOrAFile12345"))

        // This path does exist but it's not a directory
        XCTAssertFalse(sut("/bin/bash"))
    }

}
