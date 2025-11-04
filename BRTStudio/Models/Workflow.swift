//
//  Workflow.swift
//  BRT Studio - Workflow Model
//
//  Copyright © 2025 Black Room Technologies. All rights reserved.
//

import Foundation

/// Agent workflow definition
struct Workflow: Identifiable, Codable {
    let id: UUID
    var name: String
    var description: String
    var nodes: [WorkflowNode]
    var edges: [WorkflowEdge]
    let createdAt: Date
    var updatedAt: Date
    var tags: [String]
    var version: String

    init(
        id: UUID = UUID(),
        name: String,
        description: String = "",
        nodes: [WorkflowNode] = [],
        edges: [WorkflowEdge] = [],
        tags: [String] = [],
        version: String = "1.0.0"
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.nodes = nodes
        self.edges = edges
        self.createdAt = Date()
        self.updatedAt = Date()
        self.tags = tags
        self.version = version
    }

    /// Validate workflow structure
    func validate() -> [String] {
        var errors: [String] = []

        if nodes.isEmpty {
            errors.append("Workflow must have at least one node")
        }

        // Check for cycles (simplified)
        // TODO: Implement proper cycle detection

        // Check all edges reference valid nodes
        let nodeIds = Set(nodes.map { $0.id })
        for edge in edges {
            if !nodeIds.contains(edge.from) {
                errors.append("Edge references unknown source node: \(edge.from)")
            }
            if !nodeIds.contains(edge.to) {
                errors.append("Edge references unknown target node: \(edge.to)")
            }
        }

        return errors
    }
}

/// Workflow node (step in the workflow)
struct WorkflowNode: Identifiable, Codable {
    let id: UUID
    var type: NodeType
    var name: String
    var config: NodeConfig

    init(id: UUID = UUID(), type: NodeType, name: String, config: NodeConfig = NodeConfig()) {
        self.id = id
        self.type = type
        self.name = name
        self.config = config
    }

    enum NodeType: String, Codable, CaseIterable {
        case llm = "LLM Call"
        case rag = "RAG Query"
        case mcpTool = "MCP Tool"
        case branch = "Conditional Branch"
        case transform = "Transform Data"
        case script = "Run Script"
    }

    struct NodeConfig: Codable {
        var prompt: String?
        var model: String?
        var tool: String?
        var condition: String?
        var script: String?
        var parameters: [String: String] = [:]
    }
}

/// Edge connecting workflow nodes
struct WorkflowEdge: Identifiable, Codable {
    let id: UUID
    let from: UUID // source node ID
    let to: UUID // target node ID
    var condition: String? // optional condition for branching

    init(id: UUID = UUID(), from: UUID, to: UUID, condition: String? = nil) {
        self.id = id
        self.from = from
        self.to = to
        self.condition = condition
    }
}

/// Workflow execution trace
struct WorkflowExecution: Identifiable, Codable {
    let id: UUID
    let workflowId: UUID
    let startedAt: Date
    var completedAt: Date?
    var status: Status
    var nodeExecutions: [NodeExecution]

    enum Status: String, Codable {
        case running = "Running"
        case completed = "Completed"
        case failed = "Failed"
        case cancelled = "Cancelled"
    }

    struct NodeExecution: Identifiable, Codable {
        let id: UUID
        let nodeId: UUID
        let startedAt: Date
        var completedAt: Date?
        var output: String?
        var error: String?
    }
}
