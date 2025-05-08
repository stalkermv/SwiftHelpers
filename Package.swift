// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftHelpers",
    platforms: [.macOS(.v12), .iOS(.v14), .tvOS(.v14), .watchOS(.v9), .macCatalyst(.v14)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(name: "SwiftHelpers", targets: ["SwiftHelpers"]),
        .library(name: "SwiftStorage", targets: ["SwiftStorage"]),
        .library(name: "Development", targets: ["Development"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(name: "SwiftHelpers", dependencies: [
            "FoundationExtensions",
            "CombineExtensions",
        ]),
        .target(name: "FoundationExtensions", dependencies: []),
        .target(name: "CombineExtensions", dependencies: []),
        .target(name: "SwiftStorage", dependencies: [
            "FoundationExtensions",
            "CombineExtensions",
        ]),
        .target(name: "Development", dependencies: [
            "SwiftHelpers",
            "FoundationExtensions",
            "CombineExtensions",
        ]),
        .testTarget(
            name: "SwiftHelpersTests",
            dependencies: ["SwiftHelpers"]
        ),
        .testTarget(
            name: "FoundationExtensionsTests",
            dependencies: ["FoundationExtensions"]
        ),
        .testTarget(
            name: "CombineExtensionsTests",
            dependencies: ["CombineExtensions"]
        )
    ]
)
