// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "SceneStorageProbe",
    platforms: [.macOS(.v14), .iOS(.v17)],
    dependencies: [.package(name: "SwiftHelpers", path: "../../..")],
    targets: [.executableTarget(
        name: "SceneStorageProbe",
        dependencies: [.product(name: "SwiftStorage", package: "SwiftHelpers")]
    )]
)
