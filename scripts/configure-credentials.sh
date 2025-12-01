#!/bin/bash

# Interactive script to configure encryption agent credentials
# Usage: ./scripts/configure-credentials.sh

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

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Configure Encryption Agent Credentials${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${RED}Error: Configuration file not found at $CONFIG_FILE${NC}"
    exit 1
fi

# Read current values
CURRENT_IDP=$(grep -o '"idp"[[:space:]]*:[[:space:]]*"[^"]*"' "$CONFIG_FILE" | cut -d'"' -f4)
CURRENT_USERNAME=$(grep -o '"username"[[:space:]]*:[[:space:]]*"[^"]*"' "$CONFIG_FILE" | cut -d'"' -f4)
CURRENT_PASSWORD=$(grep -o '"password"[[:space:]]*:[[:space:]]*"[^"]*"' "$CONFIG_FILE" | cut -d'"' -f4)

echo "Current configuration:"
echo "  IDP: $CURRENT_IDP"
echo "  Username: $CURRENT_USERNAME"
echo "  Password: [hidden]"
echo ""

# Get new values
read -p "Enter Solid Pod Provider URL (IDP) [$CURRENT_IDP]: " NEW_IDP
NEW_IDP=${NEW_IDP:-$CURRENT_IDP}

read -p "Enter Encryption Agent WebID Username: " NEW_USERNAME
if [ -z "$NEW_USERNAME" ]; then
    echo -e "${YELLOW}Username not provided. Keeping current value.${NC}"
    NEW_USERNAME=$CURRENT_USERNAME
fi

read -sp "Enter Encryption Agent Password: " NEW_PASSWORD
echo ""
if [ -z "$NEW_PASSWORD" ]; then
    echo -e "${YELLOW}Password not provided. Keeping current value.${NC}"
    NEW_PASSWORD=$CURRENT_PASSWORD
fi

# Create backup
cp "$CONFIG_FILE" "$CONFIG_FILE.backup"
echo -e "${GREEN}✓ Created backup: $CONFIG_FILE.backup${NC}"

# Update configuration using Python for proper JSON handling
python3 << EOF
import json
import sys

config_file = "$CONFIG_FILE"
new_idp = "$NEW_IDP"
new_username = "$NEW_USERNAME"
new_password = "$NEW_PASSWORD"

try:
    with open(config_file, 'r') as f:
        config = json.load(f)
    
    config['credential']['idp'] = new_idp
    config['credential']['username'] = new_username
    config['credential']['password'] = new_password
    
    with open(config_file, 'w') as f:
        json.dump(config, f, indent=2)
    
    print("✓ Configuration updated successfully")
    sys.exit(0)
except Exception as e:
    print(f"Error updating configuration: {e}")
    sys.exit(1)
EOF

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}Configuration updated successfully!${NC}"
    echo ""
    echo "Updated configuration:"
    echo "  IDP: $NEW_IDP"
    echo "  Username: $NEW_USERNAME"
    echo "  Password: [configured]"
    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo "1. Ensure your WebID is registered at: $NEW_IDP"
    echo "2. Add 'https://solid-node-client' to your trusted apps at $NEW_IDP"
    echo "3. Grant the encryption agent read permission to data resources"
    echo ""
    echo "Your WebID will be:"
    echo "  ${NEW_IDP%/}/${NEW_USERNAME}/profile/card#me"
    echo ""
    echo "To verify setup, run: ./scripts/verify-setup.sh"
    echo ""
else
    echo -e "${RED}Error updating configuration. Restoring backup...${NC}"
    mv "$CONFIG_FILE.backup" "$CONFIG_FILE"
    exit 1
fi


