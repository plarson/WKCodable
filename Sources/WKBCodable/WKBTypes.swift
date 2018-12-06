import Foundation

public protocol WKBCodable {
    var srid: UInt { get }
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

public struct WKBPolygon: WKBCodable {
    public init(exteriorRing: WKBLineString, interiorRings: [WKBLineString]? = nil, srid: UInt? = nil) {
        self.exteriorRing = exteriorRing
        self.interiorRings = interiorRings
        self.srid = srid ?? 1000
    }
    public let exteriorRing: WKBLineString
    public let interiorRings: [WKBLineString]?
    public let srid: UInt
}

public protocol WKBMultiPoint: WKBCodable {
}

public protocol WKBMultiLineString: WKBCodable {
}

public protocol WKBMultiPolygon: WKBCodable {
}

public protocol WKBGeometryCollection: WKBCodable {
}
