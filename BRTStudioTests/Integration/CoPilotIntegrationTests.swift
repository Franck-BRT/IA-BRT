//
//  CoPilotIntegrationTests.swift
//  BRT Studio Tests - Co-Pilot Integration Tests
//
//  Copyright © 2025 Black Room Technologies. All rights reserved.
//

import XCTest
@testable import BRTStudio

@MainActor
final class CoPilotIntegrationTests: XCTestCase {

    func testCoPilotSessionLifecycle() async throws {
        let engine = CoPilotEngine()

        // Start new session
        engine.startNewSession()

        XCTAssertEqual(engine.session.phase, .introduction, "Should start in introduction phase")
        XCTAssertGreaterThan(engine.session.messages.count, 0, "Should have initial message")

        // Simulate user describing their idea
        await engine.processUserInput("I want to build a macOS productivity app")

        // Session should advance
        XCTAssertNotEqual(engine.session.phase, .introduction, "Should advance past introduction")
        XCTAssertNotNil(engine.session.projectSpec, "Project spec should be initialized")
    }

    func testDialogueManagerQuestionGeneration() {
        let dialogueManager = DialogueManager()

        let intro = dialogueManager.getIntroductionMessage()
        XCTAssertFalse(intro.isEmpty, "Introduction message should not be empty")

        let spec = ProjectSpecification(purpose: "Test app")
        let questions = dialogueManager.getDiscoveryQuestions(for: spec)
        XCTAssertFalse(questions.isEmpty, "Discovery questions should not be empty")
    }

    func testDialogueParsingMultipleInputs() {
        let dialogueManager = DialogueManager()
        var spec = ProjectSpecification()

        // Test platform detection
        spec = dialogueManager.parseDiscoveryResponses("I need it for macOS and iOS", into: spec)
        XCTAssertTrue(spec.targetPlatforms.contains(.macOS), "Should detect macOS")
        XCTAssertTrue(spec.targetPlatforms.contains(.iOS), "Should detect iOS")

        // Test GUI detection
        spec = dialogueManager.parseDiscoveryResponses("It should have a graphical interface", into: spec)
        XCTAssertTrue(spec.requiresGUI, "Should detect GUI requirement")

        // Test offline detection
        spec = dialogueManager.parseDiscoveryResponses("It must work completely offline", into: spec)
        XCTAssertTrue(spec.requiresOffline, "Should detect offline requirement")

        // Test language preference
        spec = dialogueManager.parseDiscoveryResponses("I prefer Swift", into: spec)
        XCTAssertEqual(spec.preferredLanguage, .swift, "Should detect Swift preference")
    }

    func testProjectSpecificationValidation() {
        var spec = ProjectSpecification()

        XCTAssertFalse(spec.isComplete(), "Empty spec should not be complete")

        spec.purpose = "Test app"
        XCTAssertFalse(spec.isComplete(), "Spec without platform should not be complete")

        spec.targetPlatforms = [.macOS]
        XCTAssertTrue(spec.isComplete(), "Spec with purpose and platform should be complete")
    }

    func testProjectSpecificationSummary() {
        let spec = ProjectSpecification(
            purpose: "Productivity app",
            targetPlatforms: [.macOS],
            requiresGUI: true,
            requiresOffline: true,
            needsTesting: true,
            license: .apache2
        )

        let summary = spec.summary()

        XCTAssertTrue(summary.contains("Productivity app"), "Summary should contain purpose")
        XCTAssertTrue(summary.contains("macOS"), "Summary should contain platform")
        XCTAssertTrue(summary.contains("Yes"), "Summary should show boolean values")
    }
}
