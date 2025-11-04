#!/bin/bash
#
# build.sh
# BRT Studio Build Script
#
# Copyright © 2025 Black Room Technologies. All rights reserved.
#

set -e

echo "🔨 Building BRT Studio..."

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configuration
BUILD_CONFIG="release"
SCHEME="BRTStudio"
DERIVED_DATA_PATH=".build/DerivedData"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --debug)
            BUILD_CONFIG="debug"
            shift
            ;;
        --clean)
            CLEAN=1
            shift
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Clean if requested
if [ "$CLEAN" = "1" ]; then
    echo -e "${BLUE}🧹 Cleaning build directory...${NC}"
    rm -rf .build
    rm -rf DerivedData
fi

# Check Swift version
echo -e "${BLUE}📦 Checking Swift version...${NC}"
swift --version

# Build with Swift Package Manager
echo -e "${BLUE}🏗️  Building with configuration: ${BUILD_CONFIG}${NC}"

if [ "$BUILD_CONFIG" = "release" ]; then
    swift build -c release --arch arm64
else
    swift build -c debug
fi

# Check if build succeeded
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Build successful!${NC}"

    # Show binary location
    if [ "$BUILD_CONFIG" = "release" ]; then
        BINARY_PATH=".build/arm64-apple-macosx/release/BRTStudio"
    else
        BINARY_PATH=".build/debug/BRTStudio"
    fi

    if [ -f "$BINARY_PATH" ]; then
        echo -e "${GREEN}📍 Binary location: ${BINARY_PATH}${NC}"
        ls -lh "$BINARY_PATH"
    fi
else
    echo -e "${RED}❌ Build failed${NC}"
    exit 1
fi

echo -e "${GREEN}🎉 Build complete!${NC}"
