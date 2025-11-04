//
//  SettingsView.swift
//  BRT Studio - Settings View
//
//  Copyright © 2025 Black Room Technologies. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var privacyManager: PrivacyManager
    @AppStorage("ollamaURL") private var ollamaURL = AppConstants.ollamaDefaultURL
    @AppStorage("defaultModel") private var defaultModel = AppConstants.ollamaDefaultModel
    @AppStorage("theme") private var theme = "liquid-glass"
    @AppStorage("logLevel") private var logLevel = "info"
    @State private var ollamaAvailable = false
    @State private var checkingOllama = false

    var body: some View {
        Form {
            // Privacy Section
            Section {
                Toggle("Privacy Mode", isOn: Binding(
                    get: { privacyManager.isPrivacyModeEnabled },
                    set: { _ in privacyManager.togglePrivacyMode() }
                ))

                VStack(alignment: .leading, spacing: 8) {
                    Text("When enabled, all network requests are blocked")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if privacyManager.networkRequestsBlocked > 0 {
                        Text("Blocked \(privacyManager.networkRequestsBlocked) network request(s)")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                }
            } header: {
                Label("Privacy", systemImage: "lock.shield")
            }

            // Ollama Section
            Section {
                HStack {
                    TextField("Ollama URL", text: $ollamaURL)
                        .textFieldStyle(.roundedBorder)

                    Button {
                        checkOllamaConnection()
                    } label: {
                        if checkingOllama {
                            ProgressView()
                                .scaleEffect(0.7)
                        } else {
                            Label("Test", systemImage: "network")
                        }
                    }
                    .disabled(checkingOllama)
                }

                if ollamaAvailable {
                    Label("Connected", systemImage: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                }

                TextField("Default Model", text: $defaultModel)
                    .textFieldStyle(.roundedBorder)

                Button("Open Ollama in Browser") {
                    if let url = URL(string: ollamaURL) {
                        NSWorkspace.shared.open(url)
                    }
                }
            } header: {
                Label("Ollama Configuration", systemImage: "cpu")
            } footer: {
                Text("Configure your local Ollama instance. Default: \(AppConstants.ollamaDefaultURL)")
            }

            // Appearance Section
            Section {
                Picker("Theme", selection: $theme) {
                    Text("Liquid Glass").tag("liquid-glass")
                    Text("Classic").tag("classic")
                    Text("High Contrast").tag("high-contrast")
                }
                .pickerStyle(.segmented)
            } header: {
                Label("Appearance", systemImage: "paintbrush")
            }

            // Logging Section
            Section {
                Picker("Log Level", selection: $logLevel) {
                    Text("Debug").tag("debug")
                    Text("Info").tag("info")
                    Text("Warning").tag("warning")
                    Text("Error").tag("error")
                }

                Button("View Logs") {
                    // Navigate to logger
                }

                Button("Export Logs") {
                    exportLogs()
                }
            } header: {
                Label("Logging", systemImage: "doc.text")
            }

            // About Section
            Section {
                LabeledContent("Version", value: AppConstants.version)
                LabeledContent("Build", value: AppConstants.buildNumber)

                Link("GitHub Repository", destination: URL(string: "https://github.com/blackroomtech/brtstudio")!)

                Button("Check for Updates") {
                    // TODO: Implement Sparkle updates
                    print("Check for updates")
                }
            } header: {
                Label("About", systemImage: "info.circle")
            }
        }
        .formStyle(.grouped)
        .frame(minWidth: 600, minHeight: 500)
        .navigationTitle("Settings")
        .onAppear {
            checkOllamaConnection()
        }
    }

    // MARK: - Actions

    private func checkOllamaConnection() {
        checkingOllama = true

        Task {
            let client = OllamaClient(baseURL: ollamaURL)
            let available = await client.checkAvailability()

            await MainActor.run {
                ollamaAvailable = available
                checkingOllama = false
            }
        }
    }

    private func exportLogs() {
        Task {
            if let logsURL = await AppLogger.shared.exportLogs() {
                let panel = NSSavePanel()
                panel.nameFieldStringValue = logsURL.lastPathComponent
                panel.allowedContentTypes = [.json]

                if panel.runModal() == .OK, let saveURL = panel.url {
                    try? FileManager.default.copyItem(at: logsURL, to: saveURL)
                }
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(PrivacyManager.shared)
}
