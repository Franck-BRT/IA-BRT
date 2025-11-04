//
//  DialogueManager.swift
//  BRT Studio - Co-Pilot Dialogue Management
//
//  Copyright © 2025 Black Room Technologies. All rights reserved.
//

import Foundation

/// Manages the conversational flow of the Co-Pilot
struct DialogueManager {

    /// Get introduction message
    func getIntroductionMessage() -> String {
        return """
        👋 Hello! I'm your Project Co-Pilot.

        I'll help you turn your idea into a fully-functional project scaffold with:
        - Appropriate technology stack selection
        - Clean architecture design
        - Complete development environment setup
        - Initial code and tests
        - Build and deployment scripts

        **Tell me about your project idea.** What would you like to build?
        """
    }

    /// Get discovery questions
    func getDiscoveryQuestions(for spec: ProjectSpecification) -> String {
        return """
        Great! To design the best solution for you, I need to understand your requirements better.

        **Please answer these questions:**

        1. **Platform(s):** Where should this run? (macOS, iOS, multi-platform, web)
        2. **Interface:** Does it need a graphical interface (GUI) or is it a command-line tool (CLI)?
        3. **Network:** Should it work completely offline, or can it use network resources?
        4. **Language:** Do you have a preferred programming language? (Swift, Rust, Python, TypeScript, or let me decide)
        5. **Database:** Will you need to store data locally?
        6. **Testing:** Should I include a comprehensive test suite?
        7. **License:** What license should the project use? (Apache 2.0, MIT, GPL-3.0, BSD, Proprietary)

        You can answer in natural language - just tell me what you need!
        """
    }

    /// Parse discovery responses
    func parseDiscoveryResponses(
        _ input: String,
        into spec: ProjectSpecification
    ) -> ProjectSpecification {
        var updated = spec
        let lowercased = input.lowercased()

        // Platform detection
        if lowercased.contains("macos") || lowercased.contains("mac") {
            if !updated.targetPlatforms.contains(.macOS) {
                updated.targetPlatforms.append(.macOS)
            }
        }
        if lowercased.contains("ios") || lowercased.contains("iphone") {
            if !updated.targetPlatforms.contains(.iOS) {
                updated.targetPlatforms.append(.iOS)
            }
        }
        if lowercased.contains("multi") || lowercased.contains("cross-platform") {
            if !updated.targetPlatforms.contains(.multiOS) {
                updated.targetPlatforms.append(.multiOS)
            }
        }
        if lowercased.contains("web") {
            if !updated.targetPlatforms.contains(.web) {
                updated.targetPlatforms.append(.web)
            }
        }

        // GUI vs CLI
        if lowercased.contains("cli") || lowercased.contains("command-line") || lowercased.contains("terminal") {
            updated.requiresGUI = false
            updated.requiresCLI = true
        }
        if lowercased.contains("gui") || lowercased.contains("interface") || lowercased.contains("window") {
            updated.requiresGUI = true
        }

        // Offline/Online
        if lowercased.contains("offline") || lowercased.contains("no network") || lowercased.contains("local only") {
            updated.requiresOffline = true
        }
        if lowercased.contains("online") || lowercased.contains("network") || lowercased.contains("api") {
            updated.requiresOffline = false
            updated.needsAPI = true
        }

        // Language preference
        if lowercased.contains("swift") {
            updated.preferredLanguage = .swift
        } else if lowercased.contains("rust") {
            updated.preferredLanguage = .rust
        } else if lowercased.contains("python") {
            updated.preferredLanguage = .python
        } else if lowercased.contains("typescript") || lowercased.contains("ts") {
            updated.preferredLanguage = .typescript
        } else if lowercased.contains("javascript") || lowercased.contains("js") {
            updated.preferredLanguage = .javascript
        }

        // Database
        if lowercased.contains("database") || lowercased.contains("storage") || lowercased.contains("persist") {
            updated.needsDatabase = true
        }

        // Testing
        if lowercased.contains("no test") || lowercased.contains("skip test") {
            updated.needsTesting = false
        } else if lowercased.contains("test") {
            updated.needsTesting = true
        }

        // Authentication
        if lowercased.contains("auth") || lowercased.contains("login") || lowercased.contains("user") {
            updated.needsAuthentication = true
        }

        // CI/CD
        if lowercased.contains("ci") || lowercased.contains("github actions") || lowercased.contains("automation") {
            updated.needsCI = true
        }

        // Plugins
        if lowercased.contains("plugin") || lowercased.contains("extension") || lowercased.contains("modular") {
            updated.needsPluginSystem = true
        }

        // License
        if lowercased.contains("apache") {
            updated.license = .apache2
        } else if lowercased.contains("mit") {
            updated.license = .mit
        } else if lowercased.contains("gpl") {
            updated.license = .gpl3
        } else if lowercased.contains("bsd") {
            updated.license = .bsd3
        } else if lowercased.contains("proprietary") || lowercased.contains("closed") {
            updated.license = .proprietary
        }

        return updated
    }

    /// Get follow-up questions for incomplete specs
    func getFollowUpQuestions(for spec: ProjectSpecification) -> String {
        var questions: [String] = []

        if spec.targetPlatforms.isEmpty {
            questions.append("- Which platform(s) should this target?")
        }

        if spec.preferredLanguage == nil && !spec.purpose.isEmpty {
            questions.append("- Do you have a programming language preference, or should I choose the best fit?")
        }

        if questions.isEmpty {
            return "Could you provide a bit more detail about your project requirements?"
        }

        return """
        I need a few more details:

        \(questions.joined(separator: "\n"))
        """
    }

    /// Generate suggestions based on context
    func generateSuggestions(for spec: ProjectSpecification) -> [String] {
        var suggestions: [String] = []

        // Suggest appropriate platforms
        if spec.targetPlatforms.isEmpty {
            if spec.purpose.lowercased().contains("mac") {
                suggestions.append("Consider targeting macOS for native performance")
            }
            if spec.requiresOffline {
                suggestions.append("Offline-first suggests a native app (macOS/iOS)")
            }
        }

        // Suggest stack based on requirements
        if spec.preferredLanguage == nil {
            if spec.requiresGUI && spec.targetPlatforms.contains(.macOS) {
                suggestions.append("Swift + SwiftUI would be ideal for macOS GUI")
            }
            if !spec.requiresGUI && spec.targetPlatforms.contains(.multiOS) {
                suggestions.append("Rust would provide excellent cross-platform CLI performance")
            }
            if spec.purpose.lowercased().contains("script") {
                suggestions.append("Python might be perfect for scripting tasks")
            }
        }

        // Suggest testing if complex
        if !spec.needsTesting && (spec.needsDatabase || spec.needsAPI) {
            suggestions.append("Given the complexity, I'd recommend including tests")
        }

        return suggestions
    }
}
