//
//  SwiftUITemplate.swift
//  BRT Studio - SwiftUI Project Templates
//
//  Copyright © 2025 Black Room Technologies. All rights reserved.
//

import Foundation

enum SwiftUITemplate {

    static func generatePackageSwift(projectName: String, spec: ProjectSpecification) -> String {
        return """
        // swift-tools-version: 5.10
        import PackageDescription

        let package = Package(
            name: "\(projectName)",
            platforms: [
                .macOS(.v14)
            ],
            products: [
                .executable(
                    name: "\(projectName)",
                    targets: ["\(projectName)"]
                )
            ],
            dependencies: [],
            targets: [
                .executableTarget(
                    name: "\(projectName)",
                    dependencies: []
                ),
                .testTarget(
                    name: "\(projectName)Tests",
                    dependencies: ["\(projectName)"]
                )
            ]
        )
        """
    }

    static func generateApp(projectName: String) -> String {
        return """
        //
        //  \(projectName)App.swift
        //  \(projectName)
        //

        import SwiftUI

        @main
        struct \(projectName)App: App {
            var body: some Scene {
                WindowGroup {
                    ContentView()
                        .frame(minWidth: 800, minHeight: 600)
                }
                .windowStyle(.hiddenTitleBar)
                .windowToolbarStyle(.unified)

                Settings {
                    SettingsView()
                }
            }
        }
        """
    }

    static func generateContentView() -> String {
        return """
        //
        //  ContentView.swift
        //

        import SwiftUI

        struct ContentView: View {
            @State private var text = ""

            var body: some View {
                NavigationSplitView {
                    // Sidebar
                    List {
                        Label("Home", systemImage: "house")
                        Label("Settings", systemImage: "gearshape")
                    }
                } detail: {
                    // Main content
                    VStack(spacing: 20) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 64))
                            .foregroundStyle(.blue)

                        Text("Welcome to Your App")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        TextField("Enter text...", text: $text)
                            .textFieldStyle(.roundedBorder)
                            .frame(maxWidth: 400)

                        Button("Submit") {
                            print("Submitted: \\(text)")
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }

        #Preview {
            ContentView()
        }
        """
    }

    static func generateSettingsView() -> String {
        return """
        //
        //  SettingsView.swift
        //

        import SwiftUI

        struct SettingsView: View {
            @AppStorage("enableNotifications") private var enableNotifications = true
            @AppStorage("theme") private var theme = "system"

            var body: some View {
                Form {
                    Section("General") {
                        Toggle("Enable Notifications", isOn: $enableNotifications)

                        Picker("Theme", selection: $theme) {
                            Text("System").tag("system")
                            Text("Light").tag("light")
                            Text("Dark").tag("dark")
                        }
                    }

                    Section("About") {
                        LabeledContent("Version", value: "1.0.0")
                        LabeledContent("Build", value: "1")
                    }
                }
                .formStyle(.grouped)
                .frame(width: 500, height: 400)
            }
        }

        #Preview {
            SettingsView()
        }
        """
    }

    static func generateExampleModel() -> String {
        return """
        //
        //  ExampleModel.swift
        //

        import Foundation

        struct ExampleModel: Identifiable, Codable {
            let id: UUID
            var name: String
            var createdAt: Date

            init(id: UUID = UUID(), name: String, createdAt: Date = Date()) {
                self.id = id
                self.name = name
                self.createdAt = createdAt
            }
        }
        """
    }

    static func generateTests(projectName: String) -> String {
        return """
        //
        //  \(projectName)Tests.swift
        //

        import XCTest
        @testable import \(projectName)

        final class \(projectName)Tests: XCTestCase {

            func testExample() throws {
                // Example test
                XCTAssertEqual(2 + 2, 4)
            }

            func testPerformance() throws {
                measure {
                    // Performance test
                    _ = (0..<1000).map { $0 * 2 }
                }
            }
        }
        """
    }
}
