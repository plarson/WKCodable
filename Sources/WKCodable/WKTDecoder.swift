import Foundation

public class WKTDecoder {
    public init() {}
    private var scanner: Scanner!
}

public extension WKTDecoder {
    enum Error: Swift.Error {
        case dataCorrupted
    }
}

public extension WKTDecoder {
    
    // MARK: - Public
    
    public func decode(from value: String) throws -> WKBGeometry {
        scanner = Scanner(string: value)
        scanner.charactersToBeSkipped = CharacterSet.whitespaces
        scanner.caseSensitive = false
        
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
        
        return try scanGeometry()!
    }
    
    func scanGeometry() throws -> WKBGeometry? {
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
                return WKBLineString(points: [])
            } else {
                var points: [WKBPoint] = []
                while let point = scanPoint() {
                    points.append(point)
                }
                return WKBLineString(points: points)
            }
        case .polygon:
            if empty {
                return WKBPolygon(exteriorRing: WKBLineString(points:[]))
            } else {
                var lineStrings: [WKBLineString] = []
                while let lineString = scanLineString() {
                    lineStrings.append(lineString)
                }
                return WKBPolygon(exteriorRing: lineStrings.first!)
            }
        case .multiPoint:
            if empty {
                return WKBMultiPoint(points: [])
            } else {
                var points: [WKBPoint] = []
                while scanner.scanString("(", into: nil), let point = scanPoint() {
                    points.append(point)
                    if !scanner.scanString(",", into: nil) {
                        break
                    }
                }
                return WKBMultiPoint(points: points)
            }
        case .multiLineString:
            if empty {
                return WKBMultiLineString(lineStrings: [])
            } else {
                var lineStrings: [WKBLineString] = []
                while let lineString = scanLineString() {
                    lineStrings.append(lineString)
                }
                return WKBMultiLineString(lineStrings: lineStrings)
            }
        case .multiPolygon:
            if empty {
                return WKBMultiPolygon(polygons: [])
            } else {
                var polygons: [WKBPolygon] = []
                while let polygon = scanPolygon() {
                    polygons.append(polygon)
                }
                return WKBMultiPolygon(polygons: polygons)
            }
        case .geometryCollection:
            if empty {
                return WKBGeometryCollection(geometries: [])
            } else {
                var geometries: [WKBGeometry] = []
                while let geometry = try scanGeometry() {
                    geometries.append(geometry)
                    if scanner.isAtEnd || scanner.scanString(")", into: nil) {
                        break
                    }
                }
                return WKBGeometryCollection(geometries: geometries)
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
    
    func scanPoint() -> WKBPoint? {
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
        
        return WKBPoint(vector: vector)
    }
    
    func scanLineString() -> WKBLineString? {
        var points: [WKBPoint] = []
        
        scanner.scanString("(", into: nil)
        while let point = scanPoint() {
            points.append(point)
        }

        if points.isEmpty {
            return nil
        }
        
        return WKBLineString(points: points)
    }
    
    func scanPolygon() -> WKBPolygon? {
        var lineStrings: [WKBLineString] = []
        
        scanner.scanString("(", into: nil)
        while let lineString = scanLineString() {
            lineStrings.append(lineString)
        }
        
        if lineStrings.isEmpty {
            return nil
        }
        
        let interiorRings = lineStrings.count > 1 ? Array(lineStrings[1...]) : nil
        return WKBPolygon(exteriorRing: lineStrings.first!, interiorRings: interiorRings)
    }
    
}
