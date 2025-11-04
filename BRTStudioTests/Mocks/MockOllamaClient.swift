//
//  MockOllamaClient.swift
//  BRT Studio Tests - Mock Ollama Client
//
//  Copyright © 2025 Black Room Technologies. All rights reserved.
//

import Foundation
@testable import BRTStudio

/// Mock Ollama client for testing without network calls
actor MockOllamaClient {
    var isAvailable = true
    var shouldFailGeneration = false
    var mockModels: [OllamaModel] = [
        OllamaModel(name: "llama3.2", modifiedAt: "2024-01-01", size: 4_000_000_000),
        OllamaModel(name: "codellama", modifiedAt: "2024-01-01", size: 7_000_000_000)
    ]
    var mockResponse = "This is a mock response from Ollama."

    func checkAvailability() async -> Bool {
        return isAvailable
    }

    func listModels() async throws -> [OllamaModel] {
        if !isAvailable {
            throw OllamaError.notAvailable
        }
        return mockModels
    }

    func generate(
        model: String,
        prompt: String,
        system: String? = nil,
        temperature: Double = 0.7,
        onChunk: @escaping (String) -> Void
    ) async throws {
        if shouldFailGeneration {
            throw OllamaError.networkError(NSError(domain: "MockError", code: -1))
        }

        if !isAvailable {
            throw OllamaError.notAvailable
        }

        // Simulate streaming response
        let words = mockResponse.split(separator: " ")
        for word in words {
            onChunk(String(word) + " ")
            try await Task.sleep(nanoseconds: 10_000_000) // 10ms
        }
    }

    func chat(
        model: String,
        messages: [ChatMessage],
        temperature: Double = 0.7,
        onChunk: @escaping (String) -> Void
    ) async throws {
        if shouldFailGeneration {
            throw OllamaError.networkError(NSError(domain: "MockError", code: -1))
        }

        if !isAvailable {
            throw OllamaError.notAvailable
        }

        // Simulate streaming response
        let words = mockResponse.split(separator: " ")
        for word in words {
            onChunk(String(word) + " ")
            try await Task.sleep(nanoseconds: 10_000_000) // 10ms
        }
    }
}
