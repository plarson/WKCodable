// swift-tools-version:4.2
import PackageDescription

var package = Package(
    name: "WKBCodable",
    products: [
        .library(name: "WKBCodable", targets: ["WKBCodable"]),
    ],
    targets: [
        .target(name: "WKBCodable"),
        .testTarget(
            name: "WKBCodableTests",
            dependencies: ["WKBCodable"]),
    ]
)
