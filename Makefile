# Makefile for BRT Studio
# Convenience wrapper around build scripts

.PHONY: help build test clean run release package notarize lint format

# Default target
help:
	@echo "BRT Studio - Build Targets"
	@echo ""
	@echo "Development:"
	@echo "  make build      - Build debug version"
	@echo "  make test       - Run tests"
	@echo "  make run        - Build and run"
	@echo "  make clean      - Clean build artifacts"
	@echo ""
	@echo "Release:"
	@echo "  make release    - Build release version"
	@echo "  make package    - Create app bundle and DMG"
	@echo "  make notarize   - Sign and notarize (requires Apple Dev account)"
	@echo ""
	@echo "Code Quality:"
	@echo "  make lint       - Run SwiftLint (if installed)"
	@echo "  make format     - Format code with swift-format (if installed)"

# Development targets
build:
	@echo "🔨 Building debug version..."
	./Scripts/build.sh

test:
	@echo "🧪 Running tests..."
	./Scripts/test.sh

test-verbose:
	@echo "🧪 Running tests (verbose)..."
	./Scripts/test.sh --verbose

clean:
	@echo "🧹 Cleaning build artifacts..."
	rm -rf .build dist DerivedData
	@echo "✅ Clean complete"

run: build
	@echo "🚀 Running BRT Studio..."
	./.build/debug/BRTStudio

# Release targets
release:
	@echo "🏗️ Building release version..."
	./Scripts/build.sh

package:
	@echo "📦 Creating app bundle and DMG..."
	./Scripts/build_and_package.sh

notarize:
	@echo "🔐 Building, signing, and notarizing..."
	@echo "⚠️  This requires Apple Developer credentials"
	./Scripts/build_and_notarize.sh

# Code quality
lint:
	@if command -v swiftlint >/dev/null 2>&1; then \
		echo "🔍 Running SwiftLint..."; \
		swiftlint; \
	else \
		echo "⚠️  SwiftLint not installed. Install with: brew install swiftlint"; \
	fi

format:
	@if command -v swift-format >/dev/null 2>&1; then \
		echo "🎨 Formatting code..."; \
		swift-format --in-place --recursive BRTStudio/ BRTStudioTests/; \
	else \
		echo "⚠️  swift-format not installed. Install with: brew install swift-format"; \
	fi

# Quick commands
.PHONY: b t r c
b: build
t: test
r: run
c: clean
