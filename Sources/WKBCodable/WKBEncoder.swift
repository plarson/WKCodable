import Foundation

public class WKBEncoder {
    public init() {}
    fileprivate var bytes: [UInt8] = []
}

public extension WKBEncoder {
    enum Error: Swift.Error {
        case invalidPoint
        case typeNotConformingToWKBCodable(Any.Type)
    }
}

public extension WKBEncoder {
    enum TypeCodes: UInt32 {
        case Point = 1
        case LineString = 2
        case Polygon = 3
        case MultiPoint = 4
    }
}

public extension WKBEncoder {
    
    func encode(_ value: WKBPoint) throws -> Data {
        appendByteOrder()
        appendTypeCode(TypeCodes.Point.rawValue, for: value)
        append(UInt32(value.srid))
        append(value)
        return Data(bytes: bytes, count: bytes.count)
    }

    func encode(_ value: WKBLineString) throws -> Data {
        appendByteOrder()
        appendTypeCode(TypeCodes.LineString.rawValue, for: value.points.first)
        append(UInt32(value.srid))
        if value.points.count > 0 {
            append(value)
        }
        return Data(bytes: bytes, count: bytes.count)
    }
    
    func encode(_ value: WKBPolygon) throws -> Data {
        appendByteOrder()
        appendTypeCode(TypeCodes.Polygon.rawValue, for: value.exteriorRing.points.first)
        append(UInt32(value.srid))
        
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

    func encode(_ encodable: WKBCodable) throws -> Data {
        throw Error.typeNotConformingToWKBCodable(type(of: encodable))
    }
    
    fileprivate func appendByteOrder() {
        appendBytes(of: UInt8(0))
    }
    
    fileprivate func appendTypeCode(_ typeCode: UInt32, for point: WKBPoint? = nil) {
        var typeCode = typeCode
        
        if point?.z != nil {
            typeCode |= 0x80000000
        }
        
        if point?.m != nil {
            typeCode |= 0x40000000
        }
        
        typeCode |= 0x20000000
        append(typeCode)
    }
    
    fileprivate func append(_ value: UInt32) {
        appendBytes(of: value.bigEndian)
    }

    fileprivate func append(_ value: Double) {
        appendBytes(of: value.bitPattern.bigEndian)
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

    fileprivate func appendBytes<T>(of value: T) {
        var value = value
        withUnsafeBytes(of: &value) {
            bytes.append(contentsOf: $0)
        }
    }
}
