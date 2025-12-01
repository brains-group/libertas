#!/bin/bash

# Guide for linking WebID in Community Solid Server
# Usage: ./scripts/link-webid-guide.sh

set -e

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Linking WebID in Community Solid Server${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo "Community Solid Server requires a WebID to be linked to your account"
echo "for authentication to work properly."
echo ""
echo -e "${YELLOW}Steps to Link WebID:${NC}"
echo ""
echo "1. Log into your account at: http://localhost:3000"
echo "   - Use your email and password"
echo ""
echo "2. On your account page, find the 'Registered Web IDs' section"
echo ""
echo "3. Click 'Link WebID' button"
echo ""
echo "4. The server will generate/create a WebID for you"
echo "   - Format: http://localhost:3000/[identifier]/profile/card#me"
echo ""
echo "5. Note your WebID - you'll need it for:"
echo "   - Granting permissions on data resources"
echo "   - Referencing in preference documents"
echo ""
echo -e "${GREEN}After linking WebID, authentication should work!${NC}"
echo ""
echo "Test authentication:"
echo "  ./scripts/test-authentication.sh"
echo ""

