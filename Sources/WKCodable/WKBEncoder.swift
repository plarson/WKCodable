import Foundation

public class WKBEncoder {
    public init(byteOrder: ByteOrder = .bigEndian) {
        self.byteOrder = byteOrder
    }
    fileprivate let byteOrder: ByteOrder
    fileprivate var data: Data = Data()
}

public extension WKBEncoder {
    enum Error: Swift.Error {
        case typeNotConformingToWKBGeometry(Any.Type)
    }
}

public extension WKBEncoder {
    
    // MARK: - Public
    
    func encode(_ value: Geometry) -> Data {
        data = Data()
        encode(value, withSrid: true)
        return data
    }
    
    // MARK: - Private

    private func encode(_ value: Point, withSrid: Bool) {
        appendByteOrder()
        appendTypeCode(WKBTypeCode.point.rawValue, for: value, srid: (withSrid ? value.srid : nil))
        append(value)
    }
    
    private func encode(_ value: LineString, withSrid: Bool) {
        appendByteOrder()
        appendTypeCode(WKBTypeCode.lineString.rawValue, for: value.points.first, srid: (withSrid ? value.srid : nil))
        if value.points.count > 0 {
            append(value)
        }
    }
    
    private func encode(_ value: Polygon, withSrid: Bool) {
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
    
    private func encode(_ value: MultiPoint, withSrid: Bool) {
        appendByteOrder()
        appendTypeCode(WKBTypeCode.multiPoint.rawValue, for: value.points.first, srid: (withSrid ? value.srid : nil))
        if value.points.count > 0 {
            append(value)
        }
    }
    
    private func encode(_ value: MultiLineString, withSrid: Bool) {
        appendByteOrder()
        appendTypeCode(WKBTypeCode.multiLineString.rawValue, for: value.lineStrings.first?.points.first, srid: (withSrid ? value.srid : nil))
        if value.lineStrings.count > 0 {
            append(value)
        }
    }
    
    private func encode(_ value: MultiPolygon, withSrid: Bool) {
        appendByteOrder()
        appendTypeCode(WKBTypeCode.multiPolygon.rawValue, for: value.polygons.first?.exteriorRing.points.first, srid: (withSrid ? value.srid : nil))
        if value.polygons.count > 0 {
            append(value)
        }
    }
    
    private func encode(_ value: GeometryCollection, withSrid: Bool) {
        appendByteOrder()
        appendTypeCode(WKBTypeCode.geometryCollection.rawValue, for: nil, srid: (withSrid ? value.srid : nil))
        if value.geometries.count > 0 {
            append(value)
        }
    }
    
    private func encode(_ value: Geometry, withSrid: Bool) {
        if let value = value as? Point {
            encode(value, withSrid: withSrid)
        } else if let value = value as? LineString {
            encode(value, withSrid: withSrid)
        } else if let value = value as? Polygon {
            encode(value, withSrid: withSrid)
        } else if let value = value as? MultiPoint {
            encode(value, withSrid: withSrid)
        } else if let value = value as? MultiLineString {
            encode(value, withSrid: withSrid)
        } else if let value = value as? MultiPolygon {
            encode(value, withSrid: withSrid)
        } else if let value = value as? GeometryCollection {
            encode(value, withSrid: withSrid)
        } else {
            assertionFailure()
        }
    }
    
    private func appendByteOrder() {
        appendBytes(of: (byteOrder == .bigEndian ? byteOrder.rawValue.bigEndian : byteOrder.rawValue.littleEndian))
    }
    
    private func appendTypeCode(_ typeCode: UInt32, for point: Point? = nil, srid: UInt?) {
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
    
    private func append(_ value: Point) {
        append(value.x)
        append(value.y)
        if let z = value.z {
            append(z)
        }
        if let m = value.m {
            append(m)
        }
    }
    
    private func append(_ value: LineString) {
        append(UInt32(value.points.count))
        for point in value.points {
            append(point)
        }
    }
    
    private func append(_ value: MultiPoint) {
        append(UInt32(value.points.count))
        for subvalue in value.points {
            encode(subvalue, withSrid: false)
        }
    }
    
    private func append(_ value: MultiLineString) {
        append(UInt32(value.lineStrings.count))
        for subvalue in value.lineStrings {
            encode(subvalue, withSrid: false)
        }
    }
    
    private func append(_ value: MultiPolygon) {
        append(UInt32(value.polygons.count))
        for subvalue in value.polygons {
            encode(subvalue, withSrid: false)
        }
    }
    
    private func append(_ value: GeometryCollection) {
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
