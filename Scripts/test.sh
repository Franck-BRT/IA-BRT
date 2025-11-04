#!/bin/bash
#
# test.sh
# BRT Studio Test Runner
#
# Copyright © 2025 Black Room Technologies. All rights reserved.
#

set -e

echo "🧪 Running BRT Studio tests..."

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Parse arguments
VERBOSE=0
FILTER=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --verbose|-v)
            VERBOSE=1
            shift
            ;;
        --filter)
            FILTER="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Run tests
echo -e "${BLUE}🏃 Running tests...${NC}"

if [ $VERBOSE -eq 1 ]; then
    VERBOSE_FLAG="--verbose"
else
    VERBOSE_FLAG=""
fi

if [ -n "$FILTER" ]; then
    swift test $VERBOSE_FLAG --filter "$FILTER"
else
    swift test $VERBOSE_FLAG
fi

# Check test result
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ All tests passed!${NC}"
else
    echo -e "${RED}❌ Tests failed${NC}"
    exit 1
fi

# Generate test coverage (if xcov is installed)
if command -v xcov &> /dev/null; then
    echo -e "${BLUE}📊 Generating test coverage...${NC}"
    swift test --enable-code-coverage
    xcov
fi

echo -e "${GREEN}🎉 Testing complete!${NC}"
