#!/bin/bash

# Script to create test data files for the demo
# Usage: ./scripts/create-test-data.sh

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
DATA_DIR="$PROJECT_DIR/test-data"

echo -e "${BLUE}Creating test data files...${NC}"
echo ""

mkdir -p "$DATA_DIR"

# Create sample CSV data
cat > "$DATA_DIR/data.csv" << 'EOF'
1,2,3,4,5
6,7,8,9,10
11,12,13,14,15
20,25,30,35,40
EOF

echo -e "${GREEN}✓ Created: $DATA_DIR/data.csv${NC}"

# Create preference document
cat > "$DATA_DIR/preferences.ttl" << 'EOF'
@prefix : <urn:solid:mpc#>
@prefix schema: <https://schema.org/>

[]
    :trustedComputationServer
        [ schema:url "http://localhost:8010" ],
        [ schema:url "http://localhost:8011" ],
        [ schema:url "http://localhost:8012" ];
    :trustedEncryptionServer
        [ schema:url "http://localhost:8000";
          :userId "http://localhost:3000/encryption-agent/profile/card#me" ].
EOF

echo -e "${GREEN}✓ Created: $DATA_DIR/preferences.ttl${NC}"

# Create resource description
cat > "$DATA_DIR/resource-description.ttl" << 'EOF'
@prefix : <urn:solid:mpc#>.

:sources a :MPCSourceSpec;
  :source :src1.

:src1 a :MPCSource;
  :pref <http://localhost:3000/data-provider/preferences.ttl>;
  :data <http://localhost:3000/data-provider/data.csv>.
EOF

echo -e "${GREEN}✓ Created: $DATA_DIR/resource-description.ttl${NC}"

echo ""
echo -e "${BLUE}Test data files created in: $DATA_DIR${NC}"
echo ""
echo "Next steps:"
echo "1. Log into http://localhost:3000 as data-provider"
echo "2. Upload these files to your Pod:"
echo "   - $DATA_DIR/data.csv"
echo "   - $DATA_DIR/preferences.ttl"
echo "3. Grant permissions (see END_TO_END_DEMO.md)"
echo "4. Use resource-description.ttl URL in MPC App"
echo ""

