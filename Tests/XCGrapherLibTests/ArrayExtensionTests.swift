
import XCTest
@testable import XCGrapherLib

final class ArrayExtensionTests: XCTestCase {

    func testUnique() {
        let sut = Array<String>.unique

        let output1 = sut(["a", "a", "b", "c", "b", "d", ])()
        XCTAssertEqual(output1.count, 4)
        XCTAssertTrue(output1.contains("a"))
        XCTAssertTrue(output1.contains("b"))
        XCTAssertTrue(output1.contains("c"))
        XCTAssertTrue(output1.contains("d"))

        let output2 = sut(["1", "2", "1", "4", "4", "4", ])()
        XCTAssertEqual(output2.count, 3)
        XCTAssertTrue(output2.contains("1"))
        XCTAssertTrue(output2.contains("2"))
        XCTAssertTrue(output2.contains("4"))
    }

    func testSortedAscendingCaseInsensitively() {
        let sut = Array<String>.sortedAscendingCaseInsensitively

        let output1 = sut(["baa", "dab", "Baa", "DAA"])()
        XCTAssertEqual(output1, ["Baa", "baa", "DAA", "dab"])

        let output2 = sut(["ABC", "ABX", "abx", "abc"])()
        XCTAssertEqual(output2, ["ABC", "abc", "ABX", "abx"])
    }

}

