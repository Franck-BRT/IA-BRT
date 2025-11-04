//
//  PrivacyManagerTests.swift
//  BRT Studio Tests - Privacy Manager Tests
//
//  Copyright © 2025 Black Room Technologies. All rights reserved.
//

import XCTest
@testable import BRTStudio

@MainActor
final class PrivacyManagerTests: XCTestCase {

    var privacyManager: PrivacyManager!

    override func setUp() async throws {
        privacyManager = PrivacyManager.shared
    }

    func testPrivacyModeDefaultsToEnabled() async throws {
        // Privacy mode should default to enabled (offline-first)
        XCTAssertTrue(privacyManager.isPrivacyModeEnabled, "Privacy mode should be enabled by default")
    }

    func testTogglePrivacyMode() async throws {
        let initialState = privacyManager.isPrivacyModeEnabled

        privacyManager.togglePrivacyMode()

        XCTAssertNotEqual(privacyManager.isPrivacyModeEnabled, initialState, "Privacy mode should toggle")
    }

    func testNetworkRequestBlockedWhenPrivacyEnabled() async throws {
        // Ensure privacy mode is enabled
        if !privacyManager.isPrivacyModeEnabled {
            privacyManager.togglePrivacyMode()
        }

        let allowed = await privacyManager.requestNetworkAccess(
            for: "Test request",
            destination: "https://example.com"
        )

        XCTAssertFalse(allowed, "Network request should be blocked when privacy mode is enabled")
        XCTAssertGreaterThan(privacyManager.networkRequestsBlocked, 0, "Blocked requests count should increase")
    }

    func testNetworkRequestAllowedWhenPrivacyDisabled() async throws {
        // Disable privacy mode
        if privacyManager.isPrivacyModeEnabled {
            privacyManager.togglePrivacyMode()
        }

        let allowed = await privacyManager.requestNetworkAccess(
            for: "Test request",
            destination: "https://example.com"
        )

        XCTAssertTrue(allowed, "Network request should be allowed when privacy mode is disabled")
    }

    func testModelRequiresNetworkDetection() async throws {
        let ollamaModel = AIModel.ollama("llama3.2")
        let mlxModel = AIModel.mlx("llama-3.2-mlx")
        let openAIModel = AIModel.openAI("gpt-4")

        XCTAssertFalse(privacyManager.modelRequiresNetwork(ollamaModel), "Ollama should not require network")
        XCTAssertFalse(privacyManager.modelRequiresNetwork(mlxModel), "MLX should not require network")
        XCTAssertTrue(privacyManager.modelRequiresNetwork(openAIModel), "OpenAI should require network")
    }

    func testPrivacyStatusReporting() async throws {
        let status = privacyManager.getPrivacyStatus()

        XCTAssertNotNil(status, "Privacy status should be available")
        XCTAssertEqual(status.isPrivacyModeEnabled, privacyManager.isPrivacyModeEnabled)
    }
}
