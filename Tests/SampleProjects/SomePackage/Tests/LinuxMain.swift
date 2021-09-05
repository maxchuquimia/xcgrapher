import XCTest

import SomePackageTests

var tests = [XCTestCaseEntry]()
tests += SomePackageTests.allTests()
XCTMain(tests)
