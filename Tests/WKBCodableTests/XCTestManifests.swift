import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(WKBDecoderTests.allTests),
        testCase(WKBEncoderTests.allTests),
    ]
}
#endif
