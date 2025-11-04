//
//  ContentView.swift
//  BRT Studio - Main Content View
//
//  Copyright © 2025 Black Room Technologies. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var privacyManager: PrivacyManager

    var body: some View {
        NavigationSplitView {
            // Sidebar
            SidebarView()
        } detail: {
            // Main content based on current section
            Group {
                switch appState.currentSection {
                case .coPilot:
                    CoPilotView()
                case .chat:
                    ChatView()
                case .agents:
                    AgentsView()
                case .personae:
                    PersonaeView()
                case .prompts:
                    PromptsView()
                case .logger:
                    LoggerView()
                case .settings:
                    SettingsView()
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button {
                    appState.showCommandPalette.toggle()
                } label: {
                    Label("Command Palette", systemImage: "command")
                }
                .keyboardShortcut("k", modifiers: .command)
                .help("Open Command Palette (⌘K)")
            }

            ToolbarItem(placement: .automatic) {
                PrivacyToggle()
            }
        }
        .sheet(isPresented: $appState.showCommandPalette) {
            CommandPaletteView()
        }
    }
}

// MARK: - Sidebar

struct SidebarView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        List(selection: $appState.currentSection) {
            Section("Studio") {
                ForEach(AppSection.allCases) { section in
                    NavigationLink(value: section) {
                        Label(section.rawValue, systemImage: section.icon)
                    }
                }
            }
        }
        .navigationTitle("BRT Studio")
        .frame(minWidth: 200)
    }
}

// MARK: - Privacy Toggle

struct PrivacyToggle: View {
    @EnvironmentObject var privacyManager: PrivacyManager

    var body: some View {
        Toggle(isOn: Binding(
            get: { privacyManager.isPrivacyModeEnabled },
            set: { _ in privacyManager.togglePrivacyMode() }
        )) {
            Label(
                privacyManager.isPrivacyModeEnabled ? "Privacy: ON" : "Privacy: OFF",
                systemImage: privacyManager.isPrivacyModeEnabled ? "lock.fill" : "lock.open"
            )
        }
        .toggleStyle(.switch)
        .help("Privacy Mode \(privacyManager.isPrivacyModeEnabled ? "Enabled" : "Disabled") - All network requests are \(privacyManager.isPrivacyModeEnabled ? "blocked" : "allowed")")
    }
}

// MARK: - Command Palette

struct CommandPaletteView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppState
    @State private var searchText = ""

    struct Command: Identifiable {
        let id = UUID()
        let title: String
        let icon: String
        let action: () -> Void
    }

    var body: some View {
        VStack(spacing: 0) {
            // Search field
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Type a command...", text: $searchText)
                    .textFieldStyle(.plain)
            }
            .padding()
            .background(.ultraThinMaterial)

            Divider()

            // Commands list
            List {
                ForEach(filteredCommands) { command in
                    Button {
                        command.action()
                        dismiss()
                    } label: {
                        Label(command.title, systemImage: command.icon)
                    }
                    .buttonStyle(.plain)
                }
            }
            .listStyle(.plain)
        }
        .frame(width: 600, height: 400)
    }

    var commands: [Command] {
        [
            Command(title: "New Project", icon: "wand.and.stars") {
                appState.startNewCoPilotSession()
            },
            Command(title: "New Chat", icon: "bubble.left.and.bubble.right") {
                appState.startNewChatSession()
            },
            Command(title: "View Logs", icon: "list.bullet.rectangle") {
                appState.navigateTo(.logger)
            },
            Command(title: "Settings", icon: "gearshape") {
                appState.navigateTo(.settings)
            }
        ]
    }

    var filteredCommands: [Command] {
        if searchText.isEmpty {
            return commands
        }
        return commands.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
        .environmentObject(PrivacyManager.shared)
        .environmentObject(AppLogger.shared)
}
