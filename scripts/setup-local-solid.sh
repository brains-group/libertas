#!/bin/bash

# Script to set up a local Solid IDP and Pod server for Libertas
# Usage: ./scripts/setup-local-solid.sh

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SETUP_DIR="$PROJECT_DIR/libertas-setup"
SOLID_DIR="$SETUP_DIR/community-solid-server"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Setting up Local Solid Server${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check prerequisites
echo -e "${YELLOW}Checking prerequisites...${NC}"

check_command() {
    if ! command -v $1 &> /dev/null; then
        echo -e "${RED}Error: $1 is not installed. Please install it first.${NC}"
        return 1
    fi
    return 0
}

check_command node || exit 1
check_command npm || exit 1

NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 18 ]; then
    echo -e "${YELLOW}Warning: Node.js version should be 18 or higher (current: $(node -v))${NC}"
fi

echo -e "${GREEN}✓ Prerequisites check passed${NC}"
echo ""

# Create setup directory
mkdir -p "$SETUP_DIR"
cd "$SETUP_DIR"

# Clone Community Solid Server
echo -e "${YELLOW}Setting up Community Solid Server...${NC}"

if [ ! -d "community-solid-server" ]; then
    echo "Cloning Community Solid Server..."
    git clone https://github.com/CommunitySolidServer/CommunitySolidServer.git community-solid-server
    echo -e "${GREEN}✓ Community Solid Server cloned${NC}"
else
    echo -e "${YELLOW}Community Solid Server already exists, updating...${NC}"
    cd community-solid-server
    git pull || true
    cd ..
fi

cd "$SOLID_DIR"

# Install dependencies
if [ ! -d "node_modules" ]; then
    echo "Installing dependencies (this may take a few minutes)..."
    npm install
    echo -e "${GREEN}✓ Dependencies installed${NC}"
else
    echo -e "${YELLOW}Dependencies already installed${NC}"
fi

# Create configuration directory
mkdir -p config

# Create configuration file
CONFIG_FILE="$SOLID_DIR/config/config.json"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Creating configuration file..."
    cat > "$CONFIG_FILE" << 'EOF'
{
  "port": 3000,
  "baseUrl": "http://localhost:3000",
  "loggingLevel": "info",
  "rootFilePath": "./data",
  "podTemplateFolder": "./templates",
  "enableWebId": true,
  "server": {
    "name": "Local Solid Server",
    "description": "Local Solid server for Libertas development"
  },
  "identityProvider": {
    "enabled": true
  },
  "storage": {
    "backend": "FileSystem",
    "options": {
      "root": "./data"
    }
  }
}
EOF
    echo -e "${GREEN}✓ Configuration file created${NC}"
else
    echo -e "${YELLOW}Configuration file already exists${NC}"
fi

# Create data directory
mkdir -p data
mkdir -p templates

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}Local Solid Server Setup Complete!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo "Configuration:"
echo "  Server URL: http://localhost:3000"
echo "  Data directory: $SOLID_DIR/data"
echo ""
echo "To start the server:"
echo "  cd $SOLID_DIR"
echo "  npm start"
echo ""
echo "Or use the helper script:"
echo "  ./scripts/start-solid-server.sh"
echo ""
echo "To create a test account:"
echo "  1. Go to: http://localhost:3000"
echo "  2. Click 'Register' or 'Sign up'"
echo "  3. Create an account (e.g., 'test-user')"
echo "  4. Your WebID will be: http://localhost:3000/test-user/profile/card#me"
echo ""

