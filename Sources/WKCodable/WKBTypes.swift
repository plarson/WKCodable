import Foundation

public protocol WKBGeometry {
    var srid: UInt { get }
    func isEqual(to other: WKBGeometry) -> Bool
}

extension WKBGeometry where Self: Equatable {
    public func isEqual(to other: WKBGeometry) -> Bool {
        guard let otherFruit = other as? Self else { return false }
        return self == otherFruit
    }
}
enum WKBTypeCode: UInt32 {
    case point = 1
    case lineString = 2
    case polygon = 3
    case multiPoint = 4
    case multiLineString = 5
    case multiPolygon = 6
    case geometryCollection = 7
}

enum WKTTypeCode: String {
    case point = "Point"
    case lineString = "LineString"
    case polygon = "Polygon"
    case multiPoint = "MultiPoint"
    case multiLineString = "MultiLineString"
    case multiPolygon = "MultiPolygon"
    case geometryCollection = "GeometryCollection"
}

public struct WKBPoint: WKBGeometry, Equatable {
    public init(vector: [Double], srid: UInt? = nil) {
        self.vector = vector
        self.srid = srid ?? 0
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

public struct WKBLineString: WKBGeometry, Equatable {
    public init(srid: UInt? = nil) {
        self.init(points: [], srid: srid)
    }
    public init(points: [WKBPoint], srid: UInt? = nil) {
        self.points = points
        self.srid = srid ?? 0
    }
    public let points: [WKBPoint]
    public let srid: UInt
}

public struct WKBPolygon: WKBGeometry, Equatable {
    public init(exteriorRing: WKBLineString, interiorRings: [WKBLineString]? = nil) {
        self.init(exteriorRing: exteriorRing, interiorRings: interiorRings, srid: nil)
    }
    public init(exteriorRing: WKBLineString, interiorRings: [WKBLineString]? = nil, srid: UInt? = nil) {
        self.exteriorRing = exteriorRing
        self.interiorRings = interiorRings
        self.srid = srid ?? 0
    }
    public let exteriorRing: WKBLineString
    public let interiorRings: [WKBLineString]?
    public let srid: UInt
}

public struct WKBMultiPoint: WKBGeometry, Equatable {
    public init(points: [WKBPoint], srid: UInt? = nil) {
        self.points = points
        self.srid = srid ?? 0
    }
    public let points: [WKBPoint]
    public let srid: UInt
}

public struct WKBMultiLineString: WKBGeometry, Equatable {
    public init(lineStrings: [WKBLineString], srid: UInt? = nil) {
        self.lineStrings = lineStrings
        self.srid = srid ?? 0
    }
    public let lineStrings: [WKBLineString]
    public let srid: UInt
}

public struct WKBMultiPolygon: WKBGeometry, Equatable {
    public init(polygons: [WKBPolygon], srid: UInt? = nil) {
        self.polygons = polygons
        self.srid = srid ?? 0
    }
    public let polygons: [WKBPolygon]
    public let srid: UInt
}

public struct WKBGeometryCollection: WKBGeometry, Equatable {
    public init(geometries: [WKBGeometry], srid: UInt? = nil) {
        self.geometries = geometries
        self.srid = srid ?? 0
    }
    public let geometries: [WKBGeometry]
    public let srid: UInt
    
    public static func == (lhs: WKBGeometryCollection, rhs: WKBGeometryCollection) -> Bool {
        guard lhs.srid == rhs.srid else {
            return false
        }
        guard lhs.geometries.count == rhs.geometries.count else {
            return false
        }
        for i in 0..<lhs.geometries.count {
            guard lhs.geometries[i].isEqual(to: rhs.geometries[i]) else {
                return false
            }
        }
        return true
    }
}

public enum WKBByteOrder: UInt8 {
    case bigEndian = 0
    case littleEndian = 1
}
