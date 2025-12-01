#!/bin/bash

# Script to stop all Libertas services
# Usage: ./scripts/stop-services.sh [encryption|computation|app|all]

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

stop_service() {
    local pid_file=$1
    local service_name=$2
    
    if [ -f "$pid_file" ]; then
        local pid=$(cat "$pid_file")
        if ps -p $pid > /dev/null 2>&1; then
            kill $pid 2>/dev/null || true
            echo -e "${GREEN}✓ Stopped $service_name (PID: $pid)${NC}"
        else
            echo -e "${YELLOW}Process $service_name (PID: $pid) not running${NC}"
        fi
        rm -f "$pid_file"
    else
        echo -e "${YELLOW}$service_name not found (no PID file)${NC}"
    fi
}

stop_by_port() {
    local port=$1
    local service_name=$2
    
    local pid=$(lsof -ti :$port 2>/dev/null || true)
    if [ -n "$pid" ]; then
        kill $pid 2>/dev/null || true
        echo -e "${GREEN}✓ Stopped $service_name on port $port${NC}"
    else
        echo -e "${YELLOW}$service_name on port $port not running${NC}"
    fi
}

# Parse command line argument
SERVICE="${1:-all}"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Stopping Libertas Services${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

case $SERVICE in
    encryption)
        stop_by_port 8000 "Encryption Agent"
        stop_by_port 8001 "Encryption Agent"
        stop_service "$MPC_DIR/logs/encryption-8000.pid" "Encryption Agent (8000)"
        stop_service "$MPC_DIR/logs/encryption-8001.pid" "Encryption Agent (8001)"
        ;;
    computation)
        stop_by_port 8010 "Computation Agent"
        stop_by_port 8011 "Computation Agent"
        stop_by_port 8012 "Computation Agent"
        stop_service "$MPC_DIR/logs/computation-8010.pid" "Computation Agent (8010)"
        stop_service "$MPC_DIR/logs/computation-8011.pid" "Computation Agent (8011)"
        stop_service "$MPC_DIR/logs/computation-8012.pid" "Computation Agent (8012)"
        ;;
    app)
        stop_service "$MPC_DIR/logs/mpc-app.pid" "MPC App"
        # Also try to stop by finding node process
        pkill -f "vite.*solid-mpc-app" 2>/dev/null || true
        ;;
    all)
        stop_by_port 8000 "Encryption Agent"
        stop_by_port 8001 "Encryption Agent"
        stop_by_port 8010 "Computation Agent"
        stop_by_port 8011 "Computation Agent"
        stop_by_port 8012 "Computation Agent"
        stop_service "$MPC_DIR/logs/encryption-8000.pid" "Encryption Agent (8000)"
        stop_service "$MPC_DIR/logs/encryption-8001.pid" "Encryption Agent (8001)"
        stop_service "$MPC_DIR/logs/computation-8010.pid" "Computation Agent (8010)"
        stop_service "$MPC_DIR/logs/computation-8011.pid" "Computation Agent (8011)"
        stop_service "$MPC_DIR/logs/computation-8012.pid" "Computation Agent (8012)"
        stop_service "$MPC_DIR/logs/mpc-app.pid" "MPC App"
        pkill -f "vite.*solid-mpc-app" 2>/dev/null || true
        ;;
    *)
        echo -e "${RED}Error: Unknown service '$SERVICE'${NC}"
        echo "Usage: $0 [encryption|computation|app|all]"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}Services stopped${NC}"
echo ""


