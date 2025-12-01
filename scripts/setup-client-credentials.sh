#!/bin/bash

# Script to set up client credentials for encryption agent
# Community Solid Server uses client credentials instead of trusted apps
# Usage: ./scripts/setup-client-credentials.sh

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Setting up Client Credentials${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo "Community Solid Server uses Client Credentials instead of"
echo "traditional 'trusted apps'. Here's how to set it up:"
echo ""
echo -e "${YELLOW}Step 1: Create Client Credentials${NC}"
echo ""
echo "1. Log into your account at: http://localhost:3000"
echo "2. Go to your account page (you should see it after login)"
echo "3. Find the 'Credential tokens' section"
echo "4. Click 'Create token' or similar button"
echo "5. Give it a name (e.g., 'Libertas Encryption Agent')"
echo "6. Copy the generated token/secret"
echo ""
echo -e "${YELLOW}Step 2: Update Configuration${NC}"
echo ""
echo "The encryption agent will use your email/password for authentication."
echo "Client credentials are optional but recommended for better security."
echo ""
echo "If you need to use client credentials, you may need to modify"
echo "the data_fetcher.js to use them instead of password authentication."
echo ""
echo -e "${BLUE}Alternative: Password-based Authentication${NC}"
echo ""
echo "For local development, Community Solid Server should work with"
echo "email/password authentication without requiring explicit app authorization."
echo ""
echo "Try testing authentication first:"
echo "  ./scripts/test-authentication.sh"
echo ""
echo "If authentication fails, we may need to configure the server"
echo "to be more permissive for local development."
echo ""

