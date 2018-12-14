import Foundation

public protocol Geometry {
    var srid: UInt { get }
    func isEqual(to other: Geometry) -> Bool
}

extension Geometry where Self: Equatable {
    public func isEqual(to other: Geometry) -> Bool {
        guard let other = other as? Self else { return false }
        return self == other
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

public struct Point: Geometry, Equatable {
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

public struct LineString: Geometry, Equatable {
    public init(srid: UInt? = nil) {
        self.init(points: [], srid: srid)
    }
    public init(points: [Point], srid: UInt? = nil) {
        self.points = points
        self.srid = srid ?? 0
    }
    public let points: [Point]
    public let srid: UInt
}

public struct Polygon: Geometry, Equatable {
    public init(srid: UInt? = nil) {
        self.init(exteriorRing: LineString(), interiorRings: [], srid: srid)
    }
    public init(exteriorRing: LineString, interiorRings: [LineString] = []) {
        self.init(exteriorRing: exteriorRing, interiorRings: interiorRings, srid: nil)
    }
    public init(exteriorRing: LineString, interiorRings: [LineString] = [], srid: UInt? = nil) {
        self.exteriorRing = exteriorRing
        self.interiorRings = interiorRings
        self.srid = srid ?? 0
    }
    public let exteriorRing: LineString
    public let interiorRings: [LineString]
    public var lineStrings: [LineString] { return [exteriorRing] + interiorRings }
    public let srid: UInt
}

public struct MultiPoint: Geometry, Equatable {
    public init(srid: UInt? = nil) {
        self.init(points: [], srid: srid)
    }
    public init(points: [Point], srid: UInt? = nil) {
        self.points = points
        self.srid = srid ?? 0
    }
    public let points: [Point]
    public let srid: UInt
}

public struct MultiLineString: Geometry, Equatable {
    public init(srid: UInt? = nil) {
        self.init(lineStrings: [], srid: srid)
    }
    public init(lineStrings: [LineString], srid: UInt? = nil) {
        self.lineStrings = lineStrings
        self.srid = srid ?? 0
    }
    public let lineStrings: [LineString]
    public let srid: UInt
}

public struct MultiPolygon: Geometry, Equatable {
    public init(srid: UInt? = nil) {
        self.init(polygons: [], srid: srid)
    }
    public init(polygons: [Polygon], srid: UInt? = nil) {
        self.polygons = polygons
        self.srid = srid ?? 0
    }
    public let polygons: [Polygon]
    public let srid: UInt
}

public struct GeometryCollection: Geometry, Equatable {
    public init(srid: UInt? = nil) {
        self.init(geometries: [], srid: srid)
    }
    public init(geometries: [Geometry], srid: UInt? = nil) {
        self.geometries = geometries
        self.srid = srid ?? 0
    }
    public let geometries: [Geometry]
    public let srid: UInt
    
    public static func == (lhs: GeometryCollection, rhs: GeometryCollection) -> Bool {
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

public enum ByteOrder: UInt8 {
    case bigEndian = 0
    case littleEndian = 1
}
