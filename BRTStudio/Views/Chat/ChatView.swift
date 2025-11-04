//
//  ChatView.swift
//  BRT Studio - AI Chat Interface
//
//  Copyright © 2025 Black Room Technologies. All rights reserved.
//

import SwiftUI

struct ChatView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var chatManager = ChatManager()
    @State private var selectedSession: ChatSession?
    @State private var userInput = ""
    @State private var showModelPicker = false

    var body: some View {
        HSplitView {
            // Sessions list
            sessionsList
                .frame(minWidth: 200, idealWidth: 250, maxWidth: 300)

            // Chat area
            if let session = selectedSession {
                chatArea(for: session)
            } else {
                emptyState
            }
        }
        .navigationTitle("Chat")
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button {
                    createNewSession()
                } label: {
                    Label("New Chat", systemImage: "plus.bubble")
                }
            }

            ToolbarItem(placement: .automatic) {
                if selectedSession != nil {
                    Button {
                        showModelPicker = true
                    } label: {
                        Label("Model: \(selectedSession?.model.displayName ?? "None")", systemImage: "cpu")
                    }
                }
            }
        }
        .sheet(isPresented: $showModelPicker) {
            if let session = selectedSession {
                ModelPickerView(selectedModel: Binding(
                    get: { session.model },
                    set: { newModel in
                        if let index = chatManager.sessions.firstIndex(where: { $0.id == session.id }) {
                            chatManager.sessions[index].model = newModel
                        }
                    }
                ))
            }
        }
        .onAppear {
            if chatManager.sessions.isEmpty {
                createNewSession()
            } else {
                selectedSession = chatManager.sessions.first
            }
        }
    }

    // MARK: - Subviews

    private var sessionsList: some View {
        List(selection: $selectedSession) {
            ForEach(chatManager.sessions) { session in
                SessionRow(session: session)
                    .tag(session)
            }
            .onDelete { indexSet in
                chatManager.sessions.remove(atOffsets: indexSet)
                if selectedSession != nil && !chatManager.sessions.contains(where: { $0.id == selectedSession!.id }) {
                    selectedSession = chatManager.sessions.first
                }
            }
        }
        .listStyle(.sidebar)
    }

    private func chatArea(for session: ChatSession) -> some View {
        VStack(spacing: 0) {
            // Messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 16) {
                        ForEach(session.messages) { message in
                            ChatMessageView(message: message)
                                .id(message.id)
                        }

                        if chatManager.isGenerating {
                            TypingIndicator()
                        }
                    }
                    .padding()
                }
                .onChange(of: session.messages.count) { _, _ in
                    if let lastMessage = session.messages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }

            Divider()

            // Input
            HStack(spacing: 12) {
                TextField("Message...", text: $userInput, axis: .vertical)
                    .textFieldStyle(.plain)
                    .padding(12)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                    .lineLimit(1...5)
                    .disabled(chatManager.isGenerating)
                    .onSubmit {
                        sendMessage(to: session)
                    }

                Button {
                    sendMessage(to: session)
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 32))
                }
                .buttonStyle(.plain)
                .disabled(userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || chatManager.isGenerating)
            }
            .padding()
        }
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)

            Text("No Chat Selected")
                .font(.title)

            Button("Start New Chat") {
                createNewSession()
            }
            .buttonStyle(.borderedProminent)
        }
    }

    // MARK: - Actions

    private func createNewSession() {
        let session = ChatSession()
        chatManager.sessions.insert(session, at: 0)
        selectedSession = session
    }

    private func sendMessage(to session: ChatSession) {
        let text = userInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        userInput = ""

        Task {
            await chatManager.sendMessage(text, in: session)
        }
    }
}

// MARK: - Session Row

struct SessionRow: View {
    let session: ChatSession

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(session.title)
                .font(.headline)
                .lineLimit(1)

