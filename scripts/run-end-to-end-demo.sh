#!/bin/bash

# Script to run the end-to-end demo with configured WebIDs
# Usage: ./scripts/run-end-to-end-demo.sh

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# WebIDs from user
ENCRYPTION_AGENT_WEBID="http://localhost:3000/encryption-agent/profile/card#me"
DATA_PROVIDER_WEBID="http://localhost:3000/data-provider/profile/card#me"
REQUESTOR_WEBID="http://localhost:3000/requestor/profile/card#me"

# URLs
DATA_URL="http://localhost:3000/data-provider/data.csv"
PREFERENCES_URL="http://localhost:3000/data-provider/preferences.ttl"
RESOURCE_DESC_URL="http://localhost:3000/data-provider/resource-description.ttl"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}End-to-End Demo Setup${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Step 1: Create test data files
echo -e "${YELLOW}Step 1: Creating test data files...${NC}"
mkdir -p "$PROJECT_DIR/test-data"

# Create data.csv
cat > "$PROJECT_DIR/test-data/data.csv" << 'EOF'
1,2,3,4,5
6,7,8,9,10
11,12,13,14,15
20,25,30,35,40
EOF
echo -e "${GREEN}✓ Created: test-data/data.csv${NC}"

# Create preferences.ttl with correct WebID
cat > "$PROJECT_DIR/test-data/preferences.ttl" << EOF
@prefix : <urn:solid:mpc#>
@prefix schema: <https://schema.org/>

[]
    :trustedComputationServer
        [ schema:url "http://localhost:8010" ],
        [ schema:url "http://localhost:8011" ],
        [ schema:url "http://localhost:8012" ];
    :trustedEncryptionServer
        [ schema:url "http://localhost:8000";
          :userId "${ENCRYPTION_AGENT_WEBID}" ].
EOF
echo -e "${GREEN}✓ Created: test-data/preferences.ttl${NC}"

# Create resource-description.ttl
cat > "$PROJECT_DIR/test-data/resource-description.ttl" << EOF
@prefix : <urn:solid:mpc#>.

:sources a :MPCSourceSpec;
  :source :src1.

:src1 a :MPCSource;
  :pref <${PREFERENCES_URL}>;
  :data <${DATA_URL}>.
EOF
echo -e "${GREEN}✓ Created: test-data/resource-description.ttl${NC}"

echo ""

# Step 2: Check services
echo -e "${YELLOW}Step 2: Checking services...${NC}"
if ! lsof -i :3000 > /dev/null 2>&1; then
    echo -e "${RED}✗ Solid server not running on port 3000${NC}"
    echo "  Start it with: ./scripts/start-solid-server.sh"
    exit 1
fi
echo -e "${GREEN}✓ Solid server running${NC}"

if ! lsof -i :8000 > /dev/null 2>&1; then
    echo -e "${RED}✗ Encryption agent not running on port 8000${NC}"
    echo "  Start services with: ./scripts/start-services.sh"
    exit 1
fi
echo -e "${GREEN}✓ Encryption agent running${NC}"

if ! lsof -i :8010 > /dev/null 2>&1; then
    echo -e "${RED}✗ Computation agents not running${NC}"
    echo "  Start services with: ./scripts/start-services.sh"
    exit 1
fi
echo -e "${GREEN}✓ Computation agents running${NC}"

if ! lsof -i :5173 > /dev/null 2>&1; then
    echo -e "${RED}✗ MPC App not running on port 5173${NC}"
    echo "  Start services with: ./scripts/start-services.sh"
    exit 1
fi
echo -e "${GREEN}✓ MPC App running${NC}"

echo ""

# Step 3: Display upload instructions
echo -e "${YELLOW}Step 3: Upload files to data-provider Pod${NC}"
echo ""
echo -e "${BLUE}Manual Upload Required:${NC}"
echo ""
echo "1. Log into http://localhost:3000 as data-provider"
echo "   → Email: data-provider@localhost"
echo ""
echo "2. Upload these files to your Pod:"
echo "   → $PROJECT_DIR/test-data/data.csv"
echo "   → $PROJECT_DIR/test-data/preferences.ttl"
echo ""
echo "   Files should be accessible at:"
echo "   → $DATA_URL"
echo "   → $PREFERENCES_URL"
echo ""
echo "3. Grant Read Permission to encryption-agent:"
echo "   → Click the lock icon (🔒) on each file"
echo "   → Add: ${ENCRYPTION_AGENT_WEBID}"
echo "   → Set permission to Read"
echo "   → Save"
echo ""
echo "4. Create resource-description.ttl:"
echo "   → Upload: $PROJECT_DIR/test-data/resource-description.ttl"
echo "   → Should be at: $RESOURCE_DESC_URL"
echo "   → Grant Read permission (public or to requestor)"
echo ""
read -p "Press Enter after you've completed the uploads and permissions setup..."

echo ""

# Step 4: Test authentication
echo -e "${YELLOW}Step 4: Testing encryption agent authentication...${NC}"
cd "$PROJECT_DIR/libertas-setup/solid-mpc"
if [ -f "test-auth.js" ]; then
    if node test-auth.js config/encryption_agent.json 2>&1 | grep -q "Authentication successful"; then
        echo -e "${GREEN}✓ Authentication successful${NC}"
    else
        echo -e "${RED}✗ Authentication failed${NC}"
        echo "  Check credentials in: libertas-setup/solid-mpc/config/encryption_agent.json"
        exit 1
    fi
else
    echo -e "${YELLOW}⚠ Test script not found, skipping authentication test${NC}"
fi

echo ""

# Step 5: Display demo instructions
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Ready for Demo!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${BLUE}Demo Steps:${NC}"
echo ""
echo "1. Open MPC App: http://localhost:5173"
echo ""
echo "2. (Optional) Log in as requestor:"
echo "   → Click 'Log in'"
echo "   → WebID: ${REQUESTOR_WEBID}"
echo ""
echo "3. Input Resource Description URL:"
echo "   → ${RESOURCE_DESC_URL}"
echo ""
echo "4. Select Computation:"
echo "   → Choose a computation type (e.g., sum, average)"
echo "   → Configure parameters"
echo ""
echo "5. Run Computation:"
echo "   → Click 'Run' or 'Start'"
echo "   → Monitor progress"
echo "   → View results!"
echo ""
echo -e "${BLUE}Service URLs:${NC}"
echo "  → Solid Server: http://localhost:3000"
echo "  → MPC App: http://localhost:5173"
echo "  → Encryption Agent: http://localhost:8000"
echo "  → Computation Agents: http://localhost:8010, 8011, 8012"
echo ""
echo -e "${BLUE}WebIDs:${NC}"
echo "  → Encryption Agent: ${ENCRYPTION_AGENT_WEBID}"
echo "  → Data Provider: ${DATA_PROVIDER_WEBID}"
echo "  → Requestor: ${REQUESTOR_WEBID}"
echo ""
echo -e "${GREEN}Happy computing! 🚀${NC}"
echo ""

