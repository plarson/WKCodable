import Foundation

public protocol WKBCodable {
    var srid: UInt { get }
}

public extension WKBEncoder {
    enum TypeCodes: UInt32 {
        case Point = 1
        case LineString = 2
        case Polygon = 3
        case MultiPoint = 4
        case MultiLineString = 5
        case MultiPolygon = 6
        case GeometryCollection = 7
    }
}

public struct WKBPoint: WKBCodable, Equatable {
    public init(vector: [Double], srid: UInt? = nil) {
        self.vector = vector
        self.srid = srid ?? 1000
    }
    public let vector: [Double]
    public let srid: UInt
    public var x: Double { return vector[0] }
    public var y: Double { return vector[1] }
    public var z: Double? {
        guard vector.count > 2 else { return nil }
        return vector[2]
    }
    public var m: Double? {
        guard vector.count > 3 else { return nil }
        return vector[3]
    }
}

public struct WKBLineString: WKBCodable, Equatable {
    public init(points: [WKBPoint], srid: UInt? = nil) {
        self.points = points
        self.srid = srid ?? 1000
    }
    public let points: [WKBPoint]
    public let srid: UInt
}

public struct WKBPolygon: WKBCodable, Equatable {
    public init(exteriorRing: WKBLineString, interiorRings: [WKBLineString]? = nil) {
        self.init(exteriorRing: exteriorRing, interiorRings: interiorRings, srid: nil)
    }
    public init(exteriorRing: WKBLineString, interiorRings: [WKBLineString]? = nil, srid: UInt? = nil) {
        self.exteriorRing = exteriorRing
        self.interiorRings = interiorRings
        self.srid = srid ?? 1000
    }
    public let exteriorRing: WKBLineString
    public let interiorRings: [WKBLineString]?
    public let srid: UInt
}

public struct WKBMultiPoint: WKBCodable, Equatable {
    public init(points: [WKBPoint], srid: UInt? = nil) {
        self.points = points
        self.srid = srid ?? 1000
    }
    public let points: [WKBPoint]
    public let srid: UInt
}

public struct WKBMultiLineString: WKBCodable, Equatable {
    public init(lineStrings: [WKBLineString], srid: UInt? = nil) {
        self.lineStrings = lineStrings
        self.srid = srid ?? 1000
    }
    public let lineStrings: [WKBLineString]
    public let srid: UInt
}

public struct WKBMultiPolygon: WKBCodable, Equatable {
    public init(polygons: [WKBPolygon], srid: UInt? = nil) {
        self.polygons = polygons
        self.srid = srid ?? 1000
    }
    public let polygons: [WKBPolygon]
    public let srid: UInt
}

public struct WKBGeometryCollection: WKBCodable {    
    public init(geometries: [WKBCodable], srid: UInt? = nil) {
        self.geometries = geometries
        self.srid = srid ?? 1000
    }
    public let geometries: [WKBCodable]
    public let srid: UInt
}

public enum WKBByteOrder: UInt8 {
    case bigEndian = 0
    case littleEndian = 1
}
