// swift-tools-version:4.2
import PackageDescription

var package = Package(
    name: "WKCodable",
    products: [
        .library(name: "WKCodable", targets: ["WKCodable"]),
    ],
    targets: [
        .target(name: "WKCodable"),
        .testTarget(
            name: "WKCodableTests",
            dependencies: ["WKCodable"]),
    ]
)
