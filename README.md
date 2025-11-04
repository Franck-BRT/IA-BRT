# BRT Studio

**Black Room Technologies AI Studio** - A native macOS application for local AI development with an "Idea → Project" Co-Pilot.

![macOS](https://img.shields.io/badge/macOS-14.0+-blue.svg)
![Swift](https://img.shields.io/badge/Swift-5.10+-orange.svg)
![License](https://img.shields.io/badge/license-Apache%202.0-green.svg)

## 🎯 Overview

BRT Studio is a **privacy-first, offline-capable AI studio** for macOS that helps you go from idea to working project in minutes. It features:

- **Co-Pilot "Idée → Projet"** - Conversational project scaffolding that generates complete, compilable projects
- **Local AI Chat** - Ollama/MLX integration for completely offline AI interactions
- **Privacy-First** - Zero network calls without explicit consent (Privacy Toggle)
- **Security** - AES-GCM encryption + macOS Keychain integration
- **Native Performance** - Built with SwiftUI for Apple Silicon

## ✨ Key Features

### 🪄 Co-Pilot "Idea → Project" (MVP Priority)

The Co-Pilot guides you through a conversation to understand your project requirements, then generates:

- **Complete project scaffold** with proper structure
- **Technology stack selection** (SwiftUI, Tauri, Rust, Python, etc.)
- **Build scripts** and configuration
- **Initial tests** and documentation
- **Git repository** initialization
- **README, LICENSE, CHANGELOG** and more

**Supported project types:**
- macOS Native (SwiftUI)
- Cross-platform GUI (Tauri)
- CLI tools (Rust, Swift)
- Python scripts/apps

### 🔒 Privacy & Security

- **Privacy Mode** - Toggle to block ALL network requests (default: ON)
- **Offline-first** - Works completely without internet
- **AES-GCM encryption** for sensitive data
- **Keychain integration** for secure key storage
- **Structured logging** with PII redaction (JSONL format)
- **macOS Sandbox** compatible

### 💬 Local AI Chat

- **Ollama integration** (auto-detection + manual configuration)
- **MLX support** (coming soon)
- **Multiple chat sessions**
- **Model switching**
- **Streaming responses**
- **Privacy-aware** - respects Privacy Toggle

### 📊 Additional Features

- **Agents & Workflows** (Phase 2)
- **Personae editor** (Phase 2)
- **Prompt templates** with versioning (Phase 2)
- **Log viewer** - Real-time structured logs
- **Command Palette** (⌘K)

## 🚀 Getting Started

### Prerequisites

- **macOS 14.0+** (Sonoma or later)
- **Xcode 15.0+**
- **Swift 5.10+**
- **Ollama** (optional, for AI features)

### Installation from Source

1. **Clone the repository:**

```bash
git clone https://github.com/Franck-BRT/IA-BRT.git
cd IA-BRT
```

2. **Build the project:**

```bash
./Scripts/build.sh
```

3. **Run:**

```bash
.build/debug/BRTStudio
# or for release:
.build/arm64-apple-macosx/release/BRTStudio
```

### Install Ollama (Optional but Recommended)

For local AI capabilities:

```bash
# Install Ollama
brew install ollama

# Start Ollama service
ollama serve

# Pull a model (in another terminal)
ollama pull llama3.2
```

## 📦 Building for Distribution

### Create App Bundle

```bash
./Scripts/build_and_package.sh
```

This creates:
- `dist/BRT Studio.app` - macOS app bundle
- `dist/BRTStudio-0.1.0.zip` - Distributable ZIP
- `dist/BRTStudio-0.1.0.dmg` - DMG installer (macOS only)

### Code Signing & Notarization

**⚠️ Requires Apple Developer Account**

1. **Configure credentials** in `Scripts/build_and_notarize.sh`
2. **Run:** `./Scripts/build_and_notarize.sh`

## 🧪 Testing

```bash
# Run all tests
./Scripts/test.sh

# Run specific tests
./Scripts/test.sh --filter PrivacyManagerTests

# Verbose output
./Scripts/test.sh --verbose
```

## 🏗️ Architecture

### Project Structure

```
IA-BRT/
├── BRTStudio/                # Main application
│   ├── App/                  # App lifecycle
│   ├── Views/                # SwiftUI views
│   │   ├── CoPilot/         # Co-Pilot UI
│   │   ├── Chat/            # Chat interface
│   │   ├── Settings/        # Settings
│   │   └── Logger/          # Log viewer
│   ├── Models/               # Data models
│   ├── Services/             # Business logic
│   │   ├── AI/              # Ollama, MLX
│   │   ├── CoPilot/         # Co-pilot engine
│   │   ├── Security/        # Encryption
│   │   └── Network/         # Privacy manager
│   └── Core/                 # Utilities
├── Templates/                # Project templates
├── BRTStudioTests/          # Tests
├── Scripts/                  # Build automation
└── Package.swift             # SPM configuration
```

### Technology Stack

- **Language:** Swift 5.10+
- **UI:** SwiftUI (macOS 14+)
- **Build:** Swift Package Manager
- **AI:** Ollama (REST), MLX (planned)
- **Security:** CryptoKit (AES-GCM), Keychain
- **Logging:** OSLog + JSONL

## 🔐 Security & Privacy

### Privacy Features

1. **Privacy Toggle** - Blocks all network requests (default: ON)
2. **Offline-capable** - Works without internet
3. **No telemetry** - Zero data collection
4. **Local models** - On-device inference

### Security Features

1. **AES-GCM encryption** for sensitive data
2. **macOS Keychain** for key storage
3. **Key rotation** support
4. **PII redaction** in logs
5. **Sandbox-compatible**

## 📊 Performance Targets

- **Launch:** < 2 seconds
- **UI response:** < 100ms
- **Project generation:** < 10 seconds (M-series)

## 🛣️ Roadmap

### ✅ Phase 1 - MVP (Current)

- [x] Co-Pilot "Idea → Project"
- [x] Project scaffolding (SwiftUI, Tauri, Python, Rust)
- [x] Local AI Chat (Ollama)
- [x] Privacy Toggle
- [x] AES-GCM + Keychain encryption
- [x] Structured logging
- [x] Test suite
- [x] Build & notarization scripts

### 🔄 Phase 2 - Workflows & Personae

- [ ] Agents & Workflows
- [ ] Personae management
- [ ] Prompt templates with versioning
- [ ] RAG integration
- [ ] MLX on-device inference

### 🔮 Phase 3 - Advanced

- [ ] MCP client
- [ ] Plugin system
- [ ] Sparkle auto-updates
- [ ] Cloud sync (optional)

## 📄 License

Apache License 2.0 - see [LICENSE](LICENSE)

## 🙏 Acknowledgments

- **Ollama** - Local LLM runtime
- **Apple** - SwiftUI, CryptoKit, macOS
- **Tauri** - Cross-platform inspiration

## 📞 Support

- **Issues:** [GitHub Issues](https://github.com/Franck-BRT/IA-BRT/issues)
- **Email:** support@blackroomtech.com

---

**Built with ❤️ for macOS • Offline-first • Privacy-focused**