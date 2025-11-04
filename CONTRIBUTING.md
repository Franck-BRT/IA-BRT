# Contributing to BRT Studio

Thank you for your interest in contributing to BRT Studio! This document provides guidelines and instructions for contributing.

## 🤝 Code of Conduct

By participating in this project, you agree to maintain a respectful and collaborative environment.

## 🚀 Getting Started

### Prerequisites

- macOS 14.0+ (Sonoma or later)
- Xcode 15.0+
- Swift 5.10+
- Git
- Ollama (optional, for AI features)

### Setup Development Environment

1. **Fork and clone:**

```bash
git clone https://github.com/YOUR_USERNAME/IA-BRT.git
cd IA-BRT
```

2. **Build:**

```bash
./Scripts/build.sh
```

3. **Run tests:**

```bash
./Scripts/test.sh
```

## 📋 How to Contribute

### Reporting Bugs

1. Check if the bug has already been reported in [Issues](https://github.com/Franck-BRT/IA-BRT/issues)
2. If not, create a new issue with:
   - Clear title and description
   - Steps to reproduce
   - Expected vs actual behavior
   - macOS version, Swift version
   - Logs if applicable

### Suggesting Features

1. Check [Issues](https://github.com/Franck-BRT/IA-BRT/issues) for existing suggestions
2. Create a new issue with:
   - Clear description of the feature
   - Use cases
   - Potential implementation approach
   - Label as `enhancement`

### Submitting Pull Requests

1. **Create a feature branch:**

```bash
git checkout -b feature/amazing-feature
```

2. **Make your changes:**
   - Follow the code style guide below
   - Write tests for new features
   - Update documentation as needed
   - Ensure all tests pass

3. **Commit your changes:**

```bash
git commit -m "Add amazing feature"
```

Use conventional commits:
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation
- `test:` - Tests
- `refactor:` - Code refactoring
- `chore:` - Maintenance

4. **Push and create PR:**

```bash
git push origin feature/amazing-feature
```

Then open a Pull Request on GitHub.

## 📝 Code Style Guide

### Swift Code Style

- Follow [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- Use 4 spaces for indentation
- Maximum line length: 120 characters
- Use meaningful variable names
- Document public APIs with comments

Example:

```swift
/// Encrypts data using AES-GCM
/// - Parameter data: The data to encrypt
/// - Returns: Encrypted data with algorithm metadata
/// - Throws: EncryptionError if encryption fails
func encrypt(_ data: Data) async throws -> EncryptedData {
    // Implementation
}
```

### SwiftUI Views

- Keep views small and focused
- Extract reusable components
- Use `@State`, `@StateObject`, `@EnvironmentObject` appropriately
- Prefer `@MainActor` for UI-related classes

### File Organization

- One type per file
- Group related files in folders
- Use `// MARK: -` to organize code sections

### Comments

- Document WHY, not WHAT
- Use `///` for documentation comments
- Use `//` for inline explanations
- Use `// MARK: -` for section headers

## 🧪 Testing Guidelines

### Writing Tests

- Write tests for all new features
- Maintain or improve code coverage
- Use descriptive test names
- Follow Arrange-Act-Assert pattern

Example:

```swift
func testPrivacyModeBlocksNetworkRequests() async throws {
    // Arrange
    let manager = PrivacyManager.shared
    manager.enablePrivacyMode()

    // Act
    let allowed = await manager.requestNetworkAccess(
        for: "Test",
        destination: "https://example.com"
    )

    // Assert
    XCTAssertFalse(allowed, "Privacy mode should block requests")
}
```

### Running Tests

```bash
# All tests
./Scripts/test.sh

# Specific test
./Scripts/test.sh --filter MyTests

# With coverage
swift test --enable-code-coverage
```

## 🔐 Security Guidelines

- Never commit secrets or API keys
- Use Keychain for sensitive data
- Respect Privacy Toggle in all network code
- Redact PII in logs
- Follow macOS security best practices

## 📚 Documentation

- Update README.md for user-facing changes
- Add inline documentation for complex logic
- Update architecture docs for structural changes
- Include examples in documentation

## 🏷️ Labeling Conventions

- `bug` - Something isn't working
- `enhancement` - New feature or improvement
- `documentation` - Documentation updates
- `good first issue` - Good for newcomers
- `help wanted` - Extra attention needed
- `security` - Security-related
- `performance` - Performance-related
- `Phase 2`, `Phase 3` - Roadmap phases

## 🔄 Development Workflow

1. Pick an issue or create one
2. Comment that you're working on it
3. Create a feature branch
4. Write code and tests
5. Ensure tests pass
6. Update documentation
7. Submit pull request
8. Address review feedback
9. Merge after approval

## 📦 Release Process

(For maintainers)

1. Update version in `AppConstants.swift`
2. Update `CHANGELOG.md`
3. Create release branch
4. Run full test suite
5. Build and test release binary
6. Create signed DMG
7. Create GitHub release
8. Update documentation

## 🎯 Priority Areas

Current priorities for contributions:

### Phase 1 (MVP) - Polish
- UI/UX improvements
- Bug fixes
- Performance optimizations
- Test coverage

### Phase 2 - In Progress
- Agents & Workflows implementation
- Personae management
- Prompt templates
- RAG integration
- MLX integration

### Phase 3 - Future
- MCP client
- Plugin system
- Sparkle updates
- Cloud sync (optional)

## 💬 Communication

- **Issues:** Technical discussions
- **Discussions:** General questions, ideas
- **Pull Requests:** Code review
- **Email:** support@blackroomtech.com

## 📄 License

By contributing, you agree that your contributions will be licensed under the Apache License 2.0.

## 🙏 Recognition

All contributors will be recognized in:
- GitHub contributors list
- Release notes
- Project documentation

Thank you for contributing to BRT Studio! 🎉
