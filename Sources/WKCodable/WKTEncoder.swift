import Foundation

public class WKTEncoder {
    public init() {}
    private var result: String = ""
}

public extension WKTEncoder {
    
    // MARK: - Public

    func encode(_ value: Geometry) -> String {
        result = String()
        encode(value, withSrid: true)
        return result
    }
    
    // MARK: - Private
    
    private func encode(_ value: Point, withSrid: Bool) {
        appendTypeCode(WKTTypeCode.point.rawValue, for: value, srid: (withSrid ? value.srid : nil))
        append("(")
        append(string(for: value))
        append(")")
    }
    
    private func encode(_ value: LineString, withSrid: Bool) {
        appendTypeCode(WKTTypeCode.lineString.rawValue, for: value.points.first, srid: (withSrid ? value.srid : nil))
        if value.points.count > 0 {
            append(string(for: value))
        } else {
            append(" EMPTY")
        }
    }
    
    private func encode(_ value: Polygon, withSrid: Bool) {
        appendTypeCode(WKTTypeCode.polygon.rawValue, for: value.exteriorRing.points.first, srid: (withSrid ? value.srid : nil))
        if value.exteriorRing.points.count == 0 {
            append(" EMPTY")
        } else {
            append("(")
            let components = value.lineStrings.map { string(for: $0) }
            append(components.joined(separator: ", "))
            append(")")
        }
    }
    
    private func encode(_ value: MultiPoint, withSrid: Bool) {
        appendTypeCode(WKTTypeCode.multiPoint.rawValue, for: value.points.first, srid: (withSrid ? value.srid : nil))
        if value.points.count > 0 {
            append("(")
            let components = value.points.map { "(" + string(for: $0) + ")" }
            append(components.joined(separator: ", "))
            append(")")
        } else {
            append(" EMPTY")
        }
    }
    
    private func encode(_ value: MultiLineString, withSrid: Bool) {
        appendTypeCode(WKTTypeCode.multiLineString.rawValue, for: value.lineStrings.first?.points.first, srid: (withSrid ? value.srid : nil))
        if value.lineStrings.count > 0 {
            append("(")
            let components = value.lineStrings.map { string(for: $0) }
            append(components.joined(separator: ", "))
            append(")")
        } else {
            append(" EMPTY")
        }
    }
    
    private func encode(_ value: MultiPolygon, withSrid: Bool) {
        appendTypeCode(WKTTypeCode.multiPolygon.rawValue, for: value.polygons.first?.exteriorRing.points.first, srid: (withSrid ? value.srid : nil))
        if value.polygons.count > 0 {
            append("(")
            let components = value.polygons.map { string(for: $0) }
            append(components.joined(separator: ", "))
            append(")")
        } else {
            append(" EMPTY")
        }
    }
    
    private func encode(_ value: GeometryCollection, withSrid: Bool) {
        appendTypeCode(WKTTypeCode.geometryCollection.rawValue, for: nil, srid: (withSrid ? value.srid : nil))
        if value.geometries.count > 0 {
            append("(")
            value.geometries.forEach { encode($0, withSrid: false) }
            append(")")
        } else {
            append(" EMPTY")
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
    
    private func appendTypeCode(_ typeCode: String, for point: Point? = nil, srid: UInt?) {
        var typeCode = typeCode
        
        if let srid = srid {
            typeCode = "SRID=\(srid);" + typeCode
        }

        append(typeCode)
    }
    
    private func append(_ value: UInt32) {
        result += String(value)
    }
    
    private func append(_ value: Double) {
        result += String(value)
    }
    
    private func append(_ value: String) {
        result += value
    }
    
    private func string(for value: Point) -> String {
        var coords: [String] = []
        coords.append(String(value.x))
        coords.append(String(value.y))
        if let z = value.z {
            coords.append(String(z))
        }
        if let m = value.m {
            coords.append(String(m))
        }
        return coords.joined(separator: " ")
    }
    
    private func string(for value: LineString) -> String {
        var string = "("
        string += value.points.map { self.string(for: $0) }.joined(separator: ", ")
        string += ")"
        return string
    }
    
    private func string(for value: Polygon) -> String {
        var string = "("
        string += value.lineStrings.map { self.string(for: $0) }.joined(separator: ", ")
        string += ")"
        return string
    }
    
}

