#!/usr/bin/env bash
#
# taskman-query.sh - Time-constrained task queries for ADHD support
#
# TaskMan v2.0 script for querying tasks by time estimate and context.
# Uses local SQLite cache for fast filtering.
#
# Usage:
#   ./taskman-query.sh quick              # 5-15 min tasks
#   ./taskman-query.sh phone [minutes]    # Phone tasks with time filter
#   ./taskman-query.sh desk [minutes]     # Computer tasks with time filter
#   ./taskman-query.sh wins               # Quick wins (5 min only)
#   ./taskman-query.sh custom <query>     # Custom SQL query

set -euo pipefail

# Configuration
DB_PATH="${HOME}/.claude/skills/taskman/data/taskman.db"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
NC='\033[0m'

# Check if database exists
check_database() {
    if [ ! -f "$DB_PATH" ]; then
        echo -e "${YELLOW}TaskMan cache not found. Run sync-task-cache.sh first.${NC}"
        exit 1
    fi
}

# Format task output
format_task() {
    local id="$1"
    local title="$2"
    local project="$3"
    local priority="$4"
    local due_date="$5"

    local priority_marker=""
    case $priority in
        5) priority_marker="${GREEN}!!!" ;;
        4) priority_marker="${GREEN}!!" ;;
        3) priority_marker="${YELLOW}!" ;;
        *) priority_marker="${GRAY}-" ;;
    esac

    local due_marker=""
    if [ "$due_date" != "" ]; then
        due_marker="${CYAN}📅 $due_date${NC}"
    fi

    echo -e "${priority_marker}${NC} [${BLUE}$id${NC}] $title ${GRAY}($project)${NC} $due_marker"
}

# Query: Quick tasks (5-15 min)
query_quick() {
    echo -e "\n${CYAN}Quick Tasks (5-15 minutes):${NC}\n"

    sqlite3 "$DB_PATH" -separator '|' <<'EOF'
SELECT DISTINCT t.id, t.title, t.project_name, t.priority, COALESCE(t.due_date, '')
FROM tasks t
JOIN task_labels tl ON t.id = tl.task_id
JOIN labels l ON tl.label_id = l.id
WHERE t.done = 0 AND l.name IN ('5min', '15min')
ORDER BY t.priority DESC, t.due_date ASC
LIMIT 10;
EOF
}

# Query: Phone tasks with time filter
query_phone() {
    local minutes="${1:-10}"

    echo -e "\n${CYAN}Phone Tasks ($minutes min or less):${NC}\n"

    local time_labels="'5min'"
    [ "$minutes" -ge 15 ] && time_labels="'5min', '15min'"
    [ "$minutes" -ge 30 ] && time_labels="'5min', '15min', '30min'"

    sqlite3 "$DB_PATH" -separator '|' <<EOF
SELECT DISTINCT t.id, t.title, t.project_name, t.priority, COALESCE(t.due_date, '')
FROM tasks t
JOIN task_labels tl1 ON t.id = tl1.task_id
JOIN labels l1 ON tl1.label_id = l1.id AND l1.name = 'Phone'
JOIN task_labels tl2 ON t.id = tl2.task_id
JOIN labels l2 ON tl2.label_id = l2.id AND l2.name IN ($time_labels)
WHERE t.done = 0
ORDER BY t.priority DESC, t.due_date ASC
LIMIT 10;
EOF
}

# Query: Computer/desk tasks with time filter
query_desk() {
    local minutes="${1:-30}"

    echo -e "\n${CYAN}Desk Tasks ($minutes min or less):${NC}\n"

    local time_labels="'5min'"
    [ "$minutes" -ge 15 ] && time_labels="'5min', '15min'"
    [ "$minutes" -ge 30 ] && time_labels="'5min', '15min', '30min'"
    [ "$minutes" -ge 60 ] && time_labels="'5min', '15min', '30min', '60min+'"

    sqlite3 "$DB_PATH" -separator '|' <<EOF
SELECT DISTINCT t.id, t.title, t.project_name, t.priority, COALESCE(t.due_date, '')
FROM tasks t
JOIN task_labels tl1 ON t.id = tl1.task_id
JOIN labels l1 ON tl1.label_id = l1.id AND l1.name = 'Computer'
JOIN task_labels tl2 ON t.id = tl2.task_id
JOIN labels l2 ON tl2.label_id = l2.id AND l2.name IN ($time_labels)
WHERE t.done = 0
ORDER BY t.priority DESC, t.due_date ASC
LIMIT 10;
EOF
}

# Query: Quick wins (5 min only)
query_wins() {
    echo -e "\n${CYAN}Quick Wins (5 minutes):${NC}\n"

    sqlite3 "$DB_PATH" -separator '|' <<'EOF'
SELECT DISTINCT t.id, t.title, t.project_name, t.priority, COALESCE(t.due_date, '')
FROM tasks t
JOIN task_labels tl ON t.id = tl.task_id
JOIN labels l ON tl.label_id = l.id AND l.name = '5min'
WHERE t.done = 0
ORDER BY t.priority DESC
LIMIT 5;
EOF
}

# Query: Custom SQL
query_custom() {
    local query="$1"
    echo -e "\n${CYAN}Custom Query:${NC}\n"
    sqlite3 "$DB_PATH" -separator '|' "$query"
}

# Main function
main() {
    check_database

    local command="${1:-help}"
    shift || true

    case "$command" in
        quick)
            results=$(query_quick)
            ;;
        phone)
            results=$(query_phone "$@")
            ;;
        desk)
            results=$(query_desk "$@")
            ;;
        wins)
            results=$(query_wins)
            ;;
        custom)
            results=$(query_custom "$@")
            ;;
        help|*)
            echo -e "\n${CYAN}TaskMan Query Tool - v2.0${NC}"
            echo ""
            echo "Usage:"
            echo "  taskman-query.sh quick              # 5-15 min tasks"
            echo "  taskman-query.sh phone [minutes]    # Phone tasks (default: 10 min)"
            echo "  taskman-query.sh desk [minutes]     # Computer tasks (default: 30 min)"
            echo "  taskman-query.sh wins               # Quick wins (5 min only)"
            echo "  taskman-query.sh custom <query>     # Custom SQL query"
            echo ""
            echo "Examples:"
            echo "  taskman-query.sh phone 15           # Phone tasks ≤15 min"
            echo "  taskman-query.sh desk 60            # Desk tasks ≤60 min"
            echo ""
            exit 0
            ;;
    esac

    # Format and display results
    if [ -z "$results" ]; then
        echo -e "${YELLOW}No matching tasks found.${NC}"
    else
        echo "$results" | while IFS='|' read -r id title project priority due_date; do
            format_task "$id" "$title" "$project" "$priority" "$due_date"
        done
    fi

    echo ""
}

main "$@"
