import XCTest

extension WKBDecoderTests {
    static let __allTests = [
        ("testLineString2D", testLineString2D),
        ("testLineString3D", testLineString3D),
        ("testLineString4D", testLineString4D),
        ("testPoint2D", testPoint2D),
        ("testPoint3D", testPoint3D),
        ("testPoint4D", testPoint4D),
    ]
}

extension WKBEncoderTests {
    static let __allTests = [
        ("testLineString2D", testLineString2D),
        ("testLineString3D", testLineString3D),
        ("testLineString4D", testLineString4D),
        ("testLineStringEmpty", testLineStringEmpty),
        ("testPoint2D", testPoint2D),
        ("testPoint3D", testPoint3D),
        ("testPoint4D", testPoint4D),
    ]
}

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(WKBDecoderTests.__allTests),
        testCase(WKBEncoderTests.__allTests),
    ]
}
#endif
