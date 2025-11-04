// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BRTStudio",
    platforms: [
        .macOS(.v14) // macOS Sonoma+ for latest SwiftUI features
    ],
    products: [
        .executable(
            name: "BRTStudio",
            targets: ["BRTStudio"]
        ),
        .library(
            name: "BRTCore",
            targets: ["BRTCore"]
        )
    ],
    dependencies: [
        // No external dependencies for MVP - keeping it local and secure
        // Future: Add Sparkle for updates when ready
    ],
    targets: [
        // Main Application
        .executableTarget(
            name: "BRTStudio",
            dependencies: ["BRTCore"],
            path: "BRTStudio",
            exclude: ["Info.plist"],
            resources: [
                .process("Resources")
            ]
        ),

        // Core Library (reusable logic)
        .target(
            name: "BRTCore",
            dependencies: [],
            path: "BRTStudio",
            exclude: ["App", "Views"],
            sources: ["Models", "Services", "Core"]
        ),

        // Tests
        .testTarget(
            name: "BRTStudioTests",
            dependencies: ["BRTStudio", "BRTCore"],
            path: "BRTStudioTests"
        )
    ]
)
