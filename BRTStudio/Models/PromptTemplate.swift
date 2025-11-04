//
//  PromptTemplate.swift
//  BRT Studio - Prompt Template Model
//
//  Copyright © 2025 Black Room Technologies. All rights reserved.
//

import Foundation

/// Reusable prompt template with versioning
struct PromptTemplate: Identifiable, Codable {
    let id: UUID
    var name: String
    var description: String
    var template: String
    var variables: [Variable]
    var versions: [Version]
    let createdAt: Date
    var updatedAt: Date
    var tags: [String]
    var category: Category

    init(
        id: UUID = UUID(),
        name: String,
        description: String = "",
        template: String,
        variables: [Variable] = [],
        tags: [String] = [],
        category: Category = .general
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.template = template
        self.variables = variables
        self.versions = [Version(template: template, notes: "Initial version")]
        self.createdAt = Date()
        self.updatedAt = Date()
        self.tags = tags
        self.category = category
    }

    enum Category: String, Codable, CaseIterable {
        case general = "General"
        case code = "Code"
        case analysis = "Analysis"
        case creative = "Creative"
        case technical = "Technical"
    }

    struct Variable: Identifiable, Codable {
        let id: UUID
        var name: String
        var description: String
        var defaultValue: String?
        var required: Bool

        init(
            id: UUID = UUID(),
            name: String,
            description: String = "",
            defaultValue: String? = nil,
            required: Bool = true
        ) {
            self.id = id
            self.name = name
            self.description = description
            self.defaultValue = defaultValue
            self.required = required
        }
    }

    struct Version: Identifiable, Codable {
        let id: UUID
        let template: String
        let createdAt: Date
        var notes: String
        var performanceMetrics: PerformanceMetrics?

        init(
            id: UUID = UUID(),
            template: String,
            createdAt: Date = Date(),
            notes: String = "",
            performanceMetrics: PerformanceMetrics? = nil
        ) {
            self.id = id
            self.template = template
            self.createdAt = createdAt
            self.notes = notes
            self.performanceMetrics = performanceMetrics
        }

        struct PerformanceMetrics: Codable {
            var averageLatency: Double // ms
            var successRate: Double // 0.0 to 1.0
            var totalUses: Int
        }
    }

    /// Render template with variable substitution
    func render(with values: [String: String]) throws -> String {
        var result = template

        // Check required variables
        for variable in variables where variable.required {
            if values[variable.name] == nil && variable.defaultValue == nil {
                throw PromptError.missingRequiredVariable(variable.name)
            }
        }

        // Substitute variables
        for variable in variables {
            let placeholder = "{{\(variable.name)}}"
            let value = values[variable.name] ?? variable.defaultValue ?? ""
            result = result.replacingOccurrences(of: placeholder, with: value)
        }

        return result
    }

    mutating func addVersion(template: String, notes: String) {
        let version = Version(template: template, notes: notes)
        versions.append(version)
        self.template = template
        updatedAt = Date()
    }

    enum PromptError: LocalizedError {
        case missingRequiredVariable(String)

        var errorDescription: String? {
            switch self {
            case .missingRequiredVariable(let name):
                return "Missing required variable: \(name)"
            }
        }
    }
}
