import XCTest
@testable import WKCodable

class WKTCodableTests: XCTestCase {
    
    var encoder: WKTEncoder!
    var decoder: WKTDecoder!
    
    override func setUp() {
        encoder = WKTEncoder()
        decoder = WKTDecoder()
    }
    
    func testPoint2D() throws {
        let value = Point(vector: [1,2])
        let string = encoder.encode(value)
        let value2: Point = try decoder.decode(from: string)
        XCTAssertEqual(value, value2)
    }
    
    func testPoint3D() throws {
        let value = Point(vector: [1,2,3])
        let data = encoder.encode(value)
        let value2: Point = try decoder.decode(from: data)
        XCTAssertEqual(value, value2)
    }
    
    func testPoint4D() throws {
        let value = Point(vector: [1,2,3,4])
        let data = encoder.encode(value)
        let value2: Point = try decoder.decode(from: data)
        XCTAssertEqual(value, value2)
    }
    
    func testLineStringEmpty() throws {
        let value = LineString(points: [])
        let data = encoder.encode(value)
        let value2: LineString = try decoder.decode(from: data)
        XCTAssertEqual(value, value2)
    }
    
    func testLineString2D() throws {
        let value = LineString(points: [ Point(vector: [1,2]), Point(vector: [2,3]) ])
        let data = encoder.encode(value)
        let value2: LineString = try decoder.decode(from: data)
        XCTAssertEqual(value, value2)
    }
    
    func testLineString3D() throws {
        let value = LineString(points: [ Point(vector: [1,2,3]), Point(vector: [4,5,6]) ])
        let data = encoder.encode(value)
        let value2: LineString = try decoder.decode(from: data)
        XCTAssertEqual(value, value2)
    }
    
    func testLineString4D() throws {
        let value = LineString(points: [ Point(vector: [1,2,3,4]), Point(vector: [5,6,7,8]) ])
        let data = encoder.encode(value)
        let value2: LineString = try decoder.decode(from: data)
        XCTAssertEqual(value, value2)
    }
    
    func testPolygonEmpty() throws {
        let value = Polygon(exteriorRing: LineString(points: []))
        let data = encoder.encode(value)
        let value2: WKCodable.Polygon = try decoder.decode(from: data)
        XCTAssertEqual(value, value2)
    }
    
    func testPolygon() throws {
        let lineString = LineString(points: [
            Point(vector: [1,2]),
            Point(vector: [3,4]),
            Point(vector: [6,5]),
            Point(vector: [1,2]),
            ])
        let value = Polygon(exteriorRing: lineString)
        let data = encoder.encode(value)
        let value2: WKCodable.Polygon = try decoder.decode(from: data)
        XCTAssertEqual(value, value2)
    }
    
    func testMultiPointEmpty() throws {
        let value = MultiPoint(points: [])
        let data = encoder.encode(value)
        let value2: MultiPoint = try decoder.decode(from: data)
        XCTAssertEqual(value, value2)
    }
    
    func testMultiPoint() throws {
        let value = MultiPoint(points: [ Point(vector: [1,2]), Point(vector: [2,3]) ])
        let data = encoder.encode(value)
        let value2: MultiPoint = try decoder.decode(from: data)
        XCTAssertEqual(value, value2)
    }
    
    func testMultiLineStringEmpty() throws {
        let value = MultiLineString(lineStrings: [])
        let data = encoder.encode(value)
        let value2: MultiLineString = try decoder.decode(from: data)
        XCTAssertEqual(value, value2)
    }
    
    func testMultiLineString() throws {
        let value = MultiLineString(lineStrings: [ LineString(points: [ Point(vector: [1,2]), Point(vector: [2,3]) ]),
                                                   LineString(points: [ Point(vector: [4,5]), Point(vector: [6,7]) ]) ])
        let data = encoder.encode(value)
        let value2: MultiLineString = try decoder.decode(from: data)
        XCTAssertEqual(value, value2)
    }
    
    func testMultiPolygonEmpty() throws {
        let value = MultiLineString(lineStrings: [])
        let data = encoder.encode(value)
        let value2: MultiLineString = try decoder.decode(from: data)
        XCTAssertEqual(value, value2)
    }
    
    func testMultiPolygon() throws {
        let lineString = LineString(points: [
            Point(vector: [1,2]),
            Point(vector: [3,4]),
            Point(vector: [6,5]),
            Point(vector: [1,2]),
            ])
        let polygon = Polygon(exteriorRing: lineString)
        let lineString2 = LineString(points: [
            Point(vector: [1,2]),
            Point(vector: [3,4]),
            Point(vector: [6,5]),
            Point(vector: [1,2]),
            ])
        let polygon2 = Polygon(exteriorRing: lineString2)
        let value = MultiPolygon(polygons: [ polygon, polygon2 ])
        let data = encoder.encode(value)
        let value2: MultiPolygon = try decoder.decode(from: data)
        XCTAssertEqual(value, value2)
    }
    
    func testGeometryCollectionEmpty() throws {
        let value = GeometryCollection(geometries: [])
        let data = encoder.encode(value)
        let value2: GeometryCollection = try decoder.decode(from: data)
        XCTAssertEqual(value, value2)
    }
    
    func testGeometryCollection() throws {
        let value = GeometryCollection(geometries: [ Point(vector: [1,2]) ])
        let data = encoder.encode(value)
        let value2: GeometryCollection = try decoder.decode(from: data)
        XCTAssertEqual(value, value2)
    }
    
    func testGeometryCollectionLineString() throws {
        let value = GeometryCollection(geometries: [ LineString(points: [ Point(vector: [1,2]), Point(vector: [2,3]) ]) ])
        let data = encoder.encode(value)
        let value2: GeometryCollection = try decoder.decode(from: data)
        XCTAssertEqual(value, value2)
    }
}

