import Foundation
import CoreFoundation

public class WKBDecoder {
    public init() {}
    fileprivate var bytes: [UInt8] = []
    fileprivate var offset: Int = 0
    fileprivate var byteOrder: UInt8 = 0
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
        byteOrder = try decode(UInt8.self)
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
        }
        
        if result == nil {
            throw Error.dataCorrupted
        } else {
            return result!
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
        return value.bigEndian
    }
    
    private func decode(_ type: UInt32.Type) throws -> UInt32 {
        var value: UInt32 = 0
        try read(into: &value)
        return value.bigEndian
    }
    
    private func decode(_ type: Double.Type) throws -> Double {
        var value = CFSwappedFloat64()
        try read(into: &value)
        return CFConvertFloat64SwappedToHost(value)
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
