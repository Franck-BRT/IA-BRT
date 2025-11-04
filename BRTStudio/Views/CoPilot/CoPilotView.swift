//
//  CoPilotView.swift
//  BRT Studio - Co-Pilot "Idea → Project" View
//
//  Copyright © 2025 Black Room Technologies. All rights reserved.
//

import SwiftUI

struct CoPilotView: View {
    @StateObject private var engine = CoPilotEngine()
    @State private var userInput = ""
    @State private var showProjectDetails = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView

            Divider()

            // Chat area
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 16) {
                        ForEach(engine.session.messages) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                        }

                        if engine.isProcessing {
                            TypingIndicator()
                        }
                    }
                    .padding()
                }
                .onChange(of: engine.session.messages.count) { _, _ in
                    if let lastMessage = engine.session.messages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }

            Divider()

            // Input area
            inputArea
        }
        .navigationTitle("Co-Pilot")
        .toolbar {
            ToolbarItemGroup {
                phaseIndicator

                if engine.session.generatedProject != nil {
                    Button {
                        showProjectDetails = true
                    } label: {
                        Label("View Project", systemImage: "folder")
                    }
                }

                Button {
                    engine.startNewSession()
                } label: {
                    Label("New Session", systemImage: "plus.circle")
                }
            }
        }
        .sheet(isPresented: $showProjectDetails) {
            if let project = engine.session.generatedProject {
                ProjectDetailsView(project: project)
            }
        }
        .onAppear {
            if engine.session.messages.isEmpty {
                engine.startNewSession()
            }
        }
    }

    // MARK: - Subviews

    private var headerView: some View {
        VStack(spacing: 8) {
            Image(systemName: "wand.and.stars")
                .font(.system(size: 48))
                .foregroundStyle(.blue)

            Text("Project Co-Pilot")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Turn your idea into a complete project scaffold")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
    }

    private var inputArea: some View {
        HStack(spacing: 12) {
            TextField("Type your message...", text: $userInput, axis: .vertical)
                .textFieldStyle(.plain)
                .padding(12)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                .lineLimit(1...5)
                .disabled(engine.isProcessing || engine.session.phase == .completed)
                .onSubmit {
                    sendMessage()
                }

            Button {
                sendMessage()
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
            }
            .buttonStyle(.plain)
            .disabled(userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || engine.isProcessing)
        }
        .padding()
        .background(.background)
    }

    private var phaseIndicator: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(phaseColor)
                .frame(width: 8, height: 8)

            Text(engine.session.phase.rawValue)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var phaseColor: Color {
        switch engine.session.phase {
        case .introduction, .discovery, .refinement:
            return .blue
        case .architecture:
            return .orange
        case .generation:
            return .yellow
        case .completed:
            return .green
        case .error:
            return .red
        }
    }

    // MARK: - Actions

    private func sendMessage() {
        let message = userInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !message.isEmpty else { return }

        userInput = ""

        Task {
            await engine.processUserInput(message)
        }
    }
}

// MARK: - Message Bubble

struct MessageBubble: View {
    let message: CoPilotSession.Message

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

                Text(message.timestamp, style: .time)
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

// MARK: - Typing Indicator

struct TypingIndicator: View {
    @State private var animationPhase = 0

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(.secondary)
                    .frame(width: 8, height: 8)
                    .opacity(animationPhase == index ? 1 : 0.3)
            }
        }
        .padding(12)
        .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 12))
        .onAppear {
            withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: false)) {
                animationPhase = 2
            }
        }
    }
}

// MARK: - Project Details View

struct ProjectDetailsView: View {
    @Environment(\.dismiss) var dismiss
    let project: GeneratedProject

    var body: some View {
        NavigationStack {
            Form {
                Section("Project Information") {
                    LabeledContent("Name", value: project.name)
                    LabeledContent("Description", value: project.description)
                    LabeledContent("Created", value: project.createdAt, format: .dateTime)
                }

                Section("Technology Stack") {
                    LabeledContent("Type", value: project.stack.type.rawValue)
                    LabeledContent("Language", value: project.stack.language.rawValue)
                    LabeledContent("Framework", value: project.stack.framework)
                    LabeledContent("Build System", value: project.stack.buildSystem.rawValue)
                }

                Section("Architecture") {
                    LabeledContent("Pattern", value: project.architecture.pattern.rawValue)
                    LabeledContent("Testing", value: project.architecture.testing.rawValue)

                    DisclosureGroup("Modules") {
                        ForEach(project.architecture.modules) { module in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(module.name)
                                    .font(.headline)
                                Text(module.purpose)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }

                Section("Location") {
                    LabeledContent("Path") {
                        HStack {
                            Text(project.outputPath.path)
                                .lineLimit(1)
                                .truncationMode(.middle)

                            Button {
                                NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: project.outputPath.path)
                            } label: {
                                Image(systemName: "arrow.up.forward.square")
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Project Details")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .frame(width: 600, height: 500)
    }
}

// MARK: - Placeholder Views (to be implemented)

struct AgentsView: View {
    var body: some View {
        VStack {
            Image(systemName: "cpu.fill")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)
            Text("Agents & Workflows")
                .font(.title)
            Text("Coming in Phase 2")
                .foregroundStyle(.secondary)
        }
    }
}

struct PersonaeView: View {
    var body: some View {
        VStack {
            Image(systemName: "person.2.fill")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)
            Text("Personae")
                .font(.title)
            Text("Coming in Phase 2")
                .foregroundStyle(.secondary)
        }
    }
}

struct PromptsView: View {
    var body: some View {
        VStack {
            Image(systemName: "doc.text.fill")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)
            Text("Prompt Templates")
                .font(.title)
            Text("Coming in Phase 2")
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    CoPilotView()
}
