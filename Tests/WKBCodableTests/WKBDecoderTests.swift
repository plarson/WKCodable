import XCTest
@testable import WKBCodable

class WKBDecoderTests: XCTestCase {

    func testPoint2D() throws {
        let data = Data.from(hex: "0020000001000003e83ff00000000000004000000000000000")
        let decoder = WKBDecoder()
        let value = try decoder.decode(from: data)
        XCTAssertEqual(WKBPoint(vector: [1,2]), value as? WKBPoint)
    }

    func testPoint3D() throws {
        let data = Data.from(hex: "00a0000001000003e83ff000000000000040000000000000004008000000000000")
        let decoder = WKBDecoder()
        let value = try decoder.decode(from: data)
        XCTAssertEqual(WKBPoint(vector: [1,2,3]), value as? WKBPoint)
    }

    func testPoint4D() throws {
        let data = Data.from(hex: "00e0000001000003e83ff0000000000000400000000000000040080000000000004010000000000000")
        let decoder = WKBDecoder()
        let value = try decoder.decode(from: data)
        XCTAssertEqual(WKBPoint(vector: [1,2,3, 4]), value as? WKBPoint)
    }

    func testLineString2D() throws {
        let data = Data.from(hex: "0020000002000003e8000000023ff0000000000000400000000000000040000000000000004008000000000000")
        let decoder = WKBDecoder()
        let value = try decoder.decode(from: data)
        XCTAssertEqual(WKBLineString(points: [ WKBPoint(vector: [1,2]), WKBPoint(vector: [2,3]) ]), value as? WKBLineString)
    }

    func testLineString3D() throws {
        let data = Data.from(hex: "00a0000002000003e8000000023ff000000000000040000000000000004008000000000000401000000000000040140000000000004018000000000000")
        let decoder = WKBDecoder()
        let value = try decoder.decode(from: data)
        XCTAssertEqual(WKBLineString(points: [ WKBPoint(vector: [1,2,3]), WKBPoint(vector: [4,5,6]) ]), value as? WKBLineString)
    }

    func testLineString4D() throws {
        let data = Data.from(hex: "00e0000002000003e8000000023ff000000000000040000000000000004008000000000000401000000000000040140000000000004018000000000000401c0000000000004020000000000000")
        let decoder = WKBDecoder()
        let value = try decoder.decode(from: data)
        XCTAssertEqual(WKBLineString(points: [ WKBPoint(vector: [1,2,3,4]), WKBPoint(vector: [5,6,7,8]) ]), value as? WKBLineString)
    }
}
