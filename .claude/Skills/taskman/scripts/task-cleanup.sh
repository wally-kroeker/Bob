#!/usr/bin/env bash
#
# task-cleanup.sh - TaskMan v2.0 Migration Utilities
#
# Collection of utilities for cleaning up and managing the v2.0 migration.
#
# Usage:
#   ./task-cleanup.sh move-archive       # Move AI tasks to Archive project
#   ./task-cleanup.sh delete-labels      # Delete deprecated labels (ai-parent, ai-subtask)
#   ./task-cleanup.sh verify             # Verify migration completed successfully
#   ./task-cleanup.sh stats              # Show migration statistics

set -euo pipefail

# Configuration - read from ~/.claude.json MCP config, with env var fallback
VIKUNJA_TOKEN="${VIKUNJA_API_TOKEN:-$(jq -r '.mcpServers.vikunja.env.VIKUNJA_API_TOKEN // empty' ~/.claude.json 2>/dev/null)}"
VIKUNJA_URL="${VIKUNJA_URL:-$(jq -r '.mcpServers.vikunja.env.VIKUNJA_URL // empty' ~/.claude.json 2>/dev/null)}"
ARCHIVE_PROJECT_ID=17
DB_PATH="${HOME}/.claude/skills/taskman/data/taskman.db"

# Task IDs to archive (from export)
TASK_IDS=(211 212 213 214 215 216 217 218 219 260 261 262 263 264 265 267 268 269 270 271 272 273 282 283 284 285 286 287 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383 384 385 386 387 388 389 390 391 392 393 394 396 397 398 399 400 401 402 403 404 405 406 407 408 409 411 412 413 414 415 417 418 419 420 421 422 423 427 428 429 430 431 432 433 434 435 436 437 438 439 440)

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Logging
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check API token
check_token() {
    if [ -z "$VIKUNJA_TOKEN" ]; then
        log_error "VIKUNJA_API_TOKEN not found"
        log_error "Please set it in ~/.claude.json or export VIKUNJA_API_TOKEN"
        exit 1
    fi
}

# API request helper
api_request() {
    local method="${1:-GET}"
    local endpoint="$2"
    local data="${3:-}"

    local curl_args=(
        -s -w "\n%{http_code}"
        -X "$method"
        -H "Authorization: Bearer $VIKUNJA_TOKEN"
        -H "Content-Type: application/json"
    )

    [ -n "$data" ] && curl_args+=(-d "$data")

    local response
    response=$(curl "${curl_args[@]}" "${VIKUNJA_URL}${endpoint}")

    local http_code
    http_code=$(echo "$response" | tail -n1)
    response=$(echo "$response" | sed '$d')

    if [[ ! "$http_code" =~ ^2[0-9]{2}$ ]]; then
        log_error "API request failed: ${method} ${endpoint} (HTTP ${http_code})"
        echo "$response" | jq '.' 2>/dev/null || echo "$response"
        return 1
    fi

    echo "$response"
}

# Move tasks to Archive project
move_archive() {
    log_info "Moving ${#TASK_IDS[@]} tasks to Archive (Project ID: $ARCHIVE_PROJECT_ID)"
    echo ""

    local moved=0
    local failed=0
    local not_found=0

    for task_id in "${TASK_IDS[@]}"; do
        # Move task to archive project
        response=$(api_request "PUT" "/tasks/$task_id" "{\"project_id\": $ARCHIVE_PROJECT_ID}" 2>&1)

        if echo "$response" | grep -q "\"id\":$task_id"; then
            ((moved++))
            if [ $((moved % 10)) -eq 0 ]; then
                log_info "Moved $moved tasks..."
            fi
        elif echo "$response" | grep -q "404"; then
            ((not_found++))
        else
            ((failed++))
            log_error "Failed to move task $task_id"
        fi
    done

    echo ""
    log_success "Migration complete!"
    log_success "Successfully moved: $moved tasks"
    [ $not_found -gt 0 ] && log_warn "Already deleted: $not_found tasks"
    [ $failed -gt 0 ] && log_error "Failed: $failed tasks"
}

# Delete deprecated labels
delete_labels() {
    log_info "Finding deprecated labels (ai-parent, ai-subtask)..."

    # Get all labels
    labels=$(api_request "GET" "/labels")

    # Find ai-parent and ai-subtask label IDs
    ai_parent_id=$(echo "$labels" | jq -r '.[] | select(.title == "ai-parent") | .id // empty')
    ai_subtask_id=$(echo "$labels" | jq -r '.[] | select(.title == "ai-subtask") | .id // empty')

    local deleted=0

    if [ -n "$ai_parent_id" ]; then
        log_info "Deleting label: ai-parent (ID: $ai_parent_id)"
        api_request "DELETE" "/labels/$ai_parent_id" > /dev/null && ((deleted++))
    fi

    if [ -n "$ai_subtask_id" ]; then
        log_info "Deleting label: ai-subtask (ID: $ai_subtask_id)"
        api_request "DELETE" "/labels/$ai_subtask_id" > /dev/null && ((deleted++))
    fi

    if [ $deleted -eq 0 ]; then
        log_warn "No deprecated labels found (already deleted?)"
    else
        log_success "Deleted $deleted deprecated labels"
    fi
}

