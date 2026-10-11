// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "BoiledOne",
    platforms: [
        .macOS(.v14)
    ],
    targets: [
        .executableTarget(
            name: "BoiledOne",
            resources: [
                .copy("Resources")
            ]
        ),
        .testTarget(
            name: "BoiledOneTests",
            dependencies: ["BoiledOne"]
        ),
    ]
)
