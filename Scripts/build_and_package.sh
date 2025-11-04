#!/bin/bash
#
# build_and_package.sh
# BRT Studio - Build and Package for Distribution
#
# Copyright © 2025 Black Room Technologies. All rights reserved.
#

set -e

echo "📦 Building and packaging BRT Studio..."

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Configuration
APP_NAME="BRT Studio"
BUNDLE_ID="com.blackroomtech.brtstudio"
VERSION="0.1.0"
BUILD_NUMBER="1"
DIST_DIR="dist"
APP_BUNDLE="${DIST_DIR}/${APP_NAME}.app"

# Check requirements
echo -e "${BLUE}🔍 Checking requirements...${NC}"

if ! command -v swift &> /dev/null; then
    echo -e "${RED}❌ Swift not found${NC}"
    exit 1
fi

# Clean previous builds
echo -e "${BLUE}🧹 Cleaning previous builds...${NC}"
rm -rf "${DIST_DIR}"
mkdir -p "${DIST_DIR}"

# Build release binary
echo -e "${BLUE}🏗️  Building release binary...${NC}"
swift build -c release --arch arm64

BINARY_PATH=".build/arm64-apple-macosx/release/BRTStudio"

if [ ! -f "$BINARY_PATH" ]; then
    echo -e "${RED}❌ Binary not found at ${BINARY_PATH}${NC}"
    exit 1
fi

# Create app bundle structure
echo -e "${BLUE}📁 Creating app bundle structure...${NC}"
mkdir -p "${APP_BUNDLE}/Contents/MacOS"
mkdir -p "${APP_BUNDLE}/Contents/Resources"

# Copy binary
cp "$BINARY_PATH" "${APP_BUNDLE}/Contents/MacOS/${APP_NAME}"

# Create Info.plist
echo -e "${BLUE}📝 Creating Info.plist...${NC}"
cat > "${APP_BUNDLE}/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>${APP_NAME}</string>
    <key>CFBundleIdentifier</key>
    <string>${BUNDLE_ID}</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>${APP_NAME}</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>${VERSION}</string>
    <key>CFBundleVersion</key>
    <string>${BUILD_NUMBER}</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>NSHumanReadableCopyright</key>
    <string>Copyright © 2025 Black Room Technologies</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSSupportsAutomaticGraphicsSwitching</key>
    <true/>
</dict>
</plist>
EOF

# Set permissions
chmod +x "${APP_BUNDLE}/Contents/MacOS/${APP_NAME}"

# Create DMG (requires hdiutil - macOS only)
if command -v hdiutil &> /dev/null; then
    echo -e "${BLUE}💿 Creating DMG...${NC}"
    DMG_NAME="${DIST_DIR}/BRTStudio-${VERSION}.dmg"

    # Create temporary DMG directory
    TMP_DMG_DIR="${DIST_DIR}/tmp_dmg"
    mkdir -p "${TMP_DMG_DIR}"
    cp -R "${APP_BUNDLE}" "${TMP_DMG_DIR}/"

    # Create symlink to Applications
    ln -s /Applications "${TMP_DMG_DIR}/Applications"

    # Create DMG
    hdiutil create -volname "${APP_NAME}" -srcfolder "${TMP_DMG_DIR}" -ov -format UDZO "${DMG_NAME}"

    # Clean up
    rm -rf "${TMP_DMG_DIR}"

    echo -e "${GREEN}✅ DMG created: ${DMG_NAME}${NC}"
else
    echo -e "${YELLOW}⚠️  hdiutil not available, skipping DMG creation${NC}"
fi

# Create ZIP archive
echo -e "${BLUE}🗜️  Creating ZIP archive...${NC}"
cd "${DIST_DIR}"
zip -r "BRTStudio-${VERSION}.zip" "${APP_NAME}.app"
cd ..

echo -e "${GREEN}✅ Package created successfully!${NC}"
echo ""
echo -e "${GREEN}📦 Distribution files:${NC}"
ls -lh "${DIST_DIR}"

echo ""
echo -e "${BLUE}📋 Next steps:${NC}"
echo "  1. Test the app: open '${APP_BUNDLE}'"
echo "  2. Sign the app: ./Scripts/sign.sh"
echo "  3. Notarize the app: ./Scripts/notarize.sh"
