#!/bin/bash

# Script to start the local Solid server
# Usage: ./scripts/start-solid-server.sh

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SOLID_DIR="$PROJECT_DIR/libertas-setup/community-solid-server"

echo -e "${BLUE}Starting Local Solid Server...${NC}"
echo ""

if [ ! -d "$SOLID_DIR" ]; then
    echo -e "${YELLOW}Solid server not set up. Running setup first...${NC}"
    ./scripts/setup-local-solid.sh
fi

cd "$SOLID_DIR"

# Check if already running
if lsof -Pi :3000 -sTCP:LISTEN -t >/dev/null 2>&1 ; then
    echo -e "${YELLOW}Solid server is already running on port 3000${NC}"
    echo "Access it at: http://localhost:3000"
    exit 0
fi

echo "Starting server on http://localhost:3000"
echo "Press Ctrl+C to stop"
echo ""

npm start

