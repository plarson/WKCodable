import Foundation

public class WKBEncoder {
    public init(byteOrder: WKBByteOrder = .bigEndian) {
        self.byteOrder = byteOrder
    }
    fileprivate let byteOrder: WKBByteOrder
    fileprivate var bytes: [UInt8] = []
}

public extension WKBEncoder {
    enum Error: Swift.Error {
        case invalidPoint
        case typeNotConformingToWKBCodable(Any.Type)
    }
}

public extension WKBEncoder {
    
    func encode(_ value: WKBPoint, withSrid: Bool = true) throws -> Data {
        appendByteOrder()
        appendTypeCode(TypeCodes.Point.rawValue, for: value, srid: (withSrid ? value.srid : nil))
        append(value)
        return Data(bytes: bytes, count: bytes.count)
    }
        
    func encode(_ value: WKBLineString, withSrid: Bool = true) throws -> Data {
        appendByteOrder()
        appendTypeCode(TypeCodes.LineString.rawValue, for: value.points.first, srid: (withSrid ? value.srid : nil))
        if value.points.count > 0 {
            append(value)
        }
        return Data(bytes: bytes, count: bytes.count)
    }
    
    func encode(_ value: WKBPolygon, withSrid: Bool = true) throws -> Data {
        appendByteOrder()
        appendTypeCode(TypeCodes.Polygon.rawValue, for: value.exteriorRing.points.first, srid: (withSrid ? value.srid : nil))
        if value.exteriorRing.points.count == 0 {
            append(UInt32(0))
        } else {
            append(UInt32(1 + (value.interiorRings?.count ?? 0)))
            append(value.exteriorRing)
            for interiorRing in value.interiorRings ?? [] {
                append(interiorRing)
            }
        }
        return Data(bytes: bytes, count: bytes.count)
    }
    
    func encode(_ value: WKBMultiPoint, withSrid: Bool = true) throws -> Data {
        appendByteOrder()
        appendTypeCode(TypeCodes.MultiPoint.rawValue, for: value.points.first, srid: (withSrid ? value.srid : nil))
        if value.points.count > 0 {
            try append(value)
        }
        return Data(bytes: bytes, count: bytes.count)
    }
    
    func encode(_ value: WKBMultiLineString, withSrid: Bool = true) throws -> Data {
        appendByteOrder()
        appendTypeCode(TypeCodes.MultiLineString.rawValue, for: value.lineStrings.first?.points.first, srid: (withSrid ? value.srid : nil))
        if value.lineStrings.count > 0 {
            try append(value)
        }
        return Data(bytes: bytes, count: bytes.count)
    }
    
    func encode(_ value: WKBMultiPolygon, withSrid: Bool = true) throws -> Data {
        appendByteOrder()
        appendTypeCode(TypeCodes.MultiPolygon.rawValue, for: value.polygons.first?.exteriorRing.points.first, srid: (withSrid ? value.srid : nil))
        if value.polygons.count > 0 {
            try append(value)
        }
        return Data(bytes: bytes, count: bytes.count)
    }
    
    func encode(_ value: WKBGeometryCollection, withSrid: Bool = true) throws -> Data {
        appendByteOrder()
        appendTypeCode(TypeCodes.GeometryCollection.rawValue, for: nil, srid: (withSrid ? value.srid : nil))
        if value.geometries.count > 0 {
            try append(value)
        }
        return Data(bytes: bytes, count: bytes.count)
    }
    
    func encode(_ encodable: WKBCodable, withSrid: Bool = true) throws -> Data {
        throw Error.typeNotConformingToWKBCodable(type(of: encodable))
    }
    
    fileprivate func appendByteOrder() {
        appendBytes(of: (byteOrder == .bigEndian ? byteOrder.rawValue.bigEndian : byteOrder.rawValue.littleEndian))
    }
    
    fileprivate func appendTypeCode(_ typeCode: UInt32, for point: WKBPoint? = nil, srid: UInt?) {
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
    
    fileprivate func append(_ value: UInt32) {
        appendBytes(of: (byteOrder == .bigEndian ? value.bigEndian : value.littleEndian))
    }

    fileprivate func append(_ value: Double) {
        appendBytes(of: (byteOrder == .bigEndian ? value.bitPattern.bigEndian : value.bitPattern.littleEndian))
    }
    
    fileprivate func append(_ value: WKBPoint) {
        append(value.x)
        append(value.y)
        if let z = value.z {
            append(z)
        }
        if let m = value.m {
            append(m)
        }
    }
    
    fileprivate func append(_ value: WKBLineString) {
        append(UInt32(value.points.count))
        for point in value.points {
            append(point)
        }
    }
    
    fileprivate func append(_ value: WKBMultiPoint) throws {
        append(UInt32(value.points.count))
        for subvalue in value.points {
            // TODO remove uneeded Data
            _ = try encode(subvalue, withSrid: false)
        }
    }
    
    fileprivate func append(_ value: WKBMultiLineString) throws {
        append(UInt32(value.lineStrings.count))
        for subvalue in value.lineStrings {
            // TODO remove uneeded Data
            _ = try encode(subvalue, withSrid: false)
        }
    }
    
    fileprivate func append(_ value: WKBMultiPolygon) throws {
        append(UInt32(value.polygons.count))
        for subvalue in value.polygons {
            // TODO remove uneeded Data
            _ = try encode(subvalue, withSrid: false)
        }
    }
    
    fileprivate func append(_ value: WKBGeometryCollection) throws {
        append(UInt32(value.geometries.count))
        for subvalue in value.geometries {
            // TODO remove uneeded Data
            _ = try encode(subvalue, withSrid: false)
        }
    }

    fileprivate func appendBytes<T>(of value: T) {
        var value = value
        withUnsafeBytes(of: &value) {
            bytes.append(contentsOf: $0)
        }
    }
}
