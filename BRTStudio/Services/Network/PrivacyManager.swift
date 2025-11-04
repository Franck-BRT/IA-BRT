//
//  PrivacyManager.swift
//  BRT Studio - Privacy & Network Control
//
//  Copyright © 2025 Black Room Technologies. All rights reserved.
//

import Foundation
import Combine

/// Manages privacy settings and network access control
@MainActor
final class PrivacyManager: ObservableObject {
    static let shared = PrivacyManager()

    @Published private(set) var isPrivacyModeEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isPrivacyModeEnabled, forKey: "privacyMode")
            logPrivacyChange()
        }
    }

    @Published private(set) var networkRequestsBlocked: Int = 0
    @Published private(set) var lastNetworkRequest: NetworkRequest?

    private let logger = AppLogger.shared

    private init() {
        // Load privacy mode from UserDefaults (default: true = offline)
        self.isPrivacyModeEnabled = UserDefaults.standard.bool(forKey: "privacyMode")
        if !UserDefaults.standard.bool(forKey: "privacyModeInitialized") {
            self.isPrivacyModeEnabled = true // Default to privacy mode ON
            UserDefaults.standard.set(true, forKey: "privacyModeInitialized")
        }
    }

    /// Toggle privacy mode
    func togglePrivacyMode() {
        isPrivacyModeEnabled.toggle()
    }

    /// Request network access - returns true if allowed
    func requestNetworkAccess(
        for purpose: String,
        destination: String,
        requiresExplicitConsent: Bool = false
    ) async -> Bool {
        let request = NetworkRequest(
            purpose: purpose,
            destination: destination,
            timestamp: Date()
        )

        lastNetworkRequest = request

        // Log the request
        await logger.log(
            .info,
            "Network access requested",
            metadata: [
                "purpose": purpose,
                "destination": destination,
                "privacyMode": "\(isPrivacyModeEnabled)"
            ]
        )

        // Block if privacy mode is enabled
        if isPrivacyModeEnabled {
            networkRequestsBlocked += 1
            await logger.log(
                .warning,
                "Network request blocked by Privacy Mode",
                metadata: [
                    "purpose": purpose,
                    "destination": destination
                ]
            )
            return false
        }

        // Allow if privacy mode is disabled
        return true
    }

    /// Check if a specific model requires network
    func modelRequiresNetwork(_ model: AIModel) -> Bool {
        return model.requiresNetwork
    }

    private func logPrivacyChange() {
        Task {
            await logger.log(
                .info,
                "Privacy mode changed",
                metadata: [
                    "enabled": "\(isPrivacyModeEnabled)",
                    "timestamp": ISO8601DateFormatter().string(from: Date())
                ]
            )
        }
    }

    /// Get privacy status summary
    func getPrivacyStatus() -> PrivacyStatus {
        return PrivacyStatus(
            isPrivacyModeEnabled: isPrivacyModeEnabled,
            networkRequestsBlocked: networkRequestsBlocked,
            lastNetworkRequest: lastNetworkRequest
        )
    }

    struct NetworkRequest: Identifiable {
        let id = UUID()
        let purpose: String
        let destination: String
        let timestamp: Date
    }

    struct PrivacyStatus {
        let isPrivacyModeEnabled: Bool
        let networkRequestsBlocked: Int
        let lastNetworkRequest: NetworkRequest?
    }
}
