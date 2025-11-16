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
        // No external dependencies needed for manual mocking examples
    ],
    targets: [
        .target(
            name: "Calculator",
            dependencies: []
        ),
        .target(name: "SpeakingClock", dependencies: []),
        .testTarget(
            name: "CalculatorTests",
            dependencies: ["Calculator"]
        ),
        .testTarget(
            name: "SpeakingClockTests",
            dependencies: ["SpeakingClock"]
            )
    ]
)
