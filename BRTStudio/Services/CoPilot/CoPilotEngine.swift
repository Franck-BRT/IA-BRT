//
//  CoPilotEngine.swift
//  BRT Studio - Co-Pilot Engine (Idea → Project)
//
//  Copyright © 2025 Black Room Technologies. All rights reserved.
//

import Foundation

/// Main Co-Pilot engine that orchestrates the "Idea → Project" flow
@MainActor
final class CoPilotEngine: ObservableObject {
    @Published var session: CoPilotSession
    @Published var isProcessing = false
    @Published var currentSuggestion: String?
    @Published var error: Error?

    private let ollamaClient: OllamaClient
    private let dialogueManager: DialogueManager
    private let projectGenerator: ProjectGenerator
    private let logger = AppLogger.shared

    init(ollamaClient: OllamaClient = OllamaClient()) {
        self.ollamaClient = ollamaClient
        self.dialogueManager = DialogueManager()
        self.projectGenerator = ProjectGenerator()
        self.session = CoPilotSession()
    }

    /// Start a new Co-Pilot session
    func startNewSession() {
        session = CoPilotSession()
        session.addMessage(
            role: .assistant,
            content: dialogueManager.getIntroductionMessage()
        )
    }

    /// Process user input
    func processUserInput(_ input: String) async {
        guard !isProcessing else { return }

        isProcessing = true
        defer { isProcessing = false }

        // Add user message
        session.addMessage(role: .user, content: input)

        await logger.log(
            .info,
            "Co-Pilot processing user input",
            metadata: ["phase": session.phase.rawValue, "inputLength": "\(input.count)"]
        )

        do {
            switch session.phase {
            case .introduction:
                await handleIntroduction(input)

            case .discovery:
                await handleDiscovery(input)

            case .refinement:
                await handleRefinement(input)

            case .architecture:
                await handleArchitecture(input)

            case .generation:
                await handleGeneration()

            case .completed, .error:
                break
            }
        } catch {
            self.error = error
            session.phase = .error
            session.addMessage(
                role: .assistant,
                content: "I encountered an error: \(error.localizedDescription). Please try again."
            )
            await logger.log(.error, "Co-Pilot error", metadata: ["error": error.localizedDescription])
        }
    }

    // MARK: - Phase Handlers

    private func handleIntroduction(_ input: String) async {
        // Initialize project spec
        var spec = ProjectSpecification()
        spec.purpose = input

        session.projectSpec = spec
        session.advance(to: .discovery)

        // Ask discovery questions
        let questions = dialogueManager.getDiscoveryQuestions(for: spec)
        session.addMessage(role: .assistant, content: questions)
    }

    private func handleDiscovery(_ input: String) async {
        guard var spec = session.projectSpec else { return }

        // Parse user responses and update spec
        spec = dialogueManager.parseDiscoveryResponses(input, into: spec)
        session.projectSpec = spec

        // Check if we have enough info
        if spec.isComplete() {
            session.advance(to: .refinement)

            // Show summary and ask for confirmation
            let summary = spec.summary()
            let confirmMessage = """
            Great! Here's what I understand:

            \(summary)

            Does this look correct? (yes/no)
            If you'd like to change anything, just let me know!
            """
            session.addMessage(role: .assistant, content: confirmMessage)
        } else {
            // Ask more questions
            let followUp = dialogueManager.getFollowUpQuestions(for: spec)
            session.addMessage(role: .assistant, content: followUp)
        }
    }

