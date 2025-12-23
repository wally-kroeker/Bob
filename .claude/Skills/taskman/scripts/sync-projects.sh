#!/bin/bash
# Sync project hierarchy from Vikunja to local data file
# This is the ONLY script in TaskMan - everything else is AI-native reasoning

VIKUNJA_API="https://taskman.vrexplorers.com/api/v1"
AUTH_TOKEN="${VIKUNJA_API_TOKEN}"
OUTPUT_FILE="${HOME}/.claude/skills/taskman/data/project-hierarchy.md"

# Check for API token
if [ -z "$AUTH_TOKEN" ]; then
    echo "Error: VIKUNJA_API_TOKEN environment variable not set"
    echo "Set it with: export VIKUNJA_API_TOKEN='your-token'"
    exit 1
fi

# Fetch all projects from Vikunja
echo "Fetching projects from Vikunja..."
RESPONSE=$(curl -s -H "Authorization: Bearer ${AUTH_TOKEN}" "${VIKUNJA_API}/projects")

if [ $? -ne 0 ]; then
    echo "Error: Failed to fetch projects from Vikunja"
    exit 1
fi

# Parse JSON and build hierarchy (using jq if available, otherwise basic parsing)
if command -v jq &> /dev/null; then
    # Use jq for clean parsing
    echo "# Vikunja Project Hierarchy" > "$OUTPUT_FILE"
    echo "Last synced: $(date '+%Y-%m-%d %H:%M:%S')" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    echo "## Root Projects" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"

    # Extract root projects (parent_project_id = 0)
    echo "$RESPONSE" | jq -r '.projects[] | select(.parent_project_id == 0) | "### \(.title) (id: \(.id), parent: 0)"' >> "$OUTPUT_FILE"

    # For each root, extract children
    ROOT_IDS=$(echo "$RESPONSE" | jq -r '.projects[] | select(.parent_project_id == 0) | .id')

    for root_id in $ROOT_IDS; do
        CHILDREN=$(echo "$RESPONSE" | jq -r ".projects[] | select(.parent_project_id == $root_id) | \"- \(.title) (id: \(.id), parent: $root_id)\"")
        if [ ! -z "$CHILDREN" ]; then
            echo "$CHILDREN" >> "$OUTPUT_FILE"
        fi
        echo "" >> "$OUTPUT_FILE"
    done

    echo "---" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    echo "## Sync Instructions" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    echo "Run: \`~/.claude/skills/taskman/scripts/sync-projects.sh\`" >> "$OUTPUT_FILE"
    echo "to update this file from Vikunja API" >> "$OUTPUT_FILE"

    echo "✓ Project hierarchy synced successfully!"
    echo "  Output: $OUTPUT_FILE"

else
    echo "Warning: jq not installed - using basic parsing"
    echo "Install jq for better formatting: sudo apt-get install jq"

    # Basic fallback without jq
    echo "# Vikunja Project Hierarchy" > "$OUTPUT_FILE"
    echo "Last synced: $(date '+%Y-%m-%d %H:%M:%S')" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    echo "## Projects (Raw Data)" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    echo "$RESPONSE" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    echo "Note: Install jq for formatted output" >> "$OUTPUT_FILE"

    echo "✓ Project data saved (install jq for better formatting)"
    echo "  Output: $OUTPUT_FILE"
fi
