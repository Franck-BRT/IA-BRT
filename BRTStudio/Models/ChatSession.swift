//
//  ChatSession.swift
//  BRT Studio - Chat Session Model
//
//  Copyright © 2025 Black Room Technologies. All rights reserved.
//

import Foundation

/// Represents a chat session with an AI model
struct ChatSession: Identifiable, Codable {
    let id: UUID
    var title: String
    var model: AIModel
    var messages: [ChatMessage]
    let createdAt: Date
    var updatedAt: Date
    var systemPrompt: String?
    var temperature: Double
    var maxTokens: Int?

    init(
        id: UUID = UUID(),
        title: String = "New Chat",
        model: AIModel = .ollama("llama3.2"),
        systemPrompt: String? = nil,
        temperature: Double = 0.7
    ) {
        self.id = id
        self.title = title
        self.model = model
        self.messages = []
        self.createdAt = Date()
        self.updatedAt = Date()
        self.systemPrompt = systemPrompt
        self.temperature = temperature
        self.maxTokens = nil
    }

    mutating func addMessage(_ message: ChatMessage) {
        messages.append(message)
        updatedAt = Date()

        // Auto-title from first user message
        if title == "New Chat", message.role == .user, messages.count <= 2 {
            title = String(message.content.prefix(50))
        }
    }

    /// Get context for the AI (recent messages)
    func getContext(limit: Int = 20) -> [ChatMessage] {
        return Array(messages.suffix(limit))
    }
}

/// Individual chat message
struct ChatMessage: Identifiable, Codable {
    let id: UUID
    let role: Role
    var content: String
    let timestamp: Date
    var isStreaming: Bool
    var metadata: MessageMetadata?

    init(
        id: UUID = UUID(),
        role: Role,
        content: String,
        timestamp: Date = Date(),
        isStreaming: Bool = false,
        metadata: MessageMetadata? = nil
    ) {
        self.id = id
        self.role = role
        self.content = content
        self.timestamp = timestamp
        self.isStreaming = isStreaming
        self.metadata = metadata
    }

    enum Role: String, Codable {
        case system = "system"
        case user = "user"
        case assistant = "assistant"
    }

    struct MessageMetadata: Codable {
        var model: String?
        var tokensUsed: Int?
        var latencyMs: Int?
        var finishReason: String?
    }
}

/// AI Model configuration
enum AIModel: Codable, Equatable, Hashable {
    case ollama(String) // model name
    case mlx(String) // model path
    case openAI(String) // model name (for future cloud support)

    var displayName: String {
        switch self {
        case .ollama(let model):
            return "Ollama: \(model)"
        case .mlx(let model):
            return "MLX: \(model)"
        case .openAI(let model):
            return "OpenAI: \(model)"
        }
    }

    var requiresNetwork: Bool {
        switch self {
        case .ollama, .mlx:
            return false
        case .openAI:
            return true
        }
    }

    // Codable conformance
    enum CodingKeys: String, CodingKey {
        case type, value
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .ollama(let model):
            try container.encode("ollama", forKey: .type)
            try container.encode(model, forKey: .value)
        case .mlx(let model):
            try container.encode("mlx", forKey: .type)
            try container.encode(model, forKey: .value)
        case .openAI(let model):
            try container.encode("openai", forKey: .type)
            try container.encode(model, forKey: .value)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        let value = try container.decode(String.self, forKey: .value)

        switch type {
        case "ollama":
            self = .ollama(value)
        case "mlx":
            self = .mlx(value)
        case "openai":
            self = .openAI(value)
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .type,
                in: container,
                debugDescription: "Unknown model type: \(type)"
            )
        }
    }
}
