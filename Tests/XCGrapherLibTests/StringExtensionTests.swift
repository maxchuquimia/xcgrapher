@testable import XCGrapherLib
import XCTest

final class StringExtensionTests: XCTestCase {

    func testScanBuilder() {
        let given = "abc"
        let sut = given.scan

        let output = sut {
            $0.scanAndStoreUpToAndIncluding(string: "b")
        }

        XCTAssertEqual(output, "ab")
    }

    func testAppendingPathComponent() {
        let sut = String.appendingPathComponent

        XCTAssertEqual(sut("/a/b")("c"), "/a/b/c")
        XCTAssertEqual(sut("/a/b")("/c"), "/a/b/c")
        XCTAssertEqual(sut("/a/b/")("c"), "/a/b/c")
        XCTAssertEqual(sut("/a/b/")("/c"), "/a/b/c")
    }

    func testBreakIntoLines() {
        let sut = String.breakIntoLines

        XCTAssertEqual(sut("a\nb\nc")(), ["a", "b", "c"])
        XCTAssertEqual(sut("abc")(), ["abc"])
    }

    func testLastPathComponent() {
        let sut = String.lastPathComponent

        XCTAssertEqual(sut("a")(), "a")
        XCTAssertEqual(sut("a/b/c")(), "c")
        XCTAssertEqual(sut("a/b.swift")(), "b.swift")
    }

}
