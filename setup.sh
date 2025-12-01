#!/bin/bash

# Libertas System Setup Script
# This script automates the setup of the Libertas privacy-preserving computation framework

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
MPC_APP_REPO="https://github.com/OxfordHCC/solid-mpc-app.git"
AGENT_SERVICES_REPO="https://github.com/OxfordHCC/solid-mpc.git"
SETUP_DIR="$(pwd)"
LIBERTAS_DIR="$SETUP_DIR/libertas-setup"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Libertas System Setup${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check prerequisites
echo -e "${YELLOW}Checking prerequisites...${NC}"

check_command() {
    if ! command -v $1 &> /dev/null; then
        echo -e "${RED}Error: $1 is not installed. Please install it first.${NC}"
        exit 1
    fi
}

check_command git
check_command python3
check_command node

echo -e "${GREEN}✓ Prerequisites check passed${NC}"
echo ""

# Create setup directory
mkdir -p "$LIBERTAS_DIR"
cd "$LIBERTAS_DIR"

# Clone repositories
echo -e "${YELLOW}Cloning repositories...${NC}"

if [ ! -d "solid-mpc-app" ]; then
    echo "Cloning MPC App repository..."
    git clone "$MPC_APP_REPO" solid-mpc-app
    echo -e "${GREEN}✓ MPC App repository cloned${NC}"
else
    echo -e "${YELLOW}MPC App repository already exists, skipping...${NC}"
fi

if [ ! -d "solid-mpc" ]; then
    echo "Cloning Agent Services repository..."
    git clone "$AGENT_SERVICES_REPO" solid-mpc
    echo -e "${GREEN}✓ Agent Services repository cloned${NC}"
else
    echo -e "${YELLOW}Agent Services repository already exists, skipping...${NC}"
fi

echo ""

# Copy example configuration files
echo -e "${YELLOW}Setting up configuration files...${NC}"

CONFIG_DIR="$SETUP_DIR/config"
mkdir -p "$CONFIG_DIR"

# Copy example preference document
if [ ! -f "$CONFIG_DIR/preference-example.ttl" ]; then
    cp "$SETUP_DIR/examples/preference-example.ttl" "$CONFIG_DIR/preference-example.ttl" 2>/dev/null || true
    echo -e "${GREEN}✓ Example preference document created${NC}"
fi

# Copy example resource description
if [ ! -f "$CONFIG_DIR/resource-description-example.ttl" ]; then
    cp "$SETUP_DIR/examples/resource-description-example.ttl" "$CONFIG_DIR/resource-description-example.ttl" 2>/dev/null || true
    echo -e "${GREEN}✓ Example resource description created${NC}"
fi

echo ""

# Setup instructions
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Setup Summary${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${GREEN}Repositories cloned to:${NC} $LIBERTAS_DIR"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo ""
echo "1. Set up Agent Services:"
echo "   cd $LIBERTAS_DIR/solid-mpc"
echo "   # Follow the README in that repository for setup instructions"
echo ""
echo "2. Set up MPC App:"
echo "   cd $LIBERTAS_DIR/solid-mpc-app"
echo "   # Follow the README in that repository for setup instructions"
echo ""
echo "3. Configure your Solid Pod:"
echo "   - Set up Web Access Control (WAC) permissions"
echo "   - Grant Encryption Agent read permission to data resources"
echo "   - Grant Computation Requestor read permission to Preference Documents"
echo ""
echo "4. Create Preference Documents:"
echo "   - Use the example in: $CONFIG_DIR/preference-example.ttl"
echo "   - Update with your actual agent service URLs"
echo ""
echo "5. Create Resource Description:"
echo "   - Use the example in: $CONFIG_DIR/resource-description-example.ttl"
echo "   - Update with your actual data provider information"
echo ""
echo -e "${BLUE}For detailed instructions, see: SETUP_GUIDE.md${NC}"
echo ""

