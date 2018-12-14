import Foundation

public class WKBDecoder {
    public init() {}
    fileprivate var bytes: [UInt8] = []
    fileprivate var offset: Int = 0
    fileprivate var byteOrder: ByteOrder = .bigEndian
    fileprivate var typeCode: UInt32 = 0
    fileprivate var pointSize: UInt8 = 2
    fileprivate var srid: UInt32 = 2
}

public extension WKBDecoder {
    enum Error: Swift.Error {
        case dataCorrupted
        case unexpectedType
    }
}

extension WKBDecoder {
    
    // MARK: - Public

    public func decode<T>(from data: Data) throws -> T {
        guard let value = try decode(from: [UInt8](data)) as? T else {
            throw Error.unexpectedType
        }
        return value
    }
    
    // MARK: - Private
    
    private func decode(from bytes: [UInt8], srid: UInt32? = nil) throws -> Geometry {
        self.bytes = bytes
        return try decode(srid: nil)
    }
    
    private func decode(srid: UInt32? = nil) throws -> Geometry {
        var srid = srid
        guard let byteOrder = ByteOrder(rawValue: try decode(UInt8.self)) else {
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
        if srid == nil {
            typeCode &= 0x0fffffff
            srid = try decode(UInt32.self)
        }
        var result: Geometry?
        if typeCode == WKBTypeCode.point.rawValue {
            result = try decode(Point.self)
        } else if typeCode == WKBTypeCode.lineString.rawValue {
            result = try decode(LineString.self)
        } else if typeCode == WKBTypeCode.polygon.rawValue {
            result = try decode(Polygon.self)
        } else if typeCode == WKBTypeCode.multiPoint.rawValue {
            result = try decode(MultiPoint.self)
        } else if typeCode == WKBTypeCode.multiLineString.rawValue {
            result = try decode(MultiLineString.self)
        } else if typeCode == WKBTypeCode.multiPolygon.rawValue {
            result = try decode(MultiPolygon.self)
        } else if typeCode == WKBTypeCode.geometryCollection.rawValue {
            result = try decode(GeometryCollection.self)
        }
        
        if result == nil {
            throw Error.dataCorrupted
        } else {
            return result!
        }
    }
    
    private func decode(_ type: Point.Type) throws -> Point {
        var vector: [Double] = []
        for _ in 0..<pointSize {
            let val = try decode(Double.self)
            vector.append(val)
        }
        return Point(vector: vector)
    }
    
    private func decode(_ type: LineString.Type) throws -> LineString {
        guard let count: UInt32 = try? decode(UInt32.self) else {
            // Empty case
            return LineString(points: [])
        }
        
        var points: [Point] = []
        for _ in 0..<count {
            points.append(try decode(Point.self))
        }
        return LineString(points: points)
    }

    private func decode(_ type: Polygon.Type) throws -> Polygon {
        let count: UInt32 = try decode(UInt32.self)
        
        if count == 0 {
            return Polygon(exteriorRing: LineString(points: []))
        } else {
            let exteriorRing: LineString = try decode(LineString.self)
            var interiorRings: [LineString] = []
            
            if count > 1 {
                for _ in 0..<count - 1 {
                    interiorRings.append(try decode(LineString.self))
                }
            }
            
            return Polygon(exteriorRing: exteriorRing, interiorRings: interiorRings)
        }
    }
    
    private func decode(_ type: MultiPoint.Type) throws -> MultiPoint {
        guard let count: UInt32 = try? decode(UInt32.self) else {
            // Empty case
            return MultiPoint(points: [])
        }
        var subvalues: [Point] = []
        for _ in 0..<count {
            guard let subvalue = try decode(srid: self.srid) as? Point else {
                throw Error.dataCorrupted
            }
            
            subvalues.append(subvalue)
        }
        return MultiPoint(points: subvalues)
    }
    
    private func decode(_ type: MultiLineString.Type) throws -> MultiLineString {
        guard let count: UInt32 = try? decode(UInt32.self) else {
            // Empty case
            return MultiLineString(lineStrings: [])
        }
        var subvalues: [LineString] = []
        for _ in 0..<count {
            guard let subvalue = try decode(srid: self.srid) as? LineString else {
                throw Error.dataCorrupted
            }
            
            subvalues.append(subvalue)
        }
        return MultiLineString(lineStrings: subvalues)
    }
    
    private func decode(_ type: MultiPolygon.Type) throws -> MultiPolygon {
        guard let count: UInt32 = try? decode(UInt32.self) else {
            // Empty case
            return MultiPolygon(polygons: [])
        }
        var subvalues: [Polygon] = []
        for _ in 0..<count {
            guard let subvalue = try decode(srid: self.srid) as? Polygon else {
                throw Error.dataCorrupted
            }
            
            subvalues.append(subvalue)
        }
        return MultiPolygon(polygons: subvalues)
    }
    
    private func decode(_ type: GeometryCollection.Type) throws -> GeometryCollection {
        guard let count: UInt32 = try? decode(UInt32.self) else {
            // Empty case
            return GeometryCollection(geometries: [])
        }
        var subvalues: [Geometry] = []
        for _ in 0..<count {
            let subvalue = try decode(srid: self.srid)
            subvalues.append(subvalue)
        }
        return GeometryCollection(geometries: subvalues)
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
