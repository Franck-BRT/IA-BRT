//
//  AppLogger.swift
//  BRT Studio - Structured Logging System
//
//  Copyright © 2025 Black Room Technologies. All rights reserved.
//

import Foundation
import OSLog
import Combine

/// Centralized logging system with JSONL output
actor AppLogger {
    static let shared = AppLogger()

    private let osLogger = Logger(subsystem: AppConstants.bundleIdentifier, category: "app")
    private var logFileHandle: FileHandle?
    private let logFileURL: URL

    private init() {
        // Setup log file
        let logsDir = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first!
            .appendingPathComponent(AppConstants.bundleIdentifier)
            .appendingPathComponent(AppConstants.logsDirectory)

        try? FileManager.default.createDirectory(
            at: logsDir,
            withIntermediateDirectories: true
        )

        // Create log file with timestamp
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: Date())
        logFileURL = logsDir.appendingPathComponent("brtstudio-\(dateString).jsonl")

        // Open log file
        if !FileManager.default.fileExists(atPath: logFileURL.path) {
            FileManager.default.createFile(atPath: logFileURL.path, contents: nil)
        }

        logFileHandle = try? FileHandle(forWritingTo: logFileURL)
        logFileHandle?.seekToEndOfFile()
    }

    deinit {
        try? logFileHandle?.close()
    }

    /// Log a message
    func log(
        _ level: LogLevel,
        _ message: String,
        metadata: [String: String] = [:],
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let entry = LogEntry(
            level: level,
            message: redact(message),
            metadata: redactMetadata(metadata),
            file: URL(fileURLWithPath: file).lastPathComponent,
            function: function,
            line: line,
            timestamp: Date()
        )

        // Write to OS log
        logToOS(entry)

        // Write to file
        Task {
            await writeToFile(entry)
        }
    }

    /// Convenience method for main actor
    nonisolated func log(
        _ level: LogLevel,
        _ message: String,
        metadata: [String: String] = [:]
    ) {
        Task {
            await log(level, message, metadata: metadata)
        }
    }

    private func logToOS(_ entry: LogEntry) {
        let formattedMessage = "[\(entry.level.rawValue)] \(entry.message)"

        switch entry.level {
        case .debug:
            osLogger.debug("\(formattedMessage)")
        case .info:
            osLogger.info("\(formattedMessage)")
        case .warning:
            osLogger.warning("\(formattedMessage)")
        case .error:
            osLogger.error("\(formattedMessage)")
        case .critical:
            osLogger.critical("\(formattedMessage)")
        }
    }

    private func writeToFile(_ entry: LogEntry) {
        guard let data = try? JSONEncoder().encode(entry),
              let jsonString = String(data: data, encoding: .utf8) else {
            return
        }

        let line = jsonString + "\n"
        if let lineData = line.data(using: .utf8) {
            logFileHandle?.write(lineData)
        }
    }

    /// Redact sensitive information (PII)
    private func redact(_ message: String) -> String {
        var result = message

        // Redact email patterns
        let emailPattern = #"[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}"#
        result = result.replacingOccurrences(
            of: emailPattern,
            with: "[EMAIL_REDACTED]",
            options: .regularExpression
        )

        // Redact API keys (simple pattern)
        let apiKeyPattern = #"(api[_-]?key|token|secret)["\s:=]+[a-zA-Z0-9_-]{20,}"#
        result = result.replacingOccurrences(
            of: apiKeyPattern,
            with: "[API_KEY_REDACTED]",
            options: [.regularExpression, .caseInsensitive]
        )

        // Redact file paths containing home directory
        if let homeDir = FileManager.default.homeDirectoryForCurrentUser.path as String? {
            result = result.replacingOccurrences(of: homeDir, with: "~")
        }

        return result
    }

    private func redactMetadata(_ metadata: [String: String]) -> [String: String] {
        var result = metadata

        // Redact known sensitive keys
        let sensitiveKeys = ["password", "token", "secret", "key", "api_key", "apiKey"]
        for key in sensitiveKeys {
            if result[key] != nil {
                result[key] = "[REDACTED]"
            }
        }

        return result
    }

    /// Get logs for viewing
    func getLogs(limit: Int = 100) -> [LogEntry] {
        guard let data = try? Data(contentsOf: logFileURL),
              let content = String(data: data, encoding: .utf8) else {
            return []
        }

        let lines = content.components(separatedBy: .newlines)
            .filter { !$0.isEmpty }
            .suffix(limit)

        return lines.compactMap { line in
            guard let data = line.data(using: .utf8) else { return nil }
            return try? JSONDecoder().decode(LogEntry.self, from: data)
        }
    }

    /// Export logs to file
    func exportLogs() -> URL? {
        return logFileURL
    }
}

// MARK: - Log Models

enum LogLevel: String, Codable {
    case debug = "DEBUG"
    case info = "INFO"
    case warning = "WARNING"
    case error = "ERROR"
    case critical = "CRITICAL"
}

struct LogEntry: Identifiable, Codable {
    let id: UUID
    let level: LogLevel
    let message: String
    let metadata: [String: String]
    let file: String
    let function: String
    let line: Int
    let timestamp: Date

    init(
        id: UUID = UUID(),
        level: LogLevel,
        message: String,
        metadata: [String: String] = [:],
        file: String,
        function: String,
        line: Int,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.level = level
        self.message = message
        self.metadata = metadata
        self.file = file
        self.function = function
        self.line = line
        self.timestamp = timestamp
    }
}

// MARK: - MainActor wrapper for SwiftUI
@MainActor
final class AppLoggerObservable: ObservableObject {
    @Published var recentLogs: [LogEntry] = []

    func refreshLogs() {
        Task {
            recentLogs = await AppLogger.shared.getLogs(limit: 100)
        }
    }
}
