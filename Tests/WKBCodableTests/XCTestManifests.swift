#if !os(macOS)
import XCTest
@testable import WKBCodableTests

public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(WKBCodableTests.allTests),
    ]
}
#endif
