//
//  Persona.swift
//  BRT Studio - Persona Model
//
//  Copyright © 2025 Black Room Technologies. All rights reserved.
//

import Foundation

/// AI Persona (character/role definition)
struct Persona: Identifiable, Codable {
    let id: UUID
    var name: String
    var description: String
    var systemPrompt: String
    var avatar: String? // SF Symbol or emoji
    var traits: [Trait]
    var constraints: [String]
    let createdAt: Date
    var updatedAt: Date
    var tags: [String]
    var isDefault: Bool

    init(
        id: UUID = UUID(),
        name: String,
        description: String = "",
        systemPrompt: String = "",
        avatar: String? = nil,
        traits: [Trait] = [],
        constraints: [String] = [],
        tags: [String] = [],
        isDefault: Bool = false
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.systemPrompt = systemPrompt
        self.avatar = avatar
        self.traits = traits
        self.constraints = constraints
        self.createdAt = Date()
        self.updatedAt = Date()
        self.tags = tags
        self.isDefault = isDefault
    }

    struct Trait: Identifiable, Codable {
        let id: UUID
        var name: String
        var value: Double // 0.0 to 1.0
        var description: String

        init(id: UUID = UUID(), name: String, value: Double, description: String = "") {
            self.id = id
            self.name = name
            self.value = max(0.0, min(1.0, value))
            self.description = description
        }
    }

    /// Built-in default personas
    static let `default` = Persona(
        name: "Default Assistant",
        description: "A helpful, balanced AI assistant",
        systemPrompt: "You are a helpful AI assistant.",
        avatar: "person.circle",
        isDefault: true
    )

    static let coPilot = Persona(
        name: "Project Co-Pilot",
        description: "Expert in software architecture and project setup",
        systemPrompt: """
        You are an expert software architect and project co-pilot. Your role is to:
        - Ask clarifying questions to understand project requirements
        - Suggest appropriate technology stacks
        - Design clean, maintainable architectures
        - Generate production-ready project scaffolds
        - Follow security and privacy best practices

        Be thorough, professional, and pragmatic.
        """,
        avatar: "wand.and.stars",
        traits: [
            Trait(name: "Technical", value: 0.9, description: "Deep technical knowledge"),
            Trait(name: "Methodical", value: 0.8, description: "Systematic approach"),
            Trait(name: "Pragmatic", value: 0.9, description: "Focus on practical solutions")
        ],
        isDefault: false
    )

    static let codeReviewer = Persona(
        name: "Code Reviewer",
        description: "Focuses on code quality, security, and best practices",
        systemPrompt: """
        You are an expert code reviewer. Analyze code for:
        - Security vulnerabilities
        - Performance issues
        - Code quality and maintainability
        - Best practices adherence
        - Potential bugs

        Provide constructive, actionable feedback.
        """,
        avatar: "magnifyingglass.circle",
        traits: [
            Trait(name: "Critical", value: 0.8, description: "Attention to detail"),
            Trait(name: "Security-focused", value: 0.9, description: "Security awareness"),
            Trait(name: "Constructive", value: 0.7, description: "Helpful feedback")
        ],
        isDefault: false
    )
}
