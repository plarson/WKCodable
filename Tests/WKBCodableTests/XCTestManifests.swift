#if !os(macOS)
import XCTest
@testable import WKBDecoderTests
@testable import WKBEncoderTests

public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(WKBDecoderTests.allTests),
        testCase(WKBEncoderTests.allTests),
    ]
}
#endif
