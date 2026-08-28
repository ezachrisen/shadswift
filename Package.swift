// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ShadSwift",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "ShadSwift", targets: ["ShadSwift"]),
        .executable(name: "ShadSwiftDemo", targets: ["ShadSwiftDemo"]),
        .executable(name: "ShadSwiftDocs", targets: ["ShadSwiftDocs"]),
    ],
    targets: [
        .target(
            name: "ShadSwift",
            resources: [.process("Resources")],
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),
        .executableTarget(
            name: "ShadSwiftDemo",
            dependencies: ["ShadSwift"],
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),
        .executableTarget(
            name: "ShadSwiftShot",
            dependencies: ["ShadSwift"],
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),
        .executableTarget(
            name: "ShadSwiftDocs",
            dependencies: ["ShadSwift"],
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),
    ]
)
