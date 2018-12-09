import Foundation

public class WKBEncoder {
    public init(byteOrder: WKBByteOrder = .bigEndian) {
        self.byteOrder = byteOrder
    }
    fileprivate let byteOrder: WKBByteOrder
    fileprivate var data: Data = Data()
}

public extension WKBEncoder {
    enum Error: Swift.Error {
        case typeNotConformingToWKBGeometry(Any.Type)
    }
}

public extension WKBEncoder {
    
    // MARK: - Public
    
    public func encode(_ value: WKBPoint) throws -> Data {
        return try encode(value, withSrid: true)
    }
    
    public func encode(_ value: WKBLineString) throws -> Data {
        return try encode(value, withSrid: true)
    }
    
    public func encode(_ value: WKBPolygon) throws -> Data {
        return try encode(value, withSrid: true)
    }
    
    public func encode(_ value: WKBMultiPoint) throws -> Data {
        return try encode(value, withSrid: true)
    }
    
    public func encode(_ value: WKBMultiLineString) throws -> Data {
        return try encode(value, withSrid: true)
    }
    
    public func encode(_ value: WKBMultiPolygon) throws -> Data {
        return try encode(value, withSrid: true)
    }
    
    public func encode(_ value: WKBGeometryCollection) throws -> Data {
        return try encode(value, withSrid: true)
    }
    
    // MARK: - Private

    @discardableResult
    private func encode(_ value: WKBPoint, withSrid: Bool) throws -> Data {
        appendByteOrder()
        appendTypeCode(WKBTypeCode.point.rawValue, for: value, srid: (withSrid ? value.srid : nil))
        append(value)
        return data
    }
    
    @discardableResult
    private func encode(_ value: WKBLineString, withSrid: Bool) throws -> Data {
        appendByteOrder()
        appendTypeCode(WKBTypeCode.lineString.rawValue, for: value.points.first, srid: (withSrid ? value.srid : nil))
        if value.points.count > 0 {
            append(value)
        }
        return data
    }
    
    @discardableResult
    private func encode(_ value: WKBPolygon, withSrid: Bool) throws -> Data {
        appendByteOrder()
        appendTypeCode(WKBTypeCode.polygon.rawValue, for: value.exteriorRing.points.first, srid: (withSrid ? value.srid : nil))
        if value.exteriorRing.points.count == 0 {
            append(UInt32(0))
        } else {
            append(UInt32(1 + (value.interiorRings?.count ?? 0)))
            append(value.exteriorRing)
            for interiorRing in value.interiorRings ?? [] {
                append(interiorRing)
            }
        }
        return data
    }
    
    @discardableResult
    private func encode(_ value: WKBMultiPoint, withSrid: Bool) throws -> Data {
        appendByteOrder()
        appendTypeCode(WKBTypeCode.multiPoint.rawValue, for: value.points.first, srid: (withSrid ? value.srid : nil))
        if value.points.count > 0 {
            try append(value)
        }
        return data
    }
    
    @discardableResult
    private func encode(_ value: WKBMultiLineString, withSrid: Bool) throws -> Data {
        appendByteOrder()
        appendTypeCode(WKBTypeCode.multiLineString.rawValue, for: value.lineStrings.first?.points.first, srid: (withSrid ? value.srid : nil))
        if value.lineStrings.count > 0 {
            try append(value)
        }
        return data
    }
    
    @discardableResult
    private func encode(_ value: WKBMultiPolygon, withSrid: Bool) throws -> Data {
        appendByteOrder()
        appendTypeCode(WKBTypeCode.multiPolygon.rawValue, for: value.polygons.first?.exteriorRing.points.first, srid: (withSrid ? value.srid : nil))
        if value.polygons.count > 0 {
            try append(value)
        }
        return data
    }
    
    @discardableResult
    private func encode(_ value: WKBGeometryCollection, withSrid: Bool) throws -> Data {
        appendByteOrder()
        appendTypeCode(WKBTypeCode.geometryCollection.rawValue, for: nil, srid: (withSrid ? value.srid : nil))
        if value.geometries.count > 0 {
            try append(value)
        }
        return data
    }
    
    @discardableResult
    private func encode(_ value: WKBGeometry, withSrid: Bool) throws -> Data {
        if let value = value as? WKBPoint {
            return try encode(value, withSrid: withSrid)
        } else if let value = value as? WKBLineString {
            return try encode(value, withSrid: withSrid)
        }else if let value = value as? WKBPolygon {
            return try encode(value, withSrid: withSrid)
        } else if let value = value as? WKBMultiPoint {
            return try encode(value, withSrid: withSrid)
        } else if let value = value as? WKBMultiLineString {
            return try encode(value, withSrid: withSrid)
        } else if let value = value as? WKBMultiPolygon {
            return try encode(value, withSrid: withSrid)
        } else if let value = value as? WKBGeometryCollection {
            return try encode(value, withSrid: withSrid)
        } else {
            throw Error.typeNotConformingToWKBGeometry(type(of: value))
        }
    }
    
    private func appendByteOrder() {
        appendBytes(of: (byteOrder == .bigEndian ? byteOrder.rawValue.bigEndian : byteOrder.rawValue.littleEndian))
    }
    
    private func appendTypeCode(_ typeCode: UInt32, for point: WKBPoint? = nil, srid: UInt?) {
        var typeCode = typeCode
        
        if point?.z != nil {
            typeCode |= 0x80000000
        }
        
        if point?.m != nil {
            typeCode |= 0x40000000
        }
        
        if srid != nil {
            typeCode |= 0x20000000
        }
    
        append(typeCode)
        
        if let srid = srid {
            append(UInt32(srid))
        }
    }
    
    private func append(_ value: UInt32) {
        appendBytes(of: (byteOrder == .bigEndian ? value.bigEndian : value.littleEndian))
    }

    private func append(_ value: Double) {
        appendBytes(of: (byteOrder == .bigEndian ? value.bitPattern.bigEndian : value.bitPattern.littleEndian))
    }
    
    private func append(_ value: WKBPoint) {
        append(value.x)
        append(value.y)
        if let z = value.z {
            append(z)
        }
        if let m = value.m {
            append(m)
        }
    }
    
    private func append(_ value: WKBLineString) {
        append(UInt32(value.points.count))
        for point in value.points {
            append(point)
        }
    }
    
    private func append(_ value: WKBMultiPoint) throws {
        append(UInt32(value.points.count))
        for subvalue in value.points {
            try encode(subvalue, withSrid: false)
        }
    }
    
    private func append(_ value: WKBMultiLineString) throws {
        append(UInt32(value.lineStrings.count))
        for subvalue in value.lineStrings {
            try encode(subvalue, withSrid: false)
        }
    }
    
    private func append(_ value: WKBMultiPolygon) throws {
        append(UInt32(value.polygons.count))
        for subvalue in value.polygons {
            try encode(subvalue, withSrid: false)
        }
    }
    
    private func append(_ value: WKBGeometryCollection) throws {
        append(UInt32(value.geometries.count))
        for subvalue in value.geometries {
            try encode(subvalue, withSrid: false)
        }
    }

    private func appendBytes<T>(of value: T) {
        var value = value
        withUnsafeBytes(of: &value) {
            data += $0
        }

    }
}
