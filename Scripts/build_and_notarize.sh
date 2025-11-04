#!/bin/bash
#
# build_and_notarize.sh
# BRT Studio - Build, Sign, and Notarize for Distribution
#
# Copyright © 2025 Black Room Technologies. All rights reserved.
#

set -e

echo "🔐 Building, signing, and notarizing BRT Studio..."

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Configuration - UPDATE THESE VALUES
DEVELOPER_ID_APP="Developer ID Application: Your Name (TEAM_ID)"
APPLE_ID="your-apple-id@example.com"
TEAM_ID="YOUR_TEAM_ID"
APP_SPECIFIC_PASSWORD="your-app-specific-password"  # Or use keychain
BUNDLE_ID="com.blackroomtech.brtstudio"

# Check if credentials are set
if [ "$DEVELOPER_ID_APP" = "Developer ID Application: Your Name (TEAM_ID)" ]; then
    echo -e "${RED}❌ Please configure signing credentials in this script${NC}"
    echo ""
    echo "Required:"
    echo "  1. DEVELOPER_ID_APP - Your Developer ID Application certificate"
    echo "  2. APPLE_ID - Your Apple ID email"
    echo "  3. TEAM_ID - Your Team ID"
    echo "  4. APP_SPECIFIC_PASSWORD - App-specific password from appleid.apple.com"
    echo ""
    echo "For testing without notarization, use: ./Scripts/build_and_package.sh"
    exit 1
fi

# Step 1: Build and package
echo -e "${BLUE}📦 Step 1: Building and packaging...${NC}"
./Scripts/build_and_package.sh

APP_BUNDLE="dist/BRT Studio.app"
DMG_PATH="dist/BRTStudio-0.1.0.dmg"

# Step 2: Code sign
echo -e "${BLUE}🔏 Step 2: Code signing...${NC}"

# Sign the binary
codesign --force --options runtime --deep --sign "$DEVELOPER_ID_APP" "${APP_BUNDLE}"

# Verify signature
echo -e "${BLUE}🔍 Verifying signature...${NC}"
codesign --verify --deep --strict --verbose=2 "${APP_BUNDLE}"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Code signing successful${NC}"
else
    echo -e "${RED}❌ Code signing failed${NC}"
    exit 1
fi

# Step 3: Notarize (requires macOS)
if [ -f "$DMG_PATH" ]; then
    echo -e "${BLUE}📮 Step 3: Notarizing DMG...${NC}"

    # Submit for notarization
    echo "Submitting to Apple for notarization..."
    xcrun notarytool submit "$DMG_PATH" \
        --apple-id "$APPLE_ID" \
        --team-id "$TEAM_ID" \
        --password "$APP_SPECIFIC_PASSWORD" \
        --wait

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Notarization successful${NC}"

        # Staple the notarization ticket
        echo "Stapling notarization ticket..."
        xcrun stapler staple "$DMG_PATH"

        echo -e "${GREEN}✅ DMG is ready for distribution!${NC}"
    else
        echo -e "${RED}❌ Notarization failed${NC}"
        echo "Check notarization history with:"
        echo "  xcrun notarytool history --apple-id $APPLE_ID --team-id $TEAM_ID"
        exit 1
    fi
else
    echo -e "${YELLOW}⚠️  DMG not found, skipping notarization${NC}"
fi

# Step 4: Verify
echo -e "${BLUE}🔍 Step 4: Final verification...${NC}"

# Check app signature
spctl -a -vv "${APP_BUNDLE}"

# Check DMG if exists
if [ -f "$DMG_PATH" ]; then
    spctl -a -t open --context context:primary-signature -v "$DMG_PATH"
fi

echo ""
echo -e "${GREEN}🎉 Build, signing, and notarization complete!${NC}"
echo ""
echo -e "${GREEN}📦 Distribution files:${NC}"
ls -lh dist/

echo ""
echo -e "${BLUE}📋 Distribution checklist:${NC}"
echo "  ✅ App signed with Developer ID"
echo "  ✅ App notarized by Apple"
echo "  ✅ Ready for distribution outside Mac App Store"
