#!/bin/bash

# Script to configure Libertas to use local Solid IDP
# Usage: ./scripts/configure-local-idp.sh [username]

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
CONFIG_FILE="$PROJECT_DIR/libertas-setup/solid-mpc/config/encryption_agent.json"

LOCAL_IDP="http://localhost:3000"
# Note: Community Solid Server uses email-based registration
# Default to a test email if no username provided
USERNAME="${1:-test-user@localhost}"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Configure Libertas for Local Solid IDP${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${RED}Error: Configuration file not found${NC}"
    echo "Please run ./scripts/setup-services.sh first"
    exit 1
fi

# Check if Solid server is running
if ! lsof -Pi :3000 -sTCP:LISTEN -t >/dev/null 2>&1 ; then
    echo -e "${YELLOW}Warning: Local Solid server doesn't appear to be running${NC}"
    echo "Start it with: ./scripts/start-solid-server.sh"
    echo ""
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Read current config
CURRENT_IDP=$(grep -o '"idp"[[:space:]]*:[[:space:]]*"[^"]*"' "$CONFIG_FILE" | cut -d'"' -f4)
CURRENT_USERNAME=$(grep -o '"username"[[:space:]]*:[[:space:]]*"[^"]*"' "$CONFIG_FILE" | cut -d'"' -f4)

echo "Current configuration:"
echo "  IDP: $CURRENT_IDP"
echo "  Username: $CURRENT_USERNAME"
echo ""
echo "New configuration:"
echo "  IDP: $LOCAL_IDP"
echo "  Username: $USERNAME"
echo ""

read -p "Update configuration? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled"
    exit 0
fi

# Create backup
cp "$CONFIG_FILE" "$CONFIG_FILE.backup"
echo -e "${GREEN}✓ Created backup${NC}"

# Update configuration
python3 << EOF
import json
import sys

config_file = "$CONFIG_FILE"
new_idp = "$LOCAL_IDP"
new_username = "$USERNAME"

try:
    with open(config_file, 'r') as f:
        config = json.load(f)
    
    config['credential']['idp'] = new_idp
    config['credential']['username'] = new_username
    
    with open(config_file, 'w') as f:
        json.dump(config, f, indent=2)
    
    print("✓ Configuration updated successfully")
    sys.exit(0)
except Exception as e:
    print(f"Error: {e}")
    sys.exit(1)
EOF

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}Configuration updated!${NC}"
    echo ""
    echo "Your encryption agent WebID will be:"
    echo -e "${GREEN}  ${LOCAL_IDP}/[pod-identifier]/profile/card#me${NC}"
    echo "  (Check your profile after registration for exact WebID)"
    echo ""
    echo "Note: Use your EMAIL ADDRESS as the username in the config"
    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo "1. Ensure Solid server is running: ./scripts/start-solid-server.sh"
    echo "2. Register account at: http://localhost:3000"
    echo "   - Username: $USERNAME"
    echo "   - Choose a password"
    echo "3. Add trusted app:"
    echo "   - Go to account settings"
    echo "   - Add 'https://solid-node-client' to authorized apps"
    echo "4. Test authentication: ./scripts/verify-setup.sh"
    echo ""
else
    echo -e "${RED}Error updating configuration. Restoring backup...${NC}"
    mv "$CONFIG_FILE.backup" "$CONFIG_FILE"
    exit 1
fi

