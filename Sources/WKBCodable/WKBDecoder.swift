import Foundation

public class WKBDecoder {
    public init() {}
    fileprivate var bytes: [UInt8] = []
    fileprivate var offset: Int = 0
    fileprivate var byteOrder: WKBByteOrder = .bigEndian
    fileprivate var typeCode: UInt32 = 0
    fileprivate var pointSize: UInt8 = 2
    fileprivate var srid: UInt32 = 2
}

public extension WKBDecoder {
    enum Error: Swift.Error {
        case dataCorrupted
    }
}

extension WKBDecoder {
    public func decode(from data: Data) throws -> WKBCodable {
        bytes = [UInt8](data)
        guard let byteOrder = WKBByteOrder(rawValue: try decode(UInt8.self)) else {
            throw Error.dataCorrupted
        }
        self.byteOrder = byteOrder
        typeCode = try decode(UInt32.self)
        pointSize = 2
        if typeCode & 0x80000000 != 0 {
            pointSize += 1
        }
        if typeCode & 0x40000000 != 0 {
            pointSize += 1
        }
        typeCode &= 0x0fffffff
        srid = try decode(UInt32.self)
        
        var result: WKBCodable?
        if typeCode == WKBEncoder.TypeCodes.Point.rawValue {
            result = try decode(WKBPoint.self)
        } else if typeCode == WKBEncoder.TypeCodes.LineString.rawValue {
            result = try decode(WKBLineString.self)
        } else if typeCode == WKBEncoder.TypeCodes.Polygon.rawValue {
            result = try decode(WKBPolygon.self)
        }
        
        if result == nil {
            throw Error.dataCorrupted
        } else {
            return result!
        }
    }

    private func decode(_ type: WKBPolygon.Type) throws -> WKBPolygon {
        let count: UInt32 = try decode(UInt32.self)
        
        if count == 0 {
            return WKBPolygon(exteriorRing: WKBLineString(points: []))
        } else {
            let exteriorRing: WKBLineString = try decode(WKBLineString.self)
            var interiorRings: [WKBLineString]?
            
            if count > 1 {
                interiorRings = []
                for _ in 0..<count - 1 {
                    interiorRings?.append(try decode(WKBLineString.self))
                }
            }

            return WKBPolygon(exteriorRing: exteriorRing, interiorRings: interiorRings)
        }
    }
    
    private func decode(_ type: WKBLineString.Type) throws -> WKBLineString {
        let count: UInt32 = try decode(UInt32.self)
        var points: [WKBPoint] = []
        for _ in 0..<count {
            points.append(try decode(WKBPoint.self))
        }
        return WKBLineString(points: points)
    }
    
    private func decode(_ type: WKBPoint.Type) throws -> WKBPoint {
        var vector: [Double] = []
        for _ in 0..<pointSize {
            let val = try decode(Double.self)
            vector.append(val)
        }
        return WKBPoint(vector: vector)
    }
    
    private func decode(_ type: UInt8.Type) throws -> UInt8 {
        var value: UInt8 = 0
        try read(into: &value)
        return byteOrder == .bigEndian ? value.bigEndian : value.littleEndian
    }
    
    private func decode(_ type: UInt32.Type) throws -> UInt32 {
        var value: UInt32 = 0
        try read(into: &value)
        return byteOrder == .bigEndian ? value.bigEndian : value.littleEndian
    }
    
    private func decode(_ type: Double.Type) throws -> Double {
        var value = UInt64()
        try read(into: &value)
        return Double(bitPattern: byteOrder == .bigEndian ? value.bigEndian : value.littleEndian)
    }

    private func read<T>(into: inout T) throws {
        try read(MemoryLayout<T>.size, into: &into)
    }
    
    func read(_ byteCount: Int, into: UnsafeMutableRawPointer) throws {
        if offset + byteCount > bytes.count {
            throw Error.dataCorrupted
        }
        
        bytes.withUnsafeBytes {
            let from = $0.baseAddress! + offset
            memcpy(into, from, byteCount)
        }
        
        offset += byteCount
    }
}
