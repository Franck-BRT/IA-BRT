//
//  AppState.swift
//  BRT Studio - Application State Management
//
//  Copyright © 2025 Black Room Technologies. All rights reserved.
//

import SwiftUI
import Combine

/// Global application state
@MainActor
final class AppState: ObservableObject {

    // MARK: - Navigation
    @Published var currentSection: AppSection = .coPilot
    @Published var showCommandPalette = false
    @Published var selectedProject: GeneratedProject?

    // MARK: - CoPilot State
    @Published var coPilotSession: CoPilotSession?
    @Published var isGeneratingProject = false

    // MARK: - Chat State
    @Published var chatSessions: [ChatSession] = []
    @Published var currentChatSession: ChatSession?

    // MARK: - Workflows
    @Published var workflows: [Workflow] = []
    @Published var runningWorkflows: Set<UUID> = []

    // MARK: - Personae & Prompts
    @Published var personae: [Persona] = []
    @Published var promptTemplates: [PromptTemplate] = []

    // MARK: - Methods
    func navigateTo(_ section: AppSection) {
        withAnimation(.easeInOut(duration: 0.2)) {
            currentSection = section
        }
    }

    func startNewCoPilotSession() {
        coPilotSession = CoPilotSession()
        navigateTo(.coPilot)
    }

    func startNewChatSession(model: AIModel = .ollama("llama3.2")) {
        let session = ChatSession(model: model)
        chatSessions.insert(session, at: 0)
        currentChatSession = session
        navigateTo(.chat)
    }
}

// MARK: - App Sections
enum AppSection: String, CaseIterable, Identifiable {
    case coPilot = "Co-Pilot"
    case chat = "Chat"
    case agents = "Agents"
    case personae = "Personae"
    case prompts = "Prompts"
    case logger = "Logger"
    case settings = "Settings"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .coPilot: return "wand.and.stars"
        case .chat: return "bubble.left.and.bubble.right"
        case .agents: return "cpu.fill"
        case .personae: return "person.2.fill"
        case .prompts: return "doc.text.fill"
        case .logger: return "list.bullet.rectangle"
        case .settings: return "gearshape.fill"
        }
    }
}
