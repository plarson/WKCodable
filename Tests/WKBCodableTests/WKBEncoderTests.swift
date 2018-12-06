import XCTest
@testable import WKBCodable

class WKBEncoderTests: XCTestCase {

    func testPoint2D() throws {
        let value = WKBPoint(vector: [1,2])
        let encoder = WKBEncoder()
        let data = try encoder.encode(value)
        XCTAssertTrue(data.count > 0)
        XCTAssertEqual("0020000001000003e83ff00000000000004000000000000000", data.hexEncodedString())
    }

    func testPoint3D() throws {
        let value = WKBPoint(vector: [1,2,3])
        let encoder = WKBEncoder()
        let data = try encoder.encode(value)
        XCTAssertTrue(data.count > 0)
        XCTAssertEqual("00a0000001000003e83ff000000000000040000000000000004008000000000000", data.hexEncodedString())
    }

    func testPoint4D() throws {
        let value = WKBPoint(vector: [1,2,3,4])
        let encoder = WKBEncoder()
        let data = try encoder.encode(value)
        XCTAssertTrue(data.count > 0)
        XCTAssertEqual("00e0000001000003e83ff0000000000000400000000000000040080000000000004010000000000000", data.hexEncodedString())
    }

    func testLineString2D() throws {
        let value = WKBLineString(points: [ WKBPoint(vector: [1,2]), WKBPoint(vector: [2,3]) ])
        let encoder = WKBEncoder()
        let data = try encoder.encode(value)
        XCTAssertTrue(data.count > 0)
        XCTAssertEqual("0020000002000003e8000000023ff0000000000000400000000000000040000000000000004008000000000000", data.hexEncodedString())
    }

    func testLineString3D() throws {
        let value = WKBLineString(points: [ WKBPoint(vector: [1,2,3]), WKBPoint(vector: [4,5,6]) ])
        let encoder = WKBEncoder()
        let data = try encoder.encode(value)
        XCTAssertTrue(data.count > 0)
        XCTAssertEqual("00a0000002000003e8000000023ff000000000000040000000000000004008000000000000401000000000000040140000000000004018000000000000", data.hexEncodedString())
    }

    func testLineString4D() throws {
        let value = WKBLineString(points: [ WKBPoint(vector: [1,2,3,4]), WKBPoint(vector: [5,6,7,8]) ])
        let encoder = WKBEncoder()
        let data = try encoder.encode(value)
        XCTAssertTrue(data.count > 0)
        XCTAssertEqual("00e0000002000003e8000000023ff000000000000040000000000000004008000000000000401000000000000040140000000000004018000000000000401c0000000000004020000000000000", data.hexEncodedString())
    }

    func testLineStringEmpty() throws {
        let value = WKBLineString(points: [])
        let encoder = WKBEncoder()
        let data = try encoder.encode(value)
        XCTAssertTrue(data.count > 0)
        XCTAssertEqual("0020000002000003e8", data.hexEncodedString())
    }

}
