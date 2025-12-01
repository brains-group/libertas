#!/bin/bash

# Script to upload files to Community Solid Server Pod using HTTP PUT
# Usage: ./scripts/upload-files-to-pod.sh [password]

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
DATA_DIR="$PROJECT_DIR/test-data"

# URLs
SOLID_SERVER="http://localhost:3000"
DATA_PROVIDER_EMAIL="data-provider@localhost"
DATA_URL="$SOLID_SERVER/data-provider/data.csv"
PREFERENCES_URL="$SOLID_SERVER/data-provider/preferences.ttl"
RESOURCE_DESC_URL="$SOLID_SERVER/data-provider/resource-description.ttl"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Upload Files to Solid Pod${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Get password
if [ -n "$1" ]; then
    PASSWORD="$1"
else
    read -sp "Enter password for $DATA_PROVIDER_EMAIL: " PASSWORD
    echo ""
fi

if [ -z "$PASSWORD" ]; then
    echo -e "${RED}Error: Password required${NC}"
    exit 1
fi

# Check if files exist
if [ ! -f "$DATA_DIR/data.csv" ]; then
    echo -e "${RED}Error: $DATA_DIR/data.csv not found${NC}"
    echo "  Run: ./scripts/run-end-to-end-demo.sh first"
    exit 1
fi

# Function to upload file using HTTP PUT
upload_file() {
    local file_path=$1
    local target_url=$2
    local file_name=$(basename "$file_path")
    local content_type="text/plain"
    
    # Determine content type
    case "$file_name" in
        *.csv)
            content_type="text/csv"
            ;;
        *.ttl)
            content_type="text/turtle"
            ;;
    esac
    
    echo -e "${YELLOW}Uploading $file_name...${NC}"
    echo "  From: $file_path"
    echo "  To: $target_url"
    
    # First, try to authenticate and get a session
    # Community Solid Server uses password authentication
    # We'll use HTTP PUT with Basic Auth or session-based auth
    
    # Try with Basic Auth first
    response=$(curl -s -w "\nHTTPSTATUS:%{http_code}" -X PUT \
        -H "Content-Type: $content_type" \
        -H "Slug: $file_name" \
        --data-binary "@$file_path" \
        --user "$DATA_PROVIDER_EMAIL:$PASSWORD" \
        "$target_url" 2>&1)
    
    http_code=$(echo "$response" | grep -o "HTTPSTATUS:[0-9]*" | cut -d: -f2)
    body=$(echo "$response" | sed 's/HTTPSTATUS:[0-9]*$//')
    
    if [ "$http_code" = "201" ] || [ "$http_code" = "200" ] || [ "$http_code" = "204" ]; then
        echo -e "${GREEN}✓ Uploaded: $file_name${NC}"
        return 0
    else
        # Try alternative: authenticate first, then upload
        echo -e "${YELLOW}  Basic auth failed, trying session-based auth...${NC}"
        
        # Get login endpoint
        login_url="$SOLID_SERVER/.account/login/password/"
        
        # Authenticate and get session cookie (follow redirects)
        cookie_jar=$(mktemp)
        auth_response=$(curl -s -L -c "$cookie_jar" -X POST \
            -H "Content-Type: application/json" \
            -H "Accept: application/json" \
            -d "{\"email\":\"$DATA_PROVIDER_EMAIL\",\"password\":\"$PASSWORD\"}" \
            "$login_url" 2>&1)
        
        # Check if authentication succeeded by checking cookies
        if [ ! -s "$cookie_jar" ]; then
            echo -e "${RED}✗ Authentication failed: No session cookie received${NC}"
            echo "  Please verify your email and password"
            rm -f "$cookie_jar"
            return 1
        fi
        
        # Try upload with session cookie
        response=$(curl -s -w "\nHTTPSTATUS:%{http_code}" -X PUT \
            -b "$cookie_jar" \
            -H "Content-Type: $content_type" \
            -H "Slug: $file_name" \
            --data-binary "@$file_path" \
            "$target_url" 2>&1)
        
        http_code=$(echo "$response" | grep -o "HTTPSTATUS:[0-9]*" | cut -d: -f2)
        body=$(echo "$response" | sed 's/HTTPSTATUS:[0-9]*$//')
        
        rm -f "$cookie_jar"
        
        if [ "$http_code" = "201" ] || [ "$http_code" = "200" ] || [ "$http_code" = "204" ]; then
            echo -e "${GREEN}✓ Uploaded: $file_name${NC}"
            return 0
        else
            echo -e "${RED}✗ Upload failed: HTTP $http_code${NC}"
            echo "  Response: $body"
            echo ""
            echo -e "${YELLOW}Note: Authentication may have failed.${NC}"
            echo "  Please verify:"
            echo "  1. Your email: $DATA_PROVIDER_EMAIL"
            echo "  2. Your password is correct"
            echo "  3. Your WebID is linked to your account"
            echo "  4. You have write permissions to the Pod"
            return 1
        fi
    fi
}

