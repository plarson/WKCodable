import Foundation

public protocol WKBCodable {
    var srid: UInt { get }
}

public typealias WKBGeometry = WKBCodable & Equatable

enum WKBTypeCode: UInt32 {
    case point = 1
    case lineString = 2
    case polygon = 3
    case multiPoint = 4
    case multiLineString = 5
    case multiPolygon = 6
    case geometryCollection = 7
}

public struct WKBPoint: WKBGeometry {
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

public struct WKBLineString: WKBGeometry {
    public init(points: [WKBPoint], srid: UInt? = nil) {
        self.points = points
        self.srid = srid ?? 1000
    }
    public let points: [WKBPoint]
    public let srid: UInt
}

public struct WKBPolygon: WKBGeometry {
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

public struct WKBMultiPoint: WKBGeometry {
    public init(points: [WKBPoint], srid: UInt? = nil) {
        self.points = points
        self.srid = srid ?? 1000
    }
    public let points: [WKBPoint]
    public let srid: UInt
}

public struct WKBMultiLineString: WKBGeometry {
    public init(lineStrings: [WKBLineString], srid: UInt? = nil) {
        self.lineStrings = lineStrings
        self.srid = srid ?? 1000
    }
    public let lineStrings: [WKBLineString]
    public let srid: UInt
}

public struct WKBMultiPolygon: WKBGeometry {
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