    private func handleRefinement(_ input: String) async {
        let normalized = input.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        if normalized.contains("yes") || normalized.contains("correct") || normalized.contains("good") {
            // User confirmed, move to architecture
            session.advance(to: .architecture)

            guard let spec = session.projectSpec else { return }

            // Decide stack
            let stack = TechStack.decide(
                purpose: spec.purpose,
                platform: spec.targetPlatforms.first ?? .macOS,
                requiresGUI: spec.requiresGUI,
                needsOffline: spec.requiresOffline,
                needsPerformance: true
            )

            // Generate architecture proposal
            let architecture = await proposeArchitecture(for: spec, with: stack)

            let message = """
            Perfect! Based on your requirements, I recommend:

            **Technology Stack:**
            - Type: \(stack.type.rawValue)
            - Language: \(stack.language.rawValue)
            - Framework: \(stack.framework)
            - Build System: \(stack.buildSystem.rawValue)

            **Architecture:**
            - Pattern: \(architecture.pattern.rawValue)
            - Testing: \(architecture.testing.rawValue)

            **Modules:**
            \(architecture.modules.map { "- \($0.name): \($0.purpose)" }.joined(separator: "\n"))

            Shall I proceed to generate this project? (yes/no)
            """

            session.addMessage(role: .assistant, content: message)

            // Store in session
            var updatedSpec = spec
            session.projectSpec = updatedSpec
        } else {
            // User wants to make changes
            session.advance(to: .discovery)
            session.addMessage(
                role: .assistant,
                content: "No problem! What would you like to change?"
            )
        }
    }

    private func handleArchitecture(_ input: String) async {
        let normalized = input.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        if normalized.contains("yes") || normalized.contains("proceed") || normalized.contains("generate") {
            session.advance(to: .generation)

            session.addMessage(
                role: .assistant,
                content: "Excellent! I'll now generate your project. This will take a few moments..."
            )

            await handleGeneration()
        } else {
            session.addMessage(
                role: .assistant,
                content: "What aspects of the architecture would you like me to adjust?"
            )
        }
    }

    private func handleGeneration() async {
        guard let spec = session.projectSpec else { return }

        await logger.log(.info, "Starting project generation", metadata: ["purpose": spec.purpose])

        let generationStartTime = Date()

        do {
            // Decide stack
            let stack = TechStack.decide(
                purpose: spec.purpose,
                platform: spec.targetPlatforms.first ?? .macOS,
                requiresGUI: spec.requiresGUI,
                needsOffline: spec.requiresOffline,
                needsPerformance: true
            )

            // Generate architecture
            let architecture = await proposeArchitecture(for: spec, with: stack)

            // Generate project
            let project = try await projectGenerator.generateProject(
                spec: spec,
                stack: stack,
                architecture: architecture
            )

            session.generatedProject = project
            session.advance(to: .completed)

            let duration = Date().timeIntervalSince(generationStartTime)

            let successMessage = """
            ✅ Project generated successfully!

            **Location:** \(project.outputPath.path)
            **Generation time:** \(String(format: "%.2f", duration))s

            Your project includes:
            - Complete source code structure
            - Build scripts and configuration
            - README with instructions
            - Initial tests
            - Git repository initialization

            You can now:
            1. Open the project in Xcode or your preferred editor
            2. Build and run it
            3. Ask me to make modifications

            Would you like me to explain any part of the generated code?
            """

            session.addMessage(role: .assistant, content: successMessage)

            await logger.log(
                .info,
                "Project generated successfully",
                metadata: [
                    "duration": String(format: "%.2f", duration),
                    "path": project.outputPath.path,
                    "stack": stack.type.rawValue
                ]
            )

        } catch {
            session.phase = .error
            self.error = error

            session.addMessage(
                role: .assistant,
                content: "I encountered an error generating the project: \(error.localizedDescription)"
            )

            await logger.log(.error, "Project generation failed", metadata: ["error": error.localizedDescription])
        }
    }

    // MARK: - Architecture Generation

    private func proposeArchitecture(
        for spec: ProjectSpecification,
        with stack: TechStack
    ) async -> ProjectArchitecture {
        // For MVP, use simple rule-based architecture
        // In future, could use LLM for more sophisticated proposals

        let pattern: ProjectArchitecture.ArchitecturePattern = stack.type == .macOSNative ? .mvvm : .modular

        let modules: [ProjectArchitecture.Module] = [
            .init(name: "App", purpose: "Application entry point and lifecycle"),
            .init(name: "Views", purpose: "User interface components"),
            .init(name: "Models", purpose: "Data models and business logic"),
            .init(name: "Services", purpose: "External integrations and APIs"),
            .init(name: "Core", purpose: "Utilities and helpers")
        ]

        let testing: ProjectArchitecture.TestingStrategy = spec.needsTesting ? .unit : .minimal

        return ProjectArchitecture(
            pattern: pattern,
            modules: modules,
            features: [],
            testing: testing
        )
    }
}
