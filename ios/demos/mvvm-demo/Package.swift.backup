// swift-tools-version: 5.9
// Package.swift for MVVM Example dependencies

import PackageDescription

let package = Package(
    name: "MVVMExample",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "MVVMExample",
            targets: ["MVVMExample"]
        ),
    ],
    dependencies: [
        // Cuckoo - A mocking framework for Swift
        .package(url: "https://github.com/Brightify/Cuckoo.git", from: "2.0.0"),
        // Nimble - A Matcher Framework for Swift
        .package(url: "https://github.com/Quick/Nimble.git", from: "12.0.0")
    ],
    targets: [
        .target(
            name: "MVVMExample",
            dependencies: []
        ),
        .testTarget(
            name: "MVVMExampleTests",
            dependencies: [
                "MVVMExample",
                "Cuckoo",
                "Nimble"
            ]
        ),
    ]
)