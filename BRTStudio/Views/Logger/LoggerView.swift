//
//  LoggerView.swift
//  BRT Studio - Log Viewer
//
//  Copyright © 2025 Black Room Technologies. All rights reserved.
//

import SwiftUI

struct LoggerView: View {
    @StateObject private var loggerObservable = AppLoggerObservable()
    @State private var selectedLevel: LogLevel?
    @State private var searchText = ""
    @State private var autoRefresh = true

    private let timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 0) {
            // Toolbar
            HStack {
                // Search
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    TextField("Search logs...", text: $searchText)
                        .textFieldStyle(.plain)
                }
                .padding(8)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 6))
                .frame(maxWidth: 300)

                Spacer()

                // Level filter
                Picker("Level", selection: $selectedLevel) {
                    Text("All").tag(nil as LogLevel?)
                    Text("Debug").tag(LogLevel.debug as LogLevel?)
                    Text("Info").tag(LogLevel.info as LogLevel?)
                    Text("Warning").tag(LogLevel.warning as LogLevel?)
                    Text("Error").tag(LogLevel.error as LogLevel?)
                    Text("Critical").tag(LogLevel.critical as LogLevel?)
                }
                .pickerStyle(.segmented)
                .frame(width: 400)

                Toggle("Auto-refresh", isOn: $autoRefresh)

                Button {
                    loggerObservable.refreshLogs()
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }

                Button {
                    exportLogs()
                } label: {
                    Label("Export", systemImage: "square.and.arrow.up")
                }
            }
            .padding()
            .background(.ultraThinMaterial)

            Divider()

            // Logs table
            if filteredLogs.isEmpty {
                emptyState
            } else {
                Table(filteredLogs) {
                    TableColumn("Time") { entry in
                        Text(entry.timestamp, style: .time)
                            .font(.system(.body, design: .monospaced))
                    }
                    .width(min: 80, max: 100)

                    TableColumn("Level") { entry in
                        LevelBadge(level: entry.level)
                    }
                    .width(min: 80, max: 100)

                    TableColumn("Message") { entry in
                        Text(entry.message)
                            .textSelection(.enabled)
                    }
                    .width(min: 300)

                    TableColumn("File") { entry in
                        Text("\(entry.file):\(entry.line)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .width(min: 150, max: 200)

                    TableColumn("Metadata") { entry in
                        if !entry.metadata.isEmpty {
                            MetadataView(metadata: entry.metadata)
                        }
                    }
                    .width(min: 200)
                }
            }
        }
        .navigationTitle("Logger")
        .onAppear {
            loggerObservable.refreshLogs()
        }
        .onReceive(timer) { _ in
            if autoRefresh {
                loggerObservable.refreshLogs()
            }
        }
    }

    // MARK: - Subviews

    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)

            Text("No Logs")
                .font(.title)

            Text("Logs will appear here as the application runs")
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Computed Properties

    private var filteredLogs: [LogEntry] {
        var logs = loggerObservable.recentLogs

        // Filter by level
        if let level = selectedLevel {
            logs = logs.filter { $0.level == level }
        }

        // Filter by search
        if !searchText.isEmpty {
            logs = logs.filter { entry in
                entry.message.localizedCaseInsensitiveContains(searchText) ||
                entry.file.localizedCaseInsensitiveContains(searchText)
            }
        }

        return logs
    }

    // MARK: - Actions

    private func exportLogs() {
        Task {
            if let logsURL = await AppLogger.shared.exportLogs() {
                let panel = NSSavePanel()
                panel.nameFieldStringValue = "brtstudio-logs-\(Date().ISO8601Format()).jsonl"
                panel.allowedContentTypes = [.json]

                if panel.runModal() == .OK, let saveURL = panel.url {
                    try? FileManager.default.copyItem(at: logsURL, to: saveURL)
                }
            }
        }
    }
}

// MARK: - Level Badge

struct LevelBadge: View {
    let level: LogLevel

    var body: some View {
        Text(level.rawValue)
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(backgroundColor, in: Capsule())
            .foregroundStyle(.white)
    }

    private var backgroundColor: Color {
        switch level {
        case .debug:
            return .gray
        case .info:
            return .blue
        case .warning:
            return .orange
        case .error:
            return .red
        case .critical:
            return .purple
        }
    }
}

// MARK: - Metadata View

struct MetadataView: View {
    let metadata: [String: String]

    var body: some View {
        HStack(spacing: 4) {
            ForEach(Array(metadata.prefix(2)), id: \.key) { key, value in
                Text("\(key): \(value)")
                    .font(.caption)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.quaternary, in: RoundedRectangle(cornerRadius: 4))
            }

            if metadata.count > 2 {
                Text("+\(metadata.count - 2)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    LoggerView()
}
