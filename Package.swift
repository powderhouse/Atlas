// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Atlas",
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/jakeheis/SwiftCLI", .exact("4.0.3")),
        .package(url: "https://github.com/powderhouse/AtlasCore.git", from: "2.0.0"),
        .package(url: "https://github.com/Quick/Quick.git", from: "1.0.0"),
        .package(url: "https://github.com/Quick/Nimble.git", from: "7.0.0"),
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.0.0-beta.2"),
        ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "AtlasCommands",
            dependencies: ["SwiftCLI", "AtlasCore"]),
        .target(
            name: "Atlas",
            dependencies: ["SwiftCLI", "AtlasCore", "AtlasCommands", "Alamofire"]),
        .testTarget(
            name: "AtlasTests",
            dependencies: ["AtlasCommands", "SwiftCLI", "AtlasCore", "Quick", "Nimble"]),
        ]
)
