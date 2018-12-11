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
    
    public func encode(_ value: WKBGeometry) -> Data {
        data = Data()
        encode(value, withSrid: true)
        return data
    }
    
    // MARK: - Private

    private func encode(_ value: WKBPoint, withSrid: Bool) {
        appendByteOrder()
        appendTypeCode(WKBTypeCode.point.rawValue, for: value, srid: (withSrid ? value.srid : nil))
        append(value)
    }
    
    private func encode(_ value: WKBLineString, withSrid: Bool) {
        appendByteOrder()
        appendTypeCode(WKBTypeCode.lineString.rawValue, for: value.points.first, srid: (withSrid ? value.srid : nil))
        if value.points.count > 0 {
            append(value)
        }
    }
    
    private func encode(_ value: WKBPolygon, withSrid: Bool) {
        appendByteOrder()
        appendTypeCode(WKBTypeCode.polygon.rawValue, for: value.exteriorRing.points.first, srid: (withSrid ? value.srid : nil))
        if value.exteriorRing.points.count == 0 {
            append(UInt32(0))
        } else {
            append(UInt32(1 + value.interiorRings.count))
            append(value.exteriorRing)
            for interiorRing in value.interiorRings {
                append(interiorRing)
            }
        }
    }
    
    private func encode(_ value: WKBMultiPoint, withSrid: Bool) {
        appendByteOrder()
        appendTypeCode(WKBTypeCode.multiPoint.rawValue, for: value.points.first, srid: (withSrid ? value.srid : nil))
        if value.points.count > 0 {
            append(value)
        }
    }
    
    private func encode(_ value: WKBMultiLineString, withSrid: Bool) {
        appendByteOrder()
        appendTypeCode(WKBTypeCode.multiLineString.rawValue, for: value.lineStrings.first?.points.first, srid: (withSrid ? value.srid : nil))
        if value.lineStrings.count > 0 {
            append(value)
        }
    }
    
    private func encode(_ value: WKBMultiPolygon, withSrid: Bool) {
        appendByteOrder()
        appendTypeCode(WKBTypeCode.multiPolygon.rawValue, for: value.polygons.first?.exteriorRing.points.first, srid: (withSrid ? value.srid : nil))
        if value.polygons.count > 0 {
            append(value)
        }
    }
    
    private func encode(_ value: WKBGeometryCollection, withSrid: Bool) {
        appendByteOrder()
        appendTypeCode(WKBTypeCode.geometryCollection.rawValue, for: nil, srid: (withSrid ? value.srid : nil))
        if value.geometries.count > 0 {
            append(value)
        }
    }
    
    private func encode(_ value: WKBGeometry, withSrid: Bool) {
        if let value = value as? WKBPoint {
            encode(value, withSrid: withSrid)
        } else if let value = value as? WKBLineString {
            encode(value, withSrid: withSrid)
        } else if let value = value as? WKBPolygon {
            encode(value, withSrid: withSrid)
        } else if let value = value as? WKBMultiPoint {
            encode(value, withSrid: withSrid)
        } else if let value = value as? WKBMultiLineString {
            encode(value, withSrid: withSrid)
        } else if let value = value as? WKBMultiPolygon {
            encode(value, withSrid: withSrid)
        } else if let value = value as? WKBGeometryCollection {
            encode(value, withSrid: withSrid)
        } else {
            assertionFailure()
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
    
    private func append(_ value: WKBMultiPoint) {
        append(UInt32(value.points.count))
        for subvalue in value.points {
            encode(subvalue, withSrid: false)
        }
    }
    
    private func append(_ value: WKBMultiLineString) {
        append(UInt32(value.lineStrings.count))
        for subvalue in value.lineStrings {
            encode(subvalue, withSrid: false)
        }
    }
    
    private func append(_ value: WKBMultiPolygon) {
        append(UInt32(value.polygons.count))
        for subvalue in value.polygons {
            encode(subvalue, withSrid: false)
        }
    }
    
    private func append(_ value: WKBGeometryCollection) {
        append(UInt32(value.geometries.count))
        for subvalue in value.geometries {
            encode(subvalue, withSrid: false)
        }
    }

    private func appendBytes<T>(of value: T) {
        var value = value
        withUnsafeBytes(of: &value) {
            data += $0
        }

    }
}
