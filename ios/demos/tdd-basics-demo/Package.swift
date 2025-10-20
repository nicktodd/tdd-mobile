// swift-tools-version: 5.8
import PackageDescription

let package = Package(
    name: "TDDBasicsDemo",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "Calculator",
            targets: ["Calculator"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/Brightify/Cuckoo.git", from: "1.6.0")
    ],
    targets: [
        .target(
            name: "Calculator",
            dependencies: []
        ),
        .testTarget(
            name: "CalculatorTests",
            dependencies: ["Calculator", "Cuckoo"]
        ),
    ]
)
