//
//  AppConstants.swift
//  BRT Studio - Application Constants
//
//  Copyright © 2025 Black Room Technologies. All rights reserved.
//

import Foundation

enum AppConstants {
    static let version = "0.1.0-mvp"
    static let buildNumber = "1"
    static let bundleIdentifier = "com.blackroomtech.brtstudio"

    // Performance targets
    static let launchTimeTarget: TimeInterval = 2.0 // seconds
    static let uiResponseTarget: TimeInterval = 0.1 // 100ms
    static let projectGenerationTarget: TimeInterval = 10.0 // seconds

    // Storage paths (relative to Application Support)
    static let projectsDirectory = "Projects"
    static let templatesDirectory = "Templates"
    static let logsDirectory = "Logs"
    static let modelsDirectory = "Models"
    static let workflowsDirectory = "Workflows"

    // Ollama defaults
    static let ollamaDefaultURL = "http://localhost:11434"
    static let ollamaDefaultModel = "llama3.2"

    // Security
    static let keychainService = "com.blackroomtech.brtstudio.keychain"
    static let encryptionAlgorithm = "AES-GCM"

    // Default preferences
    static let defaultPreferences: [String: Any] = [
        "privacyMode": true,
        "ollamaURL": ollamaDefaultURL,
        "defaultModel": ollamaDefaultModel,
        "enableTelemetry": false,
        "logLevel": "info",
        "theme": "liquid-glass",
        "autoSaveInterval": 30.0
    ]
}
