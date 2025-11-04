//
//  BRTStudioApp.swift
//  BRT Studio - Black Room Technologies AI Studio
//
//  Copyright © 2025 Black Room Technologies. All rights reserved.
//  Licensed under the Apache License, Version 2.0
//

import SwiftUI

@main
struct BRTStudioApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var privacyManager = PrivacyManager.shared
    @StateObject private var logger = AppLogger.shared

    init() {
        setupApp()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(privacyManager)
                .environmentObject(logger)
                .frame(minWidth: 1200, minHeight: 800)
                .onAppear {
                    logger.log(.info, "BRT Studio launched", metadata: ["version": AppConstants.version])
                }
        }
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("New Project") {
                    appState.navigateTo(.coPilot)
                }
                .keyboardShortcut("n", modifiers: .command)
            }

            CommandGroup(after: .toolbar) {
                Button("Command Palette") {
                    appState.showCommandPalette.toggle()
                }
                .keyboardShortcut("k", modifiers: .command)

                Divider()

                Toggle("Privacy Mode", isOn: $privacyManager.isPrivacyModeEnabled)
                    .keyboardShortcut("p", modifiers: [.command, .shift])
            }
        }

        Settings {
            SettingsView()
                .environmentObject(appState)
                .environmentObject(privacyManager)
        }
    }

    private func setupApp() {
        // Configure app-wide settings
        #if DEBUG
        print("🚀 BRT Studio starting in DEBUG mode")
        #endif

        // Load user preferences
        UserDefaults.standard.register(defaults: AppConstants.defaultPreferences)
    }
}
