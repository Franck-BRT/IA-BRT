//
//  OllamaClient.swift
//  BRT Studio - Ollama API Client
//
//  Copyright © 2025 Black Room Technologies. All rights reserved.
//

import Foundation

/// Client for interacting with Ollama API (local AI models)
actor OllamaClient {
    private let baseURL: URL
    private let session: URLSession
    private let privacyManager = PrivacyManager.shared
    private let logger = AppLogger.shared

    init(baseURL: String = AppConstants.ollamaDefaultURL) {
        self.baseURL = URL(string: baseURL)!
        self.session = URLSession(configuration: .default)
    }

    /// Check if Ollama is available
    func checkAvailability() async -> Bool {
        // Request network access
        let allowed = await privacyManager.requestNetworkAccess(
            for: "Check Ollama availability",
            destination: baseURL.absoluteString
        )

        guard allowed else {
            await logger.log(.warning, "Ollama availability check blocked by Privacy Mode")
            return false
        }

        do {
            let url = baseURL.appendingPathComponent("/api/tags")
            let (_, response) = try await session.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse else {
                return false
            }

            return httpResponse.statusCode == 200
        } catch {
            await logger.log(.error, "Ollama availability check failed: \(error.localizedDescription)")
            return false
        }
    }

    /// List available models
    func listModels() async throws -> [OllamaModel] {
        let allowed = await privacyManager.requestNetworkAccess(
            for: "List Ollama models",
            destination: baseURL.absoluteString
        )

        guard allowed else {
            throw OllamaError.privacyModeEnabled
        }

        let url = baseURL.appendingPathComponent("/api/tags")
        let (data, _) = try await session.data(from: url)

        let response = try JSONDecoder().decode(ModelsResponse.self, from: data)
        return response.models
    }

    /// Generate completion (streaming)
    func generate(
        model: String,
        prompt: String,
        system: String? = nil,
        temperature: Double = 0.7,
        onChunk: @escaping (String) -> Void
    ) async throws {
        let allowed = await privacyManager.requestNetworkAccess(
            for: "Generate with Ollama",
            destination: baseURL.absoluteString
        )

        guard allowed else {
            throw OllamaError.privacyModeEnabled
        }

        let url = baseURL.appendingPathComponent("/api/generate")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = GenerateRequest(
            model: model,
            prompt: prompt,
            system: system,
            temperature: temperature,
            stream: true
        )

        request.httpBody = try JSONEncoder().encode(body)

        await logger.log(
            .info,
            "Ollama generate request",
            metadata: [
                "model": model,
                "promptLength": "\(prompt.count)",
                "temperature": "\(temperature)"
            ]
        )

        // Stream response
        let (bytes, _) = try await session.bytes(for: request)

        for try await line in bytes.lines {
            if let data = line.data(using: .utf8),
               let response = try? JSONDecoder().decode(GenerateResponse.self, from: data) {
                onChunk(response.response)

                if response.done {
                    await logger.log(
                        .info,
                        "Ollama generation complete",
                        metadata: [
                            "model": model,
                            "totalDuration": response.totalDuration.map { "\($0)" } ?? "unknown"
                        ]
                    )
                    break
                }
            }
        }
    }

    /// Chat completion (with message history)
    func chat(
        model: String,
        messages: [ChatMessage],
        temperature: Double = 0.7,
        onChunk: @escaping (String) -> Void
    ) async throws {
        let allowed = await privacyManager.requestNetworkAccess(
            for: "Chat with Ollama",
            destination: baseURL.absoluteString
        )

        guard allowed else {
            throw OllamaError.privacyModeEnabled
        }

        let url = baseURL.appendingPathComponent("/api/chat")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let ollamaMessages = messages.map { msg in
            OllamaChatMessage(role: msg.role.rawValue, content: msg.content)
        }

        let body = ChatRequest(
            model: model,
            messages: ollamaMessages,
            temperature: temperature,
            stream: true
        )

        request.httpBody = try JSONEncoder().encode(body)

        await logger.log(
            .info,
            "Ollama chat request",
            metadata: [
                "model": model,
                "messageCount": "\(messages.count)",
                "temperature": "\(temperature)"
            ]
        )

        // Stream response
        let (bytes, _) = try await session.bytes(for: request)

        for try await line in bytes.lines {
            if let data = line.data(using: .utf8),
               let response = try? JSONDecoder().decode(ChatResponse.self, from: data) {
                onChunk(response.message.content)

                if response.done {
                    await logger.log(.info, "Ollama chat complete", metadata: ["model": model])
                    break
                }
            }
        }
    }

    /// Pull a model (download)
    func pullModel(name: String, onProgress: @escaping (Double) -> Void) async throws {
        let allowed = await privacyManager.requestNetworkAccess(
            for: "Pull Ollama model",
            destination: baseURL.absoluteString
        )

        guard allowed else {
            throw OllamaError.privacyModeEnabled
        }

        let url = baseURL.appendingPathComponent("/api/pull")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = PullRequest(name: name, stream: true)
        request.httpBody = try JSONEncoder().encode(body)

        await logger.log(.info, "Pulling Ollama model", metadata: ["model": name])

        let (bytes, _) = try await session.bytes(for: request)

        for try await line in bytes.lines {
            if let data = line.data(using: .utf8),
               let response = try? JSONDecoder().decode(PullResponse.self, from: data) {

                if let total = response.total, total > 0,
                   let completed = response.completed {
                    let progress = Double(completed) / Double(total)
                    onProgress(progress)
                }

                if response.status == "success" {
                    await logger.log(.info, "Model pull complete", metadata: ["model": name])
                    break
                }
            }
        }
    }
}

// MARK: - Models

struct OllamaModel: Identifiable, Codable {
    let name: String
    let modifiedAt: String
    let size: Int64

    var id: String { name }

    enum CodingKeys: String, CodingKey {
        case name
        case modifiedAt = "modified_at"
        case size
    }
}

// MARK: - Request/Response Types

private struct ModelsResponse: Codable {
    let models: [OllamaModel]
}

private struct GenerateRequest: Codable {
    let model: String
    let prompt: String
    let system: String?
    let temperature: Double
    let stream: Bool
}

private struct GenerateResponse: Codable {
    let response: String
    let done: Bool
    let totalDuration: Int64?

    enum CodingKeys: String, CodingKey {
        case response
        case done
        case totalDuration = "total_duration"
    }
}

private struct ChatRequest: Codable {
    let model: String
    let messages: [OllamaChatMessage]
    let temperature: Double
    let stream: Bool
}

private struct OllamaChatMessage: Codable {
    let role: String
    let content: String
}

private struct ChatResponse: Codable {
    let message: OllamaChatMessage
    let done: Bool
}

private struct PullRequest: Codable {
    let name: String
    let stream: Bool
}

private struct PullResponse: Codable {
    let status: String
    let total: Int64?
    let completed: Int64?
}

// MARK: - Errors

enum OllamaError: LocalizedError {
    case privacyModeEnabled
    case notAvailable
    case modelNotFound(String)
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .privacyModeEnabled:
            return "Network access blocked by Privacy Mode. Disable Privacy Mode to use Ollama."
        case .notAvailable:
            return "Ollama is not available. Please ensure Ollama is running on \(AppConstants.ollamaDefaultURL)"
        case .modelNotFound(let model):
            return "Model '\(model)' not found. Please pull it first."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}
