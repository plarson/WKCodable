import XCTest
@testable import WKCodable

class WKBCodableTests: XCTestCase {
    
    var encoder: WKBEncoder!
    var decoder: WKBDecoder!

    override func setUp() {
        encoder = WKBEncoder()
        decoder = WKBDecoder()
    }
    
    func testPoint2D() throws {
        let value = WKBPoint(vector: [1,2])
        let data = try encoder.encode(value)
        let value2 = try decoder.decode(from: data) as! WKBPoint
        XCTAssertEqual(value, value2)
    }
        
    func testPoint3D() throws {
        let value = WKBPoint(vector: [1,2,3])
        let data = try encoder.encode(value)
        let value2 = try decoder.decode(from: data) as! WKBPoint
        XCTAssertEqual(value, value2)
    }

    func testPoint4D() throws {
        let value = WKBPoint(vector: [1,2,3,4])
        let data = try encoder.encode(value)
        let value2 = try decoder.decode(from: data) as! WKBPoint
        XCTAssertEqual(value, value2)
    }
    
    func testLineStringEmpty() throws {
        let value = WKBLineString(points: [])
        let data = try encoder.encode(value)
        let value2 = try decoder.decode(from: data) as! WKBLineString
        XCTAssertEqual(value, value2)
    }

    func testLineString2D() throws {
        let value = WKBLineString(points: [ WKBPoint(vector: [1,2]), WKBPoint(vector: [2,3]) ])
        let data = try encoder.encode(value)
        let value2 = try decoder.decode(from: data) as! WKBLineString
        XCTAssertEqual(value, value2)
    }

    func testLineString3D() throws {
        let value = WKBLineString(points: [ WKBPoint(vector: [1,2,3]), WKBPoint(vector: [4,5,6]) ])
        let data = try encoder.encode(value)
        let value2 = try decoder.decode(from: data) as! WKBLineString
        XCTAssertEqual(value, value2)
    }

    func testLineString4D() throws {
        let value = WKBLineString(points: [ WKBPoint(vector: [1,2,3,4]), WKBPoint(vector: [5,6,7,8]) ])
        let data = try encoder.encode(value)
        let value2 = try decoder.decode(from: data) as! WKBLineString
        XCTAssertEqual(value, value2)
    }

    func testPolygonEmpty() throws {
        let value = WKBPolygon(exteriorRing: WKBLineString(points: []))
        let data = try encoder.encode(value)
        let value2 = try decoder.decode(from: data) as! WKBPolygon
        XCTAssertEqual(value, value2)
    }
    
    func testPolygon() throws {
        let lineString = WKBLineString(points: [
            WKBPoint(vector: [1,2]),
            WKBPoint(vector: [3,4]),
            WKBPoint(vector: [6,5]),
            WKBPoint(vector: [1,2]),
            ])
        let value = WKBPolygon(exteriorRing: lineString)
        let data = try encoder.encode(value)
        let value2 = try decoder.decode(from: data) as! WKBPolygon
        XCTAssertEqual(value, value2)
    }
    
    func testMultiPointEmpty() throws {
        let value = WKBMultiPoint(points: [])
        let data = try encoder.encode(value)
        let value2 = try decoder.decode(from: data) as! WKBMultiPoint
        XCTAssertEqual(value, value2)
    }
    
    func testMultiPoint() throws {
        let value = WKBMultiPoint(points: [ WKBPoint(vector: [1,2]), WKBPoint(vector: [2,3]) ])
        let data = try encoder.encode(value)
        let value2 = try decoder.decode(from: data) as! WKBMultiPoint
        XCTAssertEqual(value, value2)
    }
    
    func testMultiLineStringEmpty() throws {
        let value = WKBMultiLineString(lineStrings: [])
        let data = try encoder.encode(value)
        let value2 = try decoder.decode(from: data) as! WKBMultiLineString
        XCTAssertEqual(value, value2)
    }
    
    func testMultiLineString() throws {
        let value = WKBMultiLineString(lineStrings: [ WKBLineString(points: [ WKBPoint(vector: [1,2]), WKBPoint(vector: [2,3]) ]),
                                                      WKBLineString(points: [ WKBPoint(vector: [4,5]), WKBPoint(vector: [6,7]) ]) ])
        let data = try encoder.encode(value)
        let value2 = try decoder.decode(from: data) as! WKBMultiLineString
        XCTAssertEqual(value, value2)
    }
    
    func testMultiPolygonEmpty() throws {
        let value = WKBMultiLineString(lineStrings: [])
        let data = try encoder.encode(value)
        let value2 = try decoder.decode(from: data) as! WKBMultiLineString
        XCTAssertEqual(value, value2)
    }
    
    func testMultiPolygonString() throws {
        let lineString = WKBLineString(points: [
            WKBPoint(vector: [1,2]),
            WKBPoint(vector: [3,4]),
            WKBPoint(vector: [6,5]),
            WKBPoint(vector: [1,2]),
            ])
        let polygon = WKBPolygon(exteriorRing: lineString)
        let lineString2 = WKBLineString(points: [
            WKBPoint(vector: [1,2]),
            WKBPoint(vector: [3,4]),
            WKBPoint(vector: [6,5]),
            WKBPoint(vector: [1,2]),
            ])
        let polygon2 = WKBPolygon(exteriorRing: lineString2)
        let value = WKBMultiPolygon(polygons: [ polygon, polygon2 ])
        let data = try encoder.encode(value)
        let value2 = try decoder.decode(from: data) as! WKBMultiPolygon
        XCTAssertEqual(value, value2)
    }
    
    func testGeometryCollectionEmpty() throws {
        let value = WKBGeometryCollection(geometries: [])
        let data = try encoder.encode(value)
        let value2 = try decoder.decode(from: data) as! WKBGeometryCollection
        XCTAssert(value2.geometries.count == 0)
    }
}
