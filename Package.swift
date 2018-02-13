// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Atlas",
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/jakeheis/SwiftCLI", from: "4.0.0"),
        .package(url: "https://github.com/powderhouse/AtlasCore.git", from: "0.2.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "Atlas",
            dependencies: ["SwiftCLI", "AtlasCore"]),
    ]
)


// GENERATE: swift package generate-xcodeproj --xcconfig-overrides settings.xcconfig
// BUILD: swift build -Xswiftc "-target" -Xswiftc "x86_64-apple-macosx10.13"
// RUN: swift run -Xswiftc "-target" -Xswiftc "x86_64-apple-macosx10.13" Atlas
