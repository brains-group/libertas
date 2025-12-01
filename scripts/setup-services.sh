#!/bin/bash

# Script to set up agent services and MPC app dependencies
# Usage: ./scripts/setup-services.sh

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

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Setting up Libertas Services${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if repositories are cloned
if [ ! -d "$SETUP_DIR/solid-mpc" ] || [ ! -d "$SETUP_DIR/solid-mpc-app" ]; then
    echo -e "${RED}Error: Repositories not found. Please run ./setup.sh first.${NC}"
    exit 1
fi

# Setup Agent Services
echo -e "${YELLOW}Setting up Agent Services...${NC}"
cd "$SETUP_DIR/solid-mpc"

# Install Python dependencies
if [ -f "requirements.txt" ]; then
    echo "Setting up Python virtual environment..."
    if [ ! -d "venv" ]; then
        python3 -m venv venv
        echo -e "${GREEN}✓ Virtual environment created${NC}"
    fi
    
    echo "Installing Python dependencies..."
    source venv/bin/activate
    pip install --upgrade pip
    pip install -r requirements.txt
    deactivate
    echo -e "${GREEN}✓ Python dependencies installed${NC}"
else
    echo -e "${YELLOW}Warning: requirements.txt not found${NC}"
fi

# Install Node.js dependencies
if [ -f "package.json" ]; then
    echo "Installing Node.js dependencies..."
    npm install
    echo -e "${GREEN}✓ Node.js dependencies installed${NC}"
else
    echo -e "${YELLOW}Warning: package.json not found${NC}"
fi

# Create config directory if it doesn't exist
mkdir -p "$SETUP_DIR/solid-mpc/config"

# Copy configuration files if they don't exist
if [ ! -f "$SETUP_DIR/solid-mpc/config/encryption_agent.json" ]; then
    if [ -f "$SETUP_DIR/solid-mpc/config-example/encryption_agent.json" ]; then
        cp "$SETUP_DIR/solid-mpc/config-example/encryption_agent.json" "$SETUP_DIR/solid-mpc/config/encryption_agent.json"
        echo -e "${GREEN}✓ Created encryption_agent.json config file${NC}"
        echo -e "${YELLOW}  Please edit config/encryption_agent.json with your settings${NC}"
    fi
fi

if [ ! -f "$SETUP_DIR/solid-mpc/config/computation_agent.json" ]; then
    if [ -f "$SETUP_DIR/solid-mpc/config-example/computation_agent.json" ]; then
        cp "$SETUP_DIR/solid-mpc/config-example/computation_agent.json" "$SETUP_DIR/solid-mpc/config/computation_agent.json"
        echo -e "${GREEN}✓ Created computation_agent.json config file${NC}"
        echo -e "${YELLOW}  Please edit config/computation_agent.json with your MP-SPDZ path${NC}"
    fi
fi

echo ""

# Setup MPC App
echo -e "${YELLOW}Setting up MPC App...${NC}"
cd "$SETUP_DIR/solid-mpc-app"

# Install Node.js dependencies
if [ -f "package.json" ]; then
    echo "Installing Node.js dependencies..."
    npm install
    echo -e "${GREEN}✓ MPC App dependencies installed${NC}"
else
    echo -e "${YELLOW}Warning: package.json not found${NC}"
fi

echo ""

# Check for MP-SPDZ
echo -e "${YELLOW}Checking for MP-SPDZ...${NC}"
if command -v mp-spdz &> /dev/null || [ -d "$HOME/MP-SPDZ" ] || [ -d "/opt/MP-SPDZ" ]; then
    echo -e "${GREEN}✓ MP-SPDZ found or may be installed${NC}"
else
    echo -e "${YELLOW}⚠ MP-SPDZ not found in common locations${NC}"
    echo -e "${YELLOW}  You may need to install MP-SPDZ separately${NC}"
    echo -e "${YELLOW}  See: https://github.com/data61/MP-SPDZ${NC}"
fi

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Setup Complete${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo ""
echo "1. Configure Agent Services:"
echo "   - Edit: $SETUP_DIR/solid-mpc/config/encryption_agent.json"
echo "     * Set MP-SPDZ base_dir path"
echo "     * Configure WebID credentials (idp, username, password)"
echo ""
echo "   - Edit: $SETUP_DIR/solid-mpc/config/computation_agent.json"
echo "     * Set MP-SPDZ base_dir path"
echo ""
echo "2. Install MP-SPDZ (if not already installed):"
echo "   git clone https://github.com/data61/MP-SPDZ.git"
echo "   cd MP-SPDZ"
echo "   # Follow MP-SPDZ installation instructions"
echo ""
echo "3. Create required directories:"
echo "   mkdir -p MP-SPDZ/ExternalIO/DownloadData"
echo ""
echo "4. Start services:"
echo "   # Option 1: Automated (using tmuxp)"
echo "   cd $SETUP_DIR/solid-mpc"
echo "   tmuxp load tmux_sessions.yaml"
echo ""
echo "   # Option 2: Manual"
echo "   # Encryption Agent:"
echo "   cd $SETUP_DIR/solid-mpc"
echo "   uvicorn encryption_server:app --port 8000 --reload"
echo ""
echo "   # Computation Agent:"
echo "   PORT_BASE=5000 uvicorn computation_server:app --port 8010"
echo ""
echo "5. Start MPC App:"
echo "   cd $SETUP_DIR/solid-mpc-app"
echo "   npm run build && npm run start"
echo ""

