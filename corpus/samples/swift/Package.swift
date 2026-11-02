// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "Sample",
    targets: [
        .target(name: "Util"),
        .target(name: "Sample", dependencies: ["Util"]),
        .testTarget(name: "SampleTests", dependencies: ["Sample"]),
    ]
)
