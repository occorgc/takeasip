// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "WaterReminder",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(name: "WaterReminder", targets: ["WaterReminder"])
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "WaterReminder",
            dependencies: [],
            path: "Sources"
        )
    ]
)
