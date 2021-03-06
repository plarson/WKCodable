import XCTest

extension WKBCodableLittleEndianTests {
    static let __allTests = [
        ("testGeometryCollection", testGeometryCollection),
        ("testGeometryCollectionEmpty", testGeometryCollectionEmpty),
        ("testGeometryCollectionLineString", testGeometryCollectionLineString),
        ("testLineString2D", testLineString2D),
        ("testLineString3D", testLineString3D),
        ("testLineString4D", testLineString4D),
        ("testLineStringEmpty", testLineStringEmpty),
        ("testMultiLineString", testMultiLineString),
        ("testMultiLineStringEmpty", testMultiLineStringEmpty),
        ("testMultiPoint", testMultiPoint),
        ("testMultiPointEmpty", testMultiPointEmpty),
        ("testMultiPolygon", testMultiPolygon),
        ("testMultiPolygonEmpty", testMultiPolygonEmpty),
        ("testPoint2D", testPoint2D),
        ("testPoint3D", testPoint3D),
        ("testPoint4D", testPoint4D),
        ("testPolygon", testPolygon),
        ("testPolygonEmpty", testPolygonEmpty),
    ]
}

extension WKBCodableTests {
    static let __allTests = [
        ("testGeometryCollection", testGeometryCollection),
        ("testGeometryCollectionEmpty", testGeometryCollectionEmpty),
        ("testGeometryCollectionLineString", testGeometryCollectionLineString),
        ("testLineString2D", testLineString2D),
        ("testLineString3D", testLineString3D),
        ("testLineString4D", testLineString4D),
        ("testLineStringEmpty", testLineStringEmpty),
        ("testMultiLineString", testMultiLineString),
        ("testMultiLineStringEmpty", testMultiLineStringEmpty),
        ("testMultiPoint", testMultiPoint),
        ("testMultiPointEmpty", testMultiPointEmpty),
        ("testMultiPolygon", testMultiPolygon),
        ("testMultiPolygonEmpty", testMultiPolygonEmpty),
        ("testPoint2D", testPoint2D),
        ("testPoint3D", testPoint3D),
        ("testPoint4D", testPoint4D),
        ("testPolygon", testPolygon),
        ("testPolygonEmpty", testPolygonEmpty),
    ]
}

extension WKTCodableTests {
    static let __allTests = [
        ("testGeometryCollection", testGeometryCollection),
        ("testGeometryCollectionEmpty", testGeometryCollectionEmpty),
        ("testGeometryCollectionLineString", testGeometryCollectionLineString),
        ("testLineString2D", testLineString2D),
        ("testLineString3D", testLineString3D),
        ("testLineString4D", testLineString4D),
        ("testLineStringEmpty", testLineStringEmpty),
        ("testMultiLineString", testMultiLineString),
        ("testMultiLineStringEmpty", testMultiLineStringEmpty),
        ("testMultiPoint", testMultiPoint),
        ("testMultiPointEmpty", testMultiPointEmpty),
        ("testMultiPolygon", testMultiPolygon),
        ("testMultiPolygonEmpty", testMultiPolygonEmpty),
        ("testPoint2D", testPoint2D),
        ("testPoint3D", testPoint3D),
        ("testPoint4D", testPoint4D),
        ("testPolygon", testPolygon),
        ("testPolygonEmpty", testPolygonEmpty),
    ]
}

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(WKBCodableLittleEndianTests.__allTests),
        testCase(WKBCodableTests.__allTests),
        testCase(WKTCodableTests.__allTests),
    ]
}
#endif