# Verify migration
verify_migration() {
    log_info "Verifying TaskMan v2.0 migration..."
    echo ""

    # Check Archive project exists
    projects=$(api_request "GET" "/projects")
    archive_exists=$(echo "$projects" | jq -r ".[] | select(.id == $ARCHIVE_PROJECT_ID) | .id // empty")

    if [ -z "$archive_exists" ]; then
        log_error "Archive project (ID: $ARCHIVE_PROJECT_ID) not found!"
    else
        log_success "✓ Archive project exists (ID: $ARCHIVE_PROJECT_ID)"
    fi

    # Check TimeEstimate labels exist
    labels=$(api_request "GET" "/labels")
    label_5min=$(echo "$labels" | jq -r '.[] | select(.title == "5min") | .id // empty')
    label_15min=$(echo "$labels" | jq -r '.[] | select(.title == "15min") | .id // empty')
    label_30min=$(echo "$labels" | jq -r '.[] | select(.title == "30min") | .id // empty')
    label_60min=$(echo "$labels" | jq -r '.[] | select(.title == "60min+") | .id // empty')

    if [ -n "$label_5min" ] && [ -n "$label_15min" ] && [ -n "$label_30min" ] && [ -n "$label_60min" ]; then
        log_success "✓ TimeEstimate labels exist (IDs: $label_5min, $label_15min, $label_30min, $label_60min)"
    else
        log_error "TimeEstimate labels incomplete!"
    fi

    # Check deprecated labels are gone
    ai_parent=$(echo "$labels" | jq -r '.[] | select(.title == "ai-parent") | .id // empty')
    ai_subtask=$(echo "$labels" | jq -r '.[] | select(.title == "ai-subtask") | .id // empty')

    if [ -z "$ai_parent" ] && [ -z "$ai_subtask" ]; then
        log_success "✓ Deprecated labels removed"
    else
        log_warn "Deprecated labels still exist (run: task-cleanup.sh delete-labels)"
    fi

    # Check local cache
    if [ -f "$DB_PATH" ]; then
        log_success "✓ Local cache exists: $DB_PATH"

        # Check cache metadata
        last_sync=$(sqlite3 "$DB_PATH" "SELECT value FROM cache_metadata WHERE key = 'last_sync';" 2>/dev/null || echo "")
        if [ -n "$last_sync" ]; then
            log_success "✓ Cache last synced: $last_sync"
        else
            log_warn "Cache metadata missing (run: /taskman-refresh)"
        fi
    else
        log_error "Local cache not found: $DB_PATH"
        log_info "Run: ~/.claude/skills/taskman/scripts/sync-task-cache.sh"
    fi

    echo ""
    log_info "Verification complete!"
}

# Show statistics
show_stats() {
    log_info "TaskMan v2.0 Statistics"
    echo ""

    # Projects
    projects=$(api_request "GET" "/projects")
    project_count=$(echo "$projects" | jq '. | length')
    log_info "Projects: $project_count"

    # Tasks in Archive
    archive_tasks=$(api_request "GET" "/projects/$ARCHIVE_PROJECT_ID/tasks")
    archive_count=$(echo "$archive_tasks" | jq '. | length')
    log_info "Tasks in Archive: $archive_count"

    # Labels
    labels=$(api_request "GET" "/labels")
    label_count=$(echo "$labels" | jq '. | length')
    log_info "Labels: $label_count"

    # TimeEstimate label counts
    echo ""
    log_info "TimeEstimate Label Usage:"

    for label_name in "5min" "15min" "30min" "60min+"; do
        label_id=$(echo "$labels" | jq -r ".[] | select(.title == \"$label_name\") | .id // empty")
        if [ -n "$label_id" ]; then
            # This is a rough count - actual task counting would require iterating all tasks
            echo "  - $label_name (ID: $label_id)"
        fi
    done

    echo ""
}

# Main function
main() {
    local command="${1:-help}"

    case "$command" in
        move-archive)
            check_token
            move_archive
            ;;
        delete-labels)
            check_token
            delete_labels
            ;;
        verify)
            check_token
            verify_migration
            ;;
        stats)
            check_token
            show_stats
            ;;
        help|*)
            echo -e "\n${CYAN}TaskMan v2.0 Migration Utilities${NC}"
            echo ""
            echo "Usage:"
            echo "  task-cleanup.sh move-archive    # Move 175 AI tasks to Archive project"
            echo "  task-cleanup.sh delete-labels   # Delete deprecated labels (ai-parent, ai-subtask)"
            echo "  task-cleanup.sh verify          # Verify migration completed successfully"
            echo "  task-cleanup.sh stats           # Show migration statistics"
            echo ""
            echo "Recommended order:"
            echo "  1. task-cleanup.sh move-archive"
            echo "  2. task-cleanup.sh delete-labels"
            echo "  3. task-cleanup.sh verify"
            echo ""
            exit 0
            ;;
    esac
}

main "$@"
