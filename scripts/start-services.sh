#!/bin/bash

# Script to start all Libertas services
# Usage: ./scripts/start-services.sh [encryption|computation|app|all]

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
MPC_DIR="$SETUP_DIR/solid-mpc"
APP_DIR="$SETUP_DIR/solid-mpc-app"

# Check if services are already running
check_port() {
    if lsof -Pi :$1 -sTCP:LISTEN -t >/dev/null 2>&1 ; then
        return 0
    else
        return 1
    fi
}

start_encryption_agent() {
    local port=$1
    echo -e "${YELLOW}Starting Encryption Agent on port $port...${NC}"
    
    if check_port $port; then
        echo -e "${YELLOW}Port $port is already in use. Skipping...${NC}"
        return
    fi
    
    cd "$MPC_DIR"
    source venv/bin/activate
    nohup uvicorn encryption_server:app --port $port --reload > "logs/encryption-$port.log" 2>&1 &
    echo $! > "logs/encryption-$port.pid"
    echo -e "${GREEN}✓ Encryption Agent started on port $port (PID: $(cat logs/encryption-$port.pid))${NC}"
    deactivate
}

start_computation_agent() {
    local port=$1
    local port_base=$2
    echo -e "${YELLOW}Starting Computation Agent on port $port (PORT_BASE=$port_base)...${NC}"
    
    if check_port $port; then
        echo -e "${YELLOW}Port $port is already in use. Skipping...${NC}"
        return
    fi
    
    cd "$MPC_DIR"
    source venv/bin/activate
    PORT_BASE=$port_base nohup uvicorn computation_server:app --port $port > "logs/computation-$port.log" 2>&1 &
    echo $! > "logs/computation-$port.pid"
    echo -e "${GREEN}✓ Computation Agent started on port $port (PID: $(cat logs/computation-$port.pid))${NC}"
    deactivate
}

start_mpc_app() {
    echo -e "${YELLOW}Starting MPC App...${NC}"
    
    cd "$APP_DIR"
    nohup npm run dev > "../logs/mpc-app.log" 2>&1 &
    echo $! > "../logs/mpc-app.pid"
    echo -e "${GREEN}✓ MPC App started (PID: $(cat ../logs/mpc-app.pid))${NC}"
}

# Create logs directory
mkdir -p "$MPC_DIR/logs"

# Parse command line argument
SERVICE="${1:-all}"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Starting Libertas Services${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if virtual environment exists
if [ ! -d "$MPC_DIR/venv" ]; then
    echo -e "${RED}Error: Virtual environment not found. Please run ./scripts/setup-services.sh first.${NC}"
    exit 1
fi

# Check if config files exist
if [ ! -f "$MPC_DIR/config/encryption_agent.json" ] || [ ! -f "$MPC_DIR/config/computation_agent.json" ]; then
    echo -e "${RED}Error: Configuration files not found. Please run ./scripts/setup-services.sh first.${NC}"
    exit 1
fi

case $SERVICE in
    encryption)
        start_encryption_agent 8000
        start_encryption_agent 8001
        ;;
    computation)
        start_computation_agent 8010 5000
        start_computation_agent 8011 5010
        start_computation_agent 8012 5020
        ;;
    app)
        start_mpc_app
        ;;
    all)
        start_encryption_agent 8000
        start_encryption_agent 8001
        start_computation_agent 8010 5000
        start_computation_agent 8011 5010
        start_computation_agent 8012 5020
        start_mpc_app
        ;;
    *)
        echo -e "${RED}Error: Unknown service '$SERVICE'${NC}"
        echo "Usage: $0 [encryption|computation|app|all]"
        exit 1
        ;;
esac

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}Services started successfully!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo "Service Status:"
echo "  Encryption Agents: http://localhost:8000, http://localhost:8001"
echo "  Computation Agents: http://localhost:8010, http://localhost:8011, http://localhost:8012"
echo "  MPC App: Check logs/mpc-app.log for URL"
echo ""
echo "To stop services, run: ./scripts/stop-services.sh"
echo "To check status, run: ./scripts/check-services.sh"
echo ""