# Authenticate once and reuse session for all files
echo -e "${YELLOW}Authenticating...${NC}"
login_url="$SOLID_SERVER/.account/login/password/"
cookie_jar=$(mktemp)

# Authenticate and follow redirects to get session
auth_response=$(curl -s -L -c "$cookie_jar" -X POST \
    -H "Content-Type: application/json" \
    -H "Accept: application/json" \
    -d "{\"email\":\"$DATA_PROVIDER_EMAIL\",\"password\":\"$PASSWORD\"}" \
    "$login_url" 2>&1)

# Visit account page to fully establish session
curl -s -L -b "$cookie_jar" -c "$cookie_jar" \
    "$SOLID_SERVER/.account/" > /dev/null 2>&1

# Check if authentication succeeded (check for any cookie or successful response)
if [ ! -s "$cookie_jar" ]; then
    echo -e "${RED}✗ Authentication failed: No session cookie received${NC}"
    echo "  Response: $auth_response"
    echo ""
    echo "  Please verify:"
    echo "  1. Your email: $DATA_PROVIDER_EMAIL"
    echo "  2. Your password is correct"
    echo "  3. Your WebID is linked to your account"
    echo "  4. The Solid server is running at $SOLID_SERVER"
    rm -f "$cookie_jar"
    exit 1
fi

# Check if we got any cookies (more flexible check)
if ! grep -q "localhost" "$cookie_jar" 2>/dev/null; then
    echo -e "${YELLOW}⚠ Warning: No cookies found, but continuing...${NC}"
fi

echo -e "${GREEN}✓ Authenticated${NC}"
echo ""

# Upload files using the session
upload_file_with_session() {
    local file_path=$1
    local target_url=$2
    local file_name=$(basename "$file_path")
    local content_type="text/plain"
    
    # Determine content type
    case "$file_name" in
        *.csv)
            content_type="text/csv"
            ;;
        *.ttl)
            content_type="text/turtle"
            ;;
    esac
    
    echo -e "${YELLOW}Uploading $file_name...${NC}"
    echo "  From: $file_path"
    echo "  To: $target_url"
    
    # Use both -b (read) and -c (write) to maintain session
    response=$(curl -s -L -w "\nHTTPSTATUS:%{http_code}" -X PUT \
        -b "$cookie_jar" \
        -c "$cookie_jar" \
        -H "Content-Type: $content_type" \
        -H "Slug: $file_name" \
        --data-binary "@$file_path" \
        "$target_url" 2>&1)
    
    http_code=$(echo "$response" | grep -o "HTTPSTATUS:[0-9]*" | cut -d: -f2)
    body=$(echo "$response" | sed 's/HTTPSTATUS:[0-9]*$//')
    
    if [ "$http_code" = "201" ] || [ "$http_code" = "200" ] || [ "$http_code" = "204" ]; then
        echo -e "${GREEN}✓ Uploaded: $file_name${NC}"
        return 0
    else
        echo -e "${RED}✗ Upload failed: HTTP $http_code${NC}"
        if [ -n "$body" ]; then
            echo "  Response: $body"
        fi
        return 1
    fi
}

# Upload files
echo -e "${YELLOW}Uploading files...${NC}"
echo ""

upload_file_with_session "$DATA_DIR/data.csv" "$DATA_URL"
upload_file_with_session "$DATA_DIR/preferences.ttl" "$PREFERENCES_URL"
upload_file_with_session "$DATA_DIR/resource-description.ttl" "$RESOURCE_DESC_URL"

# Clean up
rm -f "$cookie_jar"

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Upload Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Verify files are accessible:"
echo "  → $DATA_URL"
echo "  → $PREFERENCES_URL"
echo "  → $RESOURCE_DESC_URL"
echo ""
echo -e "${BLUE}Next Steps:${NC}"
echo "1. Grant Read Permission to encryption-agent:"
echo "   → Log into: $SOLID_SERVER"
echo "   → Click lock icon (🔒) on each file"
echo "   → Add: http://localhost:3000/encryption-agent/profile/card#me"
echo "   → Set permission to Read"
echo "   → Save"
echo ""
echo "2. Run the demo:"
echo "   → Open: http://localhost:5173"
echo "   → Input resource description: $RESOURCE_DESC_URL"
echo ""

