//
//  TauriTemplate.swift
//  BRT Studio - Tauri Project Templates
//
//  Copyright © 2025 Black Room Technologies. All rights reserved.
//

import Foundation

enum TauriTemplate {

    static func generateConfig(projectName: String) -> String {
        return """
        {
          "$schema": "https://schema.tauri.app/config/1",
          "build": {
            "beforeDevCommand": "npm run dev",
            "beforeBuildCommand": "npm run build",
            "devPath": "http://localhost:1420",
            "distDir": "../dist"
          },
          "package": {
            "productName": "\(projectName)",
            "version": "0.1.0"
          },
          "tauri": {
            "allowlist": {
              "all": false,
              "fs": {
                "all": true,
                "scope": ["$APPDATA/*"]
              }
            },
            "bundle": {
              "active": true,
              "identifier": "com.\(projectName.lowercased())",
              "targets": "all"
            },
            "security": {
              "csp": null
            },
            "windows": [
              {
                "title": "\(projectName)",
                "width": 1200,
                "height": 800,
                "resizable": true,
                "fullscreen": false
              }
            ]
          }
        }
        """
    }

    static func generateCargoToml(projectName: String) -> String {
        return """
        [package]
        name = "\(projectName.lowercased())"
        version = "0.1.0"
        edition = "2021"

        [build-dependencies]
        tauri-build = { version = "1.5" }

        [dependencies]
        serde = { version = "1.0", features = ["derive"] }
        serde_json = "1.0"
        tauri = { version = "1.5", features = ["shell-open"] }

        [features]
        default = ["custom-protocol"]
        custom-protocol = ["tauri/custom-protocol"]
        """
    }

    static func generateMainRs() -> String {
        return """
        // Prevents additional console window on Windows in release
        #![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

        fn main() {
            tauri::Builder::default()
                .invoke_handler(tauri::generate_handler![greet])
                .run(tauri::generate_context!())
                .expect("error while running tauri application");
        }

        #[tauri::command]
        fn greet(name: &str) -> String {
            format!("Hello, {}! Welcome to Tauri!", name)
        }
        """
    }

    static func generateIndexHtml(projectName: String) -> String {
        return """
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>\(projectName)</title>
            <style>
                * {
                    margin: 0;
                    padding: 0;
                    box-sizing: border-box;
                }

                body {
                    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, sans-serif;
                    display: flex;
                    justify-content: center;
                    align-items: center;
                    min-height: 100vh;
                    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                    color: white;
                }

                .container {
                    text-align: center;
                    padding: 2rem;
                }

                h1 {
                    font-size: 3rem;
                    margin-bottom: 1rem;
                }

                p {
                    font-size: 1.2rem;
                    opacity: 0.9;
                }

                .input-group {
                    margin-top: 2rem;
                }

                input {
                    padding: 0.75rem 1rem;
                    font-size: 1rem;
                    border: none;
                    border-radius: 8px;
                    margin-right: 0.5rem;
                    width: 200px;
                }

                button {
                    padding: 0.75rem 1.5rem;
                    font-size: 1rem;
                    background: white;
                    color: #667eea;
                    border: none;
                    border-radius: 8px;
                    cursor: pointer;
                    font-weight: 600;
                    transition: transform 0.2s;
                }

                button:hover {
                    transform: scale(1.05);
                }

                #greeting {
                    margin-top: 1.5rem;
                    font-size: 1.5rem;
                    font-weight: 600;
                }
            </style>
        </head>
        <body>
            <div class="container">
                <h1>Welcome to \(projectName)</h1>
                <p>Built with Tauri</p>

                <div class="input-group">
                    <input id="name-input" type="text" placeholder="Enter your name">
                    <button onclick="greet()">Greet</button>
                </div>

                <div id="greeting"></div>
            </div>

            <script>
                const { invoke } = window.__TAURI__.tauri;

                async function greet() {
                    const name = document.getElementById('name-input').value;
                    const greeting = await invoke('greet', { name });
                    document.getElementById('greeting').textContent = greeting;
                }
            </script>
        </body>
        </html>
        """
    }
}
