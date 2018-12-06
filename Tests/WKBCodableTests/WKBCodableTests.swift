import XCTest
@testable import WKBCodable

class WKBCodableTests: XCTestCase {
    
    var encoder = WKBEncoder()
    var decoder = WKBDecoder()

    override func setUp() {
        encoder = WKBEncoder()
        decoder = WKBDecoder()
    }
    
    func testPoint2D() throws {
        let value = WKBPoint(vector: [1,2])
        let data = try encoder.encode(value)
        XCTAssertEqual("0020000001000003e83ff00000000000004000000000000000", data.hexEncodedString())
        let value2 = try decoder.decode(from: data) as! WKBPoint
        XCTAssertEqual(value, value2)
    }

    func testPoint3D() throws {
        let value = WKBPoint(vector: [1,2,3])
        let data = try encoder.encode(value)
        XCTAssertEqual("00a0000001000003e83ff000000000000040000000000000004008000000000000", data.hexEncodedString())
        let value2 = try decoder.decode(from: data) as! WKBPoint
        XCTAssertEqual(value, value2)
    }

    func testPoint4D() throws {
        let value = WKBPoint(vector: [1,2,3,4])
        let data = try encoder.encode(value)
        XCTAssertEqual("00e0000001000003e83ff0000000000000400000000000000040080000000000004010000000000000", data.hexEncodedString())
        let value2 = try decoder.decode(from: data) as! WKBPoint
        XCTAssertEqual(value, value2)
    }
    
    func testLineStringEmpty() throws {
        let value = WKBLineString(points: [])
        let data = try encoder.encode(value)
        XCTAssertEqual("0020000002000003e8", data.hexEncodedString())
    }

    func testLineString2D() throws {
        let value = WKBLineString(points: [ WKBPoint(vector: [1,2]), WKBPoint(vector: [2,3]) ])
        let data = try encoder.encode(value)
        XCTAssertEqual("0020000002000003e8000000023ff0000000000000400000000000000040000000000000004008000000000000", data.hexEncodedString())
        let value2 = try decoder.decode(from: data) as! WKBLineString
        XCTAssertEqual(value, value2)
    }

    func testLineString3D() throws {
        let value = WKBLineString(points: [ WKBPoint(vector: [1,2,3]), WKBPoint(vector: [4,5,6]) ])
        let data = try encoder.encode(value)
        XCTAssertEqual("00a0000002000003e8000000023ff000000000000040000000000000004008000000000000401000000000000040140000000000004018000000000000", data.hexEncodedString())
        let value2 = try decoder.decode(from: data) as! WKBLineString
        XCTAssertEqual(value, value2)
    }

    func testLineString4D() throws {
        let value = WKBLineString(points: [ WKBPoint(vector: [1,2,3,4]), WKBPoint(vector: [5,6,7,8]) ])
        let data = try encoder.encode(value)
        XCTAssertEqual("00e0000002000003e8000000023ff000000000000040000000000000004008000000000000401000000000000040140000000000004018000000000000401c0000000000004020000000000000", data.hexEncodedString())
        let value2 = try decoder.decode(from: data) as! WKBLineString
        XCTAssertEqual(value, value2)
    }

    func testPolygonEmpty() throws {
        let value = WKBPolygon(exteriorRing: WKBLineString(points: []))
        let data = try encoder.encode(value)
        XCTAssertEqual("0020000003000003e800000000", data.hexEncodedString())
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
        XCTAssertEqual("0020000003000003e800000001000000043ff0000000000000400000000000000040080000000000004010000000000000401800000000000040140000000000003ff00000000000004000000000000000", data.hexEncodedString())
    }
}
