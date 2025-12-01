#!/bin/bash

# Script to check if Libertas services are running
# Usage: ./scripts/check-services.sh

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
MPC_DIR="$PROJECT_DIR/libertas-setup/solid-mpc"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Libertas Services Status${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if port is in use
check_port() {
    if lsof -Pi :$1 -sTCP:LISTEN -t >/dev/null 2>&1 ; then
        return 0
    else
        return 1
    fi
}

# Check PID file
check_pid() {
    local pid_file=$1
    local service_name=$2
    
    if [ -f "$pid_file" ]; then
        local pid=$(cat "$pid_file")
        if ps -p $pid > /dev/null 2>&1; then
            echo -e "${GREEN}✓${NC} $service_name is running (PID: $pid)"
            return 0
        else
            echo -e "${YELLOW}⚠${NC} $service_name PID file exists but process not running"
            return 1
        fi
    else
        return 1
    fi
}

# Check endpoint
check_endpoint() {
    local url=$1
    local name=$2
    
    if curl -s -f -o /dev/null "$url" 2>/dev/null; then
        echo -e "${GREEN}✓${NC} $name is accessible at $url"
        return 0
    else
        echo -e "${RED}✗${NC} $name is not accessible at $url"
        return 1
    fi
}

# Check Encryption Agents
echo -e "${YELLOW}Encryption Agents:${NC}"
ENCRYPTION_RUNNING=0
for port in 8000 8001; do
    if check_port $port; then
        check_endpoint "http://localhost:$port" "Encryption Agent ($port)"
        ENCRYPTION_RUNNING=$((ENCRYPTION_RUNNING + 1))
    else
        check_pid "$MPC_DIR/logs/encryption-$port.pid" "Encryption Agent ($port)" || \
        echo -e "${RED}✗${NC} Encryption Agent ($port) is not running"
    fi
done

echo ""

# Check Computation Agents
echo -e "${YELLOW}Computation Agents:${NC}"
COMPUTATION_RUNNING=0
for port in 8010 8011 8012; do
    if check_port $port; then
        check_endpoint "http://localhost:$port" "Computation Agent ($port)"
        COMPUTATION_RUNNING=$((COMPUTATION_RUNNING + 1))
    else
        check_pid "$MPC_DIR/logs/computation-$port.pid" "Computation Agent ($port)" || \
        echo -e "${RED}✗${NC} Computation Agent ($port) is not running"
    fi
done

echo ""

# Check MPC App
echo -e "${YELLOW}MPC App:${NC}"
if check_pid "$MPC_DIR/logs/mpc-app.pid" "MPC App"; then
    echo -e "${GREEN}✓${NC} MPC App is running"
    # Try to find the dev server URL
    if pgrep -f "vite.*solid-mpc-app" > /dev/null; then
        echo -e "${GREEN}  → Check http://localhost:5173 (or see logs for actual port)${NC}"
    fi
else
    if pgrep -f "vite.*solid-mpc-app" > /dev/null; then
        echo -e "${GREEN}✓${NC} MPC App is running (detected via process)"
    else
        echo -e "${RED}✗${NC} MPC App is not running"
    fi
fi

echo ""
echo -e "${BLUE}========================================${NC}"
echo "Summary:"
echo "  Encryption Agents: $ENCRYPTION_RUNNING/2 running"
echo "  Computation Agents: $COMPUTATION_RUNNING/3 running"
echo ""
if [ $ENCRYPTION_RUNNING -eq 2 ] && [ $COMPUTATION_RUNNING -eq 3 ]; then
    echo -e "${GREEN}All services are running!${NC}"
else
    echo -e "${YELLOW}Some services are not running.${NC}"
    echo "  Start services: ./scripts/start-services.sh"
fi
echo ""


