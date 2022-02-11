// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "OsmiumAtlas",
    platforms: [.macOS(.v11)],
    products: [
        .executable(name: "iosdevdirectory", targets: ["OsmiumAtlas"]),
    ],
    dependencies: [
        .package(url: "https://github.com/MarcoEidinger/swift-argument-parser", .branch("async")),
        .package(url: "https://github.com/SwiftyBeaver/SwiftyBeaver.git", .upToNextMajor(from: "1.9.0")),
        .package(name: "FeedKit", url: "https://github.com/nmdias/FeedKit.git", .upToNextMajor(from: "9.0.0")),
        .package(name: "AsyncCompatibilityKit", url: "https://github.com/KaiOelfke/AsyncCompatibilityKit", .branch("main")),
        .package(name: "OhhAuth", url: "https://github.com/mw99/OhhAuth.git", .upToNextMajor(from: "1.0.0")),
        .package(name: "Swifter", url: "https://github.com/mattdonnelly/Swifter", .upToNextMajor(from: "2.0.0")),
    ],
    targets: [
        .executableTarget(
            name: "OsmiumAtlas",
            dependencies: ["OsmiumAtlasFramework", "Twitter", .product(name: "ArgumentParser", package: "swift-argument-parser")]
        ),
        .target(
            name: "OsmiumAtlasFramework",
            dependencies: ["FeedKit", "AsyncCompatibilityKit", .product(name: "ArgumentParser", package: "swift-argument-parser"), "SwiftyBeaver"]
        ),
        .target(
            name: "Twitter",
            dependencies: ["Swifter", "OhhAuth", "AsyncCompatibilityKit"]
        ),
        .testTarget(
            name: "OsmiumAtlasFrameworkTests",
            dependencies: ["OsmiumAtlasFramework"]
        ),
    ]
)
