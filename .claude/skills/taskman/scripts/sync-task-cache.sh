#!/usr/bin/env bash
#
# sync-task-cache.sh - Sync Vikunja tasks to local SQLite cache
#
# This script fetches all tasks, projects, and labels from Vikunja API
# and builds a local SQLite database for fast querying by TaskMan skill.
#

set -euo pipefail

# Configuration - read from ~/.claude.json MCP config, with env var fallback
VIKUNJA_TOKEN="${VIKUNJA_API_TOKEN:-$(jq -r '.mcpServers.vikunja.env.VIKUNJA_API_TOKEN // empty' ~/.claude.json 2>/dev/null)}"
VIKUNJA_URL="${VIKUNJA_URL:-$(jq -r '.mcpServers.vikunja.env.VIKUNJA_URL // empty' ~/.claude.json 2>/dev/null)}"
DB_PATH="${HOME}/.claude/skills/taskman/data/taskman.db"
LOG_PATH="${HOME}/.claude/skills/taskman/data/sync.log"
TEMP_DB="${DB_PATH}.tmp"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$LOG_PATH"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOG_PATH"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1" | tee -a "$LOG_PATH"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_PATH"
}

# Check dependencies
check_dependencies() {
    local missing=()

    command -v curl >/dev/null 2>&1 || missing+=("curl")
    command -v jq >/dev/null 2>&1 || missing+=("jq")
    command -v sqlite3 >/dev/null 2>&1 || missing+=("sqlite3")

    if [ ${#missing[@]} -gt 0 ]; then
        log_error "Missing required dependencies: ${missing[*]}"
        log_error "Install with: apt install ${missing[*]}"
        exit 1
    fi
}

# Validate API token
check_token() {
    if [ -z "$VIKUNJA_TOKEN" ]; then
        log_error "VIKUNJA_API_TOKEN not found"
        log_error "Please set it in ~/.claude.json under mcpServers.vikunja.env.VIKUNJA_API_TOKEN"
        log_error "Or export VIKUNJA_API_TOKEN environment variable"
        exit 1
    fi
}

# API request helper
api_request() {
    local endpoint="$1"
    local response
    local http_code

    response=$(curl -s -w "\n%{http_code}" \
        -H "Authorization: Bearer $VIKUNJA_TOKEN" \
        -H "Accept: application/json" \
        "${VIKUNJA_URL}${endpoint}")

    http_code=$(echo "$response" | tail -n1)
    response=$(echo "$response" | sed '$d')

    if [ "$http_code" != "200" ]; then
        log_error "API request failed: ${endpoint} (HTTP ${http_code})"
        echo "$response" | jq '.' 2>/dev/null || echo "$response"
        return 1
    fi

    echo "$response"
}

# Initialize database schema
init_database() {
    log_info "Initializing database schema..."

    sqlite3 "$TEMP_DB" <<'EOF'
-- Metadata table
CREATE TABLE IF NOT EXISTS cache_metadata (
    key TEXT PRIMARY KEY,
    value TEXT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Projects table
CREATE TABLE IF NOT EXISTS projects (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    parent_id INTEGER,
    is_archived BOOLEAN DEFAULT 0
);

-- Tasks table
CREATE TABLE IF NOT EXISTS tasks (
    id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    project_id INTEGER,
    project_name TEXT,
    due_date TEXT,
    priority INTEGER,
    done BOOLEAN,
    parent_task_id INTEGER,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

-- Labels table
CREATE TABLE IF NOT EXISTS labels (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    hex_color TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Task labels (many-to-many)
CREATE TABLE IF NOT EXISTS task_labels (
    task_id INTEGER,
    label_id INTEGER,
    PRIMARY KEY (task_id, label_id),
    FOREIGN KEY (task_id) REFERENCES tasks(id),
    FOREIGN KEY (label_id) REFERENCES labels(id)
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_tasks_project ON tasks(project_id);
CREATE INDEX IF NOT EXISTS idx_tasks_done ON tasks(done);
CREATE INDEX IF NOT EXISTS idx_tasks_due_date ON tasks(due_date);
CREATE INDEX IF NOT EXISTS idx_tasks_priority ON tasks(priority);
CREATE INDEX IF NOT EXISTS idx_tasks_parent ON tasks(parent_task_id);
CREATE INDEX IF NOT EXISTS idx_labels_name ON labels(name);
CREATE INDEX IF NOT EXISTS idx_task_labels_task ON task_labels(task_id);
CREATE INDEX IF NOT EXISTS idx_task_labels_label ON task_labels(label_id);
EOF

    log_success "Database schema initialized"
}

# Fetch and insert projects
sync_projects() {
    log_info "Fetching projects..."

    local projects_json
    projects_json=$(api_request "/projects") || return 1

    local project_count
    project_count=$(echo "$projects_json" | jq '. | length')

    log_info "Found $project_count projects"

    # Insert projects into database
    echo "$projects_json" | jq -r '.[] | [.id, .title, (.parent_project_id // "NULL"), (.is_archived // false)] | @tsv' | \
    while IFS=$'\t' read -r id title parent_id is_archived; do
        # Escape single quotes in title
        title=$(echo "$title" | sed "s/'/''/g")

        if [ "$parent_id" = "NULL" ]; then
            parent_id="NULL"
        fi

        sqlite3 "$TEMP_DB" "INSERT INTO projects (id, name, parent_id, is_archived) VALUES ($id, '$title', $parent_id, $is_archived);"
    done

    log_success "Synced $project_count projects"
    return 0
}

# Fetch and insert labels
sync_labels() {
    log_info "Fetching labels..."

    local labels_json
    labels_json=$(api_request "/labels") || return 1

    local label_count
    label_count=$(echo "$labels_json" | jq '. | length')

    log_info "Found $label_count labels"

    # Insert labels into database
    echo "$labels_json" | jq -r '.[] | [.id, .title, (.description // ""), (.hex_color // "")] | @tsv' | \
    while IFS=$'\t' read -r id title description hex_color; do
        # Escape single quotes
        title=$(echo "$title" | sed "s/'/''/g")
        description=$(echo "$description" | sed "s/'/''/g")

        sqlite3 "$TEMP_DB" "INSERT OR REPLACE INTO labels (id, name, description, hex_color)
                           VALUES ($id, '$title', '$description', '$hex_color');"
    done

    log_success "Synced $label_count labels"
    return 0
}

# Fetch and insert tasks (with pagination)
sync_tasks() {
    log_info "Fetching tasks..."

    local page=1
    local total_tasks=0
    local per_page=50

    while true; do
        log_info "Fetching page $page..."

        local tasks_json
        tasks_json=$(api_request "/tasks/all?page=$page&per_page=$per_page") || return 1

        local page_count
        page_count=$(echo "$tasks_json" | jq '. | length')

        if [ "$page_count" -eq 0 ]; then
            log_info "No more tasks to fetch"
            break
        fi

        # Process each task
        echo "$tasks_json" | jq -c '.[]' | while read -r task; do
            local id title project_id due_date priority done parent_task_id created_at updated_at

            id=$(echo "$task" | jq -r '.id')
            title=$(echo "$task" | jq -r '.title' | sed "s/'/''/g")
            project_id=$(echo "$task" | jq -r '.project_id // "NULL"')
            due_date=$(echo "$task" | jq -r '.due_date // "NULL"' | sed 's/T.*//')
            priority=$(echo "$task" | jq -r '.priority // 0')
            done=$(echo "$task" | jq -r '.done // false')
            parent_task_id=$(echo "$task" | jq -r '.parent_task_id // "NULL"')
            created_at=$(echo "$task" | jq -r '.created')
            updated_at=$(echo "$task" | jq -r '.updated')

            # Get project name if we have project_id
            local project_name="NULL"
            if [ "$project_id" != "NULL" ]; then
                project_name=$(sqlite3 "$TEMP_DB" "SELECT name FROM projects WHERE id = $project_id;" | sed "s/'/''/g")
                if [ -n "$project_name" ]; then
                    project_name="'$project_name'"
                else
                    project_name="NULL"
                fi
            fi

            # Convert boolean
            [ "$done" = "true" ] && done=1 || done=0

            # Handle NULL values
            [ "$due_date" = "NULL" ] && due_date="NULL" || due_date="'$due_date'"
            [ "$parent_task_id" = "NULL" ] && parent_task_id="NULL"

            # Insert task
            sqlite3 "$TEMP_DB" "INSERT INTO tasks (id, title, project_id, project_name, due_date, priority, done, parent_task_id, created_at, updated_at)
                VALUES ($id, '$title', $project_id, $project_name, $due_date, $priority, $done, $parent_task_id, '$created_at', '$updated_at');" || log_warn "Failed to insert task $id"

            # Insert task labels (using label_id)
            echo "$task" | jq -r '.labels[]?.id // empty' | while read -r label_id; do
                if [ -n "$label_id" ]; then
                    sqlite3 "$TEMP_DB" "INSERT OR IGNORE INTO task_labels (task_id, label_id) VALUES ($id, $label_id);"
                fi
            done
        done

        total_tasks=$((total_tasks + page_count))
        log_info "Processed $page_count tasks from page $page (total: $total_tasks)"

        # Check if we should continue
        if [ "$page_count" -lt "$per_page" ]; then
            break
        fi

        page=$((page + 1))
    done

    log_success "Synced $total_tasks tasks"
    return 0
}

# Update metadata
update_metadata() {
    log_info "Updating cache metadata..."

    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    sqlite3 "$TEMP_DB" "INSERT OR REPLACE INTO cache_metadata (key, value, updated_at) VALUES ('last_sync', '$timestamp', CURRENT_TIMESTAMP);"

    # Store statistics
    local task_count active_count
    task_count=$(sqlite3 "$TEMP_DB" "SELECT COUNT(*) FROM tasks;")
    active_count=$(sqlite3 "$TEMP_DB" "SELECT COUNT(*) FROM tasks WHERE done = 0;")

    sqlite3 "$TEMP_DB" "INSERT OR REPLACE INTO cache_metadata (key, value) VALUES ('total_tasks', '$task_count');"
    sqlite3 "$TEMP_DB" "INSERT OR REPLACE INTO cache_metadata (key, value) VALUES ('active_tasks', '$active_count');"

    log_success "Metadata updated"
}

# Main sync function
main() {
    local start_time
    start_time=$(date +%s)

    log_info "========================================="
    log_info "TaskMan Cache Sync Starting"
    log_info "Time: $(date)"
    log_info "========================================="

    # Check dependencies
    check_dependencies

    # Check API token
    check_token

    # Create temp database
    rm -f "$TEMP_DB"

    # Initialize schema
    init_database || { log_error "Failed to initialize database"; exit 1; }

    # Sync data
    sync_projects || { log_error "Failed to sync projects"; exit 1; }
    sync_labels || { log_error "Failed to sync labels"; exit 1; }
    sync_tasks || { log_error "Failed to sync tasks"; exit 1; }

    # Update metadata
    update_metadata

    # Move temp database to final location (atomic operation)
    mv "$TEMP_DB" "$DB_PATH"

    local end_time
    end_time=$(date +%s)
    local duration=$((end_time - start_time))

    # Get statistics
    local total_tasks active_tasks project_count
    total_tasks=$(sqlite3 "$DB_PATH" "SELECT COUNT(*) FROM tasks;")
    active_tasks=$(sqlite3 "$DB_PATH" "SELECT COUNT(*) FROM tasks WHERE done = 0;")
    project_count=$(sqlite3 "$DB_PATH" "SELECT COUNT(*) FROM projects;")

    log_success "========================================="
    log_success "TaskMan Cache Sync Complete!"
    log_success "Duration: ${duration}s"
    log_success "Projects: $project_count"
    log_success "Tasks: $total_tasks ($active_tasks active)"
    log_success "Cache: $DB_PATH"
    log_success "========================================="
}

# Run main function
main "$@"
