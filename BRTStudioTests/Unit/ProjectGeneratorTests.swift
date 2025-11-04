//
//  ProjectGeneratorTests.swift
//  BRT Studio Tests - Project Generator Tests
//
//  Copyright © 2025 Black Room Technologies. All rights reserved.
//

import XCTest
@testable import BRTStudio

final class ProjectGeneratorTests: XCTestCase {

    var generator: ProjectGenerator!
    var tempDirectory: URL!

    override func setUp() async throws {
        generator = ProjectGenerator()

        // Create temp directory for testing
        tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("BRTStudioTests-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
    }

    override func tearDown() async throws {
        // Clean up temp directory
        try? FileManager.default.removeItem(at: tempDirectory)
    }

    func testGenerateSwiftUIProject() async throws {
        let spec = ProjectSpecification(
            purpose: "Test macOS app",
            targetPlatforms: [.macOS],
            requiresGUI: true,
            requiresOffline: true,
            needsTesting: true
        )

        let stack = TechStack.swiftUIMacOS

        let architecture = ProjectArchitecture(
            pattern: .mvvm,
            modules: [
                .init(name: "App", purpose: "Main app"),
                .init(name: "Views", purpose: "UI components")
            ],
            features: [],
            testing: .unit
        )

        let project = try await generator.generateProject(
            spec: spec,
            stack: stack,
            architecture: architecture
        )

        XCTAssertNotNil(project, "Project should be generated")
        XCTAssertEqual(project.stack.type, .macOSNative)
        XCTAssertTrue(FileManager.default.fileExists(atPath: project.outputPath.path))

        // Check for essential files
        let packageSwift = project.outputPath.appendingPathComponent("Package.swift")
        XCTAssertTrue(FileManager.default.fileExists(atPath: packageSwift.path), "Package.swift should exist")

        let readme = project.outputPath.appendingPathComponent("README.md")
        XCTAssertTrue(FileManager.default.fileExists(atPath: readme.path), "README.md should exist")

        let license = project.outputPath.appendingPathComponent("LICENSE")
        XCTAssertTrue(FileManager.default.fileExists(atPath: license.path), "LICENSE should exist")

        let gitignore = project.outputPath.appendingPathComponent(".gitignore")
        XCTAssertTrue(FileManager.default.fileExists(atPath: gitignore.path), ".gitignore should exist")
    }

    func testStackDecisionLogic() {
        // Test macOS native
        let macOSStack = TechStack.decide(
            purpose: "macOS productivity app",
            platform: .macOS,
            requiresGUI: true,
            needsOffline: true,
            needsPerformance: true
        )

        XCTAssertEqual(macOSStack.type, .macOSNative)
        XCTAssertEqual(macOSStack.language, .swift)

        // Test cross-platform
        let crossPlatformStack = TechStack.decide(
            purpose: "multi-platform tool",
            platform: .multiOS,
            requiresGUI: true,
            needsOffline: true,
            needsPerformance: true
        )

        XCTAssertEqual(crossPlatformStack.type, .crossPlatformGUI)

        // Test Python script
        let scriptStack = TechStack.decide(
            purpose: "automation script",
            platform: .multiOS,
            requiresGUI: false,
            needsOffline: true,
            needsPerformance: false
        )

        XCTAssertEqual(scriptStack.language, .python)
    }

    func testProjectMetadataGeneration() async throws {
        let spec = ProjectSpecification(
            purpose: "Test app",
            targetPlatforms: [.macOS],
            license: .mit
        )

        let stack = TechStack.swiftUIMacOS
        let architecture = ProjectArchitecture(
            pattern: .mvvm,
            modules: [],
            features: [],
            testing: .minimal
        )

        let project = try await generator.generateProject(
            spec: spec,
            stack: stack,
            architecture: architecture
        )

        XCTAssertEqual(project.metadata.license, .mit)
        XCTAssertEqual(project.metadata.version, "0.1.0")
    }

    func testProjectGenerationPerformance() async throws {
        measure {
            let spec = ProjectSpecification(
                purpose: "Performance test app",
                targetPlatforms: [.macOS]
            )

            let stack = TechStack.swiftUIMacOS
            let architecture = ProjectArchitecture(
                pattern: .simple,
                modules: [],
                features: [],
                testing: .minimal
            )

            // Should complete within performance target (< 10s)
            let startTime = Date()

            Task {
                _ = try await self.generator.generateProject(
                    spec: spec,
                    stack: stack,
                    architecture: architecture
                )
            }

            let duration = Date().timeIntervalSince(startTime)
            XCTAssertLessThan(duration, AppConstants.projectGenerationTarget, "Project generation should complete within target time")
        }
    }
}
