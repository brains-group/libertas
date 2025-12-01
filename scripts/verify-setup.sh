#!/bin/bash

# Comprehensive setup verification script
# Usage: ./scripts/verify-setup.sh

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
MP_SPDZ_DIR="$SETUP_DIR/MP-SPDZ"

ERRORS=0
WARNINGS=0

check() {
    local name=$1
    local condition=$2
    local message=$3
    
    if eval "$condition"; then
        echo -e "${GREEN}✓${NC} $name: $message"
        return 0
    else
        echo -e "${RED}✗${NC} $name: $message"
        ERRORS=$((ERRORS + 1))
        return 1
    fi
}

warn() {
    local name=$1
    local message=$2
    echo -e "${YELLOW}⚠${NC} $name: $message"
    WARNINGS=$((WARNINGS + 1))
}

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Libertas Setup Verification${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check repositories
echo -e "${YELLOW}Repositories:${NC}"
check "MPC App" "[ -d \"$APP_DIR\" ]" "Repository exists"
check "Agent Services" "[ -d \"$MPC_DIR\" ]" "Repository exists"
check "MP-SPDZ" "[ -d \"$MP_SPDZ_DIR\" ]" "Repository exists"

echo ""

# Check dependencies
echo -e "${YELLOW}Dependencies:${NC}"
check "Python venv" "[ -d \"$MPC_DIR/venv\" ]" "Virtual environment exists"
check "Agent Services Node modules" "[ -d \"$MPC_DIR/node_modules\" ]" "Node modules installed"
check "MPC App Node modules" "[ -d \"$APP_DIR/node_modules\" ]" "Node modules installed"

echo ""

# Check MP-SPDZ
echo -e "${YELLOW}MP-SPDZ:${NC}"
check "MP-SPDZ executables" "[ -f \"$MP_SPDZ_DIR/Player-Online.x\" ]" "Executables built"
check "DownloadData directory" "[ -d \"$MP_SPDZ_DIR/ExternalIO/DownloadData\" ]" "Required directory exists"

echo ""

# Check configuration files
echo -e "${YELLOW}Configuration:${NC}"
check "Encryption Agent Config" "[ -f \"$MPC_DIR/config/encryption_agent.json\" ]" "Config file exists"
check "Computation Agent Config" "[ -f \"$MPC_DIR/config/computation_agent.json\" ]" "Config file exists"

# Check MP-SPDZ path in configs
if [ -f "$MPC_DIR/config/encryption_agent.json" ]; then
    if grep -q "\"base_dir\".*MP-SPDZ" "$MPC_DIR/config/encryption_agent.json" && \
       ! grep -q "\"base_dir\".*PATH/TO" "$MPC_DIR/config/encryption_agent.json"; then
        echo -e "${GREEN}✓${NC} Encryption Agent: MP-SPDZ path configured"
    else
        warn "Encryption Agent" "MP-SPDZ path not configured"
    fi
    
    if grep -q "AGENT-USERNAME\|AGENT-PASSWORD" "$MPC_DIR/config/encryption_agent.json"; then
        warn "Encryption Agent" "Credentials need to be configured (run ./scripts/configure-credentials.sh)"
    else
        echo -e "${GREEN}✓${NC} Encryption Agent: Credentials configured"
    fi
fi

if [ -f "$MPC_DIR/config/computation_agent.json" ]; then
    if grep -q "\"base_dir\".*MP-SPDZ" "$MPC_DIR/config/computation_agent.json" && \
       ! grep -q "\"base_dir\".*PATH/TO" "$MPC_DIR/config/computation_agent.json"; then
        echo -e "${GREEN}✓${NC} Computation Agent: MP-SPDZ path configured"
    else
        warn "Computation Agent" "MP-SPDZ path not configured"
    fi
fi

echo ""

# Check example files
echo -e "${YELLOW}Example Files:${NC}"
check "Preference Example" "[ -f \"$PROJECT_DIR/examples/preference-example.ttl\" ]" "Example exists"
check "Resource Description Example" "[ -f \"$PROJECT_DIR/examples/resource-description-example.ttl\" ]" "Example exists"

echo ""

# Check system dependencies
echo -e "${YELLOW}System Dependencies:${NC}"
check "Python 3" "command -v python3 >/dev/null" "Python 3 installed"
check "Node.js" "command -v node >/dev/null" "Node.js installed"
check "Git" "command -v git >/dev/null" "Git installed"

# Check Homebrew packages (macOS)
if [[ "$OSTYPE" == "darwin"* ]]; then
    if command -v brew >/dev/null; then
        for pkg in openssl boost libsodium gmp; do
            if brew list $pkg >/dev/null 2>&1; then
                echo -e "${GREEN}✓${NC} $pkg: Installed via Homebrew"
            else
                warn "$pkg" "Not found in Homebrew (may be installed elsewhere)"
            fi
        done
    fi
fi

echo ""

# Summary
echo -e "${BLUE}========================================${NC}"
echo "Verification Summary:"
if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✓ All checks passed!${NC}"
    echo ""
    echo "Your Libertas system is ready to use!"
    echo ""
    echo "Next steps:"
    echo "  1. Configure credentials: ./scripts/configure-credentials.sh"
    echo "  2. Start services: ./scripts/start-services.sh"
    echo "  3. Check status: ./scripts/check-services.sh"
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠ Setup complete with $WARNINGS warning(s)${NC}"
    echo ""
    echo "Review the warnings above and address as needed."
else
    echo -e "${RED}✗ Setup incomplete: $ERRORS error(s), $WARNINGS warning(s)${NC}"
    echo ""
    echo "Please fix the errors above before proceeding."
fi
echo ""


