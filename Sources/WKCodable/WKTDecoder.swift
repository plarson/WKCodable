import Foundation

public class WKTDecoder {
    public init() {}
    private var srid: UInt = 0
    private var scanner: Scanner!
}

public extension WKTDecoder {
    enum Error: Swift.Error {
        case dataCorrupted
        case unexpectedType
    }
}

public extension WKTDecoder {
    
    // MARK: - Public

    func decode<T>(from value: String) throws -> T {
        scanner = Scanner(string: value)
        scanner.charactersToBeSkipped = CharacterSet.whitespaces
        scanner.caseSensitive = false
        srid = try scanSRID()
        guard let value = try scanGeometry() as? T else {
                throw Error.unexpectedType
        }
        return value
    }
    
    // MARK: - Private
    
    func scanSRID() throws -> UInt {
        if !scanner.scanString("SRID=", into: nil) {
            throw Error.dataCorrupted
        }
        
        var srid: Int32 = 0
        if !scanner.scanInt32(&srid) {
            throw Error.dataCorrupted
        }
        
        if !scanner.scanString(";", into: nil) {
            throw Error.dataCorrupted
        }

        return UInt(srid)
    }
    
    func scanGeometry() throws -> Geometry? {
        guard let type = scanType() else {
            throw Error.dataCorrupted
        }
        
        let empty = self.scanEmpty()
        
        switch type {
        case .point:
            guard let point = scanPoint() else {
                throw Error.dataCorrupted
            }
            return point
        case .lineString:
            if empty{
                return LineString()
            } else {
                var points: [Point] = []
                while let point = scanPoint() {
                    points.append(point)
                }
                return LineString(points: points)
            }
        case .polygon:
            if empty {
                return Polygon(exteriorRing: LineString(points:[]))
            } else {
                var lineStrings: [LineString] = []
                while let lineString = scanLineString() {
                    lineStrings.append(lineString)
                }
                return Polygon(exteriorRing: lineStrings.first!)
            }
        case .multiPoint:
            if empty {
                return MultiPoint(points: [])
            } else {
                var points: [Point] = []
                while scanner.scanString("(", into: nil), let point = scanPoint() {
                    points.append(point)
                    if !scanner.scanString(",", into: nil) {
                        break
                    }
                }
                return MultiPoint(points: points)
            }
        case .multiLineString:
            if empty {
                return MultiLineString(lineStrings: [])
            } else {
                var lineStrings: [LineString] = []
                while let lineString = scanLineString() {
                    lineStrings.append(lineString)
                }
                return MultiLineString(lineStrings: lineStrings)
            }
        case .multiPolygon:
            if empty {
                return MultiPolygon(polygons: [])
            } else {
                var polygons: [Polygon] = []
                while let polygon = scanPolygon() {
                    polygons.append(polygon)
                }
                return MultiPolygon(polygons: polygons)
            }
        case .geometryCollection:
            if empty {
                return GeometryCollection(geometries: [])
            } else {
                var geometries: [Geometry] = []
                while let geometry = try scanGeometry() {
                    geometries.append(geometry)
                    if scanner.isAtEnd || scanner.scanString(")", into: nil) {
                        break
                    }
                }
                return GeometryCollection(geometries: geometries)
            }
        }
    }
    
    private func scanType() -> WKTTypeCode? {
        #if !os(macOS)
        var rawType: String? = ""
        #else
        var rawType: NSString? = ""
        #endif
        let boundarySet = CharacterSet.whitespaces.union(CharacterSet(charactersIn: "("))
        scanner.scanUpToCharacters(from: boundarySet, into: &rawType)
        
        guard let type = WKTTypeCode(rawValue: String(rawType!)) else {
            return nil
        }
        
        return type
    }
    
    func scanEmpty() -> Bool {
        let scanLocation = scanner.scanLocation
        if scanner.scanString("EMPTY", into: nil) {
            return true
        }
        scanner.scanLocation = scanLocation
        if !scanner.scanString("(", into: nil) {
            scanner.scanLocation = scanLocation
        }
        return false
    }
    
    func scanPoint() -> Point? {
        var vector: [Double] = []
        var number: Double = 0.0
        
        while !scanner.scanString(")", into: nil)
            && !scanner.scanString(",", into: nil)
            && scanner.scanDouble(&number) {
            vector.append(number)
        }
        
        if vector.count < 2 {
            return nil
        }
        
        return Point(vector: vector)
    }
    
    func scanLineString() -> LineString? {
        var points: [Point] = []
        
        scanner.scanString("(", into: nil)
        while let point = scanPoint() {
            points.append(point)
        }

        if points.isEmpty {
            return nil
        }
        
        return LineString(points: points)
    }
    
    func scanPolygon() -> Polygon? {
        var lineStrings: [LineString] = []
        
        scanner.scanString("(", into: nil)
        while let lineString = scanLineString() {
            lineStrings.append(lineString)
        }
        
        if lineStrings.isEmpty {
            return nil
        }
        
        let interiorRings = Array(lineStrings[1...])
        return Polygon(exteriorRing: lineStrings.first!, interiorRings: interiorRings)
    }
    
}
