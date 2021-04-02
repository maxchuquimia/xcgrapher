
import XCTest
@testable import XCGrapherLib

final class ScannerTests: XCTestCase {

    var sut: Scanner.Builder!

    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = Scanner.Builder()
    }

    func testScanAndStoreUpTo() {
        let given = "abc 123 567"

        sut.scanUpTo(string: " ")
        sut.scanAndStoreUpTo(string: " 5")

        XCTAssertEqual(sut.execute(on: given), " 123")
    }

    func testScanAndStoreUpToMultiple() {
        let given = "abc 123 567 xyz"

        sut.scanUpTo(string: "1")
        XCTAssertEqual(sut.execute(on: given), "")

        sut.scanAndStoreUpTo(string: " ")
        XCTAssertEqual(sut.execute(on: given), "123")

        sut.scanAndStoreUpTo(string: " xyz")
        XCTAssertEqual(sut.execute(on: given), "123 567")
    }

    func testScanAndStoreUpToAndIncluding() {
        let given = "abc 123 567"

        sut.scanUpToAndIncluding(string: " ")
        XCTAssertEqual(sut.execute(on: given), "")

        sut.scanAndStoreUpToAndIncluding(string: " ")
        XCTAssertEqual(sut.execute(on: given), "123 ")
    }

    func testScanAndStoreUpToAndIncludingMultiple() {
        let given = "abc 123 567"

        sut.scanAndStoreUpToAndIncluding(string: " 1")
        XCTAssertEqual(sut.execute(on: given), "abc 1")

        sut.scanUpToAndIncluding(string: "5")
        XCTAssertEqual(sut.execute(on: given), "abc 1")

        sut.scanAndStoreUpToAndIncluding(string: "7")
        XCTAssertEqual(sut.execute(on: given), "abc 167")
    }

    func testScanAndStoreUpToCharacters() {
        let given = "?!@#abc@?@!"
        
        sut.scanAndStoreUpToCharacters(from: CharacterSet.alphanumerics)
        XCTAssertEqual(sut.execute(on: given), "?!@#")

        sut.scanAndStoreUpToCharacters(from: CharacterSet.alphanumerics.inverted)
        XCTAssertEqual(sut.execute(on: given), "?!@#abc")
    }

}
