import XCTest
@testable import WKCodable

class WKBCodableLittleEndianTests: XCTestCase {
    
    var encoder: WKBEncoder!
    var decoder: WKBDecoder!
    
    override func setUp() {
        encoder = WKBEncoder(byteOrder: .littleEndian)
        decoder = WKBDecoder()
    }
    
    func testPoint2D() throws {
        let value = WKBPoint(vector: [1,2])
        let data = try encoder.encode(value)
        XCTAssertEqual("0101000020e8030000000000000000f03f0000000000000040", data.hexEncodedString())
        let value2 = try decoder.decode(from: data) as! WKBPoint
        XCTAssertEqual(value, value2)
    }
    
    func testPoint3D() throws {
        let value = WKBPoint(vector: [1,2,3])
        let data = try encoder.encode(value)
        XCTAssertEqual("01010000a0e8030000000000000000f03f00000000000000400000000000000840", data.hexEncodedString())
        let value2 = try decoder.decode(from: data) as! WKBPoint
        XCTAssertEqual(value, value2)
    }
    
    func testPoint4D() throws {
        let value = WKBPoint(vector: [1,2,3,4])
        let data = try encoder.encode(value)
        XCTAssertEqual("01010000e0e8030000000000000000f03f000000000000004000000000000008400000000000001040", data.hexEncodedString())
        let value2 = try decoder.decode(from: data) as! WKBPoint
        XCTAssertEqual(value, value2)
    }
    
    func testLineStringEmpty() throws {
        let value = WKBLineString(points: [])
        let data = try encoder.encode(value)
        XCTAssertEqual("0102000020e8030000", data.hexEncodedString())
    }
    
    func testLineString2D() throws {
        let value = WKBLineString(points: [ WKBPoint(vector: [1,2]), WKBPoint(vector: [2,3]) ])
        let data = try encoder.encode(value)
        XCTAssertEqual("0102000020e803000002000000000000000000f03f000000000000004000000000000000400000000000000840", data.hexEncodedString())
        let value2 = try decoder.decode(from: data) as! WKBLineString
        XCTAssertEqual(value, value2)
    }
    
    func testLineString3D() throws {
        let value = WKBLineString(points: [ WKBPoint(vector: [1,2,3]), WKBPoint(vector: [4,5,6]) ])
        let data = try encoder.encode(value)
        XCTAssertEqual("01020000a0e803000002000000000000000000f03f00000000000000400000000000000840000000000000104000000000000014400000000000001840", data.hexEncodedString())
        let value2 = try decoder.decode(from: data) as! WKBLineString
        XCTAssertEqual(value, value2)
    }
    
    func testLineString4D() throws {
        let value = WKBLineString(points: [ WKBPoint(vector: [1,2,3,4]), WKBPoint(vector: [5,6,7,8]) ])
        let data = try encoder.encode(value)
        XCTAssertEqual("01020000e0e803000002000000000000000000f03f000000000000004000000000000008400000000000001040000000000000144000000000000018400000000000001c400000000000002040", data.hexEncodedString())
        let value2 = try decoder.decode(from: data) as! WKBLineString
        XCTAssertEqual(value, value2)
    }
    
    func testPolygonEmpty() throws {
        let value = WKBPolygon(exteriorRing: WKBLineString(points: []))
        let data = try encoder.encode(value)
        XCTAssertEqual("0103000020e803000000000000", data.hexEncodedString())
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
        XCTAssertEqual("0103000020e80300000100000004000000000000000000f03f00000000000000400000000000000840000000000000104000000000000018400000000000001440000000000000f03f0000000000000040", data.hexEncodedString())
        let value2 = try decoder.decode(from: data) as! WKBPolygon
        XCTAssertEqual(value, value2)
    }
}