            if let lastMessage = session.messages.last {
                Text(lastMessage.content)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Chat Message View

struct ChatMessageView: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.role == .user {
                Spacer()
            }

            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .padding(12)
                    .background(backgroundColor, in: RoundedRectangle(cornerRadius: 12))
                    .foregroundStyle(textColor)
                    .textSelection(.enabled)

                HStack(spacing: 4) {
                    Text(message.timestamp, style: .time)

                    if let metadata = message.metadata, let latency = metadata.latencyMs {
                        Text("• \(latency)ms")
                    }
                }
                .font(.caption2)
                .foregroundStyle(.secondary)
            }
            .frame(maxWidth: 600, alignment: message.role == .user ? .trailing : .leading)

            if message.role == .assistant {
                Spacer()
            }
        }
    }

    private var backgroundColor: Color {
        switch message.role {
        case .user:
            return .blue
        case .assistant:
            return Color(nsColor: .controlBackgroundColor)
        case .system:
            return .gray.opacity(0.2)
        }
    }

    private var textColor: Color {
        message.role == .user ? .white : .primary
    }
}

// MARK: - Model Picker

struct ModelPickerView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedModel: AIModel
    @State private var availableModels: [String] = []
    @State private var isLoading = true

    var body: some View {
        NavigationStack {
            List {
                Section("Ollama Models") {
                    if isLoading {
                        ProgressView()
                    } else if availableModels.isEmpty {
                        Text("No models found. Install models using `ollama pull <model>`")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(availableModels, id: \.self) { model in
                            Button {
                                selectedModel = .ollama(model)
                                dismiss()
                            } label: {
                                HStack {
                                    Text(model)
                                    Spacer()
                                    if case .ollama(let current) = selectedModel, current == model {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(.blue)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                Section("MLX Models") {
                    Text("MLX support coming soon")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Select Model")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .task {
                await loadModels()
            }
        }
        .frame(width: 400, height: 500)
    }

    private func loadModels() async {
        let client = OllamaClient()
        do {
            let models = try await client.listModels()
            availableModels = models.map { $0.name }
        } catch {
            availableModels = []
        }
        isLoading = false
    }
}

// MARK: - Chat Manager

@MainActor
class ChatManager: ObservableObject {
    @Published var sessions: [ChatSession] = []
    @Published var isGenerating = false

    private let ollamaClient = OllamaClient()

    func sendMessage(_ text: String, in session: ChatSession) async {
        guard !isGenerating else { return }

        isGenerating = true
        defer { isGenerating = false }

        // Find session index
        guard let index = sessions.firstIndex(where: { $0.id == session.id }) else { return }

        // Add user message
        let userMessage = ChatMessage(role: .user, content: text)
        sessions[index].addMessage(userMessage)

        // Prepare assistant message
        var assistantContent = ""
        let assistantMessage = ChatMessage(role: .assistant, content: "", isStreaming: true)
        sessions[index].addMessage(assistantMessage)

        let assistantIndex = sessions[index].messages.count - 1
        let startTime = Date()

        do {
            // Get model
            let modelName: String
            switch session.model {
            case .ollama(let name):
                modelName = name
            default:
                throw NSError(domain: "ChatManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unsupported model type"])
            }

            // Stream response
            try await ollamaClient.chat(
                model: modelName,
                messages: sessions[index].getContext(),
                temperature: session.temperature
            ) { chunk in
                assistantContent += chunk
                Task { @MainActor in
                    if let idx = self.sessions.firstIndex(where: { $0.id == session.id }) {
                        self.sessions[idx].messages[assistantIndex].content = assistantContent
                    }
                }
            }

            // Finalize message
            let latency = Int(Date().timeIntervalSince(startTime) * 1000)
            sessions[index].messages[assistantIndex].isStreaming = false
            sessions[index].messages[assistantIndex].metadata = ChatMessage.MessageMetadata(
                model: modelName,
                latencyMs: latency
            )

        } catch {
            // Handle error
            sessions[index].messages[assistantIndex].content = "Error: \(error.localizedDescription)"
            sessions[index].messages[assistantIndex].isStreaming = false
        }
    }
}

#Preview {
    ChatView()
        .environmentObject(AppState())
}
