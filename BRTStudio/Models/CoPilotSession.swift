//
//  CoPilotSession.swift
//  BRT Studio - Co-Pilot Session Model
//
//  Copyright © 2025 Black Room Technologies. All rights reserved.
//

import Foundation

/// Represents a Co-Pilot "Idea → Project" session
struct CoPilotSession: Identifiable, Codable {
    let id: UUID
    var phase: Phase
    var messages: [Message]
    var projectSpec: ProjectSpecification?
    var generatedProject: GeneratedProject?
    let createdAt: Date
    var updatedAt: Date

    init(id: UUID = UUID()) {
        self.id = id
        self.phase = .introduction
        self.messages = []
        self.projectSpec = nil
        self.generatedProject = nil
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    enum Phase: String, Codable {
        case introduction = "Introduction"
        case discovery = "Discovery"
        case refinement = "Refinement"
        case architecture = "Architecture Design"
        case generation = "Code Generation"
        case completed = "Completed"
        case error = "Error"
    }

    struct Message: Identifiable, Codable {
        let id: UUID
        let role: Role
        let content: String
        let timestamp: Date
        var metadata: [String: String]?

        init(
            id: UUID = UUID(),
            role: Role,
            content: String,
            timestamp: Date = Date(),
            metadata: [String: String]? = nil
        ) {
            self.id = id
            self.role = role
            self.content = content
            self.timestamp = timestamp
            self.metadata = metadata
        }

        enum Role: String, Codable {
            case user = "user"
            case assistant = "assistant"
            case system = "system"
        }
    }

    mutating func addMessage(role: Message.Role, content: String) {
        let message = Message(role: role, content: content)
        messages.append(message)
        updatedAt = Date()
    }

    mutating func advance(to newPhase: Phase) {
        phase = newPhase
        updatedAt = Date()
    }
}

/// Complete project specification gathered from user
struct ProjectSpecification: Codable {
    var purpose: String = ""
    var targetPlatforms: [TechStack.Platform] = []
    var requiresGUI: Bool = true
    var requiresOffline: Bool = true
    var requiresCLI: Bool = false
    var preferredLanguage: TechStack.ProgrammingLanguage?
    var needsDatabase: Bool = false
    var needsAPI: Bool = false
    var needsAuthentication: Bool = false
    var needsTesting: Bool = true
    var needsCI: Bool = false
    var needsPluginSystem: Bool = false
    var license: ProjectMetadata.License = .apache2
    var additionalRequirements: [String] = []
    var constraints: [String] = []

    /// Validate that spec is complete enough to proceed
    func isComplete() -> Bool {
        return !purpose.isEmpty && !targetPlatforms.isEmpty
    }

    /// Generate a summary for confirmation
    func summary() -> String {
        var lines: [String] = []
        lines.append("📋 Project Specification:")
        lines.append("  Purpose: \(purpose)")
        lines.append("  Platform(s): \(targetPlatforms.map { $0.rawValue }.joined(separator: ", "))")
        lines.append("  GUI: \(requiresGUI ? "Yes" : "No")")
        lines.append("  Offline: \(requiresOffline ? "Yes" : "No")")
        if let lang = preferredLanguage {
            lines.append("  Language: \(lang.rawValue)")
        }
        lines.append("  Testing: \(needsTesting ? "Yes" : "No")")
        lines.append("  License: \(license.rawValue)")

        if !additionalRequirements.isEmpty {
            lines.append("  Additional: \(additionalRequirements.joined(separator: ", "))")
        }

        return lines.joined(separator: "\n")
    }
}
