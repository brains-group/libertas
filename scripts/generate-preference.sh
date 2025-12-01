#!/bin/bash

# Script to generate a preference document template
# Usage: ./scripts/generate-preference.sh [output-file]

set -e

OUTPUT_FILE="${1:-preference.ttl}"

cat > "$OUTPUT_FILE" << 'EOF'
@prefix : <urn:solid:mpc#>
@prefix schema: <https://schema.org/>

# Libertas Preference Document
# Generated: $(date)
#
# Instructions:
# 1. Replace the example URLs with your actual agent service URLs
# 2. Update the userId values for Encryption Agents if needed
# 3. Add or remove Computation/Encryption servers as needed
# 4. Upload this file to your Solid Pod
# 5. Grant read permission to Computation Requestor for this document

[]
    :trustedComputationServer
        [ schema:url "http://localhost:8010" ],
        [ schema:url "http://localhost:8011" ],
        [ schema:url "http://localhost:8012" ];
    :trustedEncryptionServer
        [ schema:url "http://localhost:8000";
          :userId "https://web.id/alice#me" ],
        [ schema:url "http://localhost:8001";
          :userId "can-also-be-some-special-id-for-this-encryption-agent-service" ].
EOF

# Replace the date placeholder
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s/\$(date)/$(date)/" "$OUTPUT_FILE"
else
    sed -i "s/\$(date)/$(date)/" "$OUTPUT_FILE"
fi

echo "Preference document generated: $OUTPUT_FILE"
echo "Please update it with your actual service URLs before using."



