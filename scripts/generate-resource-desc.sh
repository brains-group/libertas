#!/bin/bash

# Script to generate a resource description template
# Usage: ./scripts/generate-resource-desc.sh [output-file]

set -e

OUTPUT_FILE="${1:-resource-description.ttl}"

cat > "$OUTPUT_FILE" << 'EOF'
@prefix : <urn:solid:mpc#>.

# Libertas Resource Description Document
# Generated: $(date)
#
# Instructions:
# 1. Replace the example URIs with your actual data provider information
# 2. Add more :source entries for additional data providers
# 3. Each :MPCSource must have:
#    - :pref: URL to the Preference Document
#    - :data: URL to the actual data resource
# 4. Use this file when configuring the MPC App

:sources a :MPCSourceSpec;
  :source :src1, :src2.

:src1 a :MPCSource;
  :pref <https://pod.example.com/alice/preferences.ttl>;
  :data <https://pod.example.com/alice/data.csv>.

:src2 a :MPCSource;
  :pref <https://pod.example.com/bob/preferences.ttl>;
  :data <https://pod.example.com/bob/data.csv>.
EOF

# Replace the date placeholder
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s/\$(date)/$(date)/" "$OUTPUT_FILE"
else
    sed -i "s/\$(date)/$(date)/" "$OUTPUT_FILE"
fi

echo "Resource description generated: $OUTPUT_FILE"
echo "Please update it with your actual data provider information before using."



