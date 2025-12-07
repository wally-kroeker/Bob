#!/usr/bin/env bash
#
# taskman-query.sh - Query helper for TaskMan SQLite cache
#
# Provides convenient access to common TaskMan queries
#

set -euo pipefail

DB_PATH="${HOME}/.claude/skills/taskman/data/taskman.db"

# Check if database exists
check_db() {
    if [ ! -f "$DB_PATH" ]; then
        echo "Error: TaskMan cache not found at $DB_PATH"
        echo "Run /taskman-refresh to create the cache"
        exit 1
    fi
}

# Show usage
usage() {
    cat <<EOF
TaskMan Query Helper

Usage: taskman-query.sh <command> [args]

Commands:
  sql <query>              Execute raw SQL query
  stats                    Show cache statistics
  next-tasks [limit]       Show next tasks to work on (default: 10)
  workload-this-week       Show tasks due this week by project
  project <name>           Show tasks for a specific project
  by-label <label>         Show tasks with a specific label
  due-soon [days]          Show tasks due in next N days (default: 3)
  high-priority            Show high-priority tasks (priority >= 4)
  parents                  Show parent tasks with subtasks
  cache-age                Show how old the cache is

Examples:
  taskman-query.sh next-tasks 5
  taskman-query.sh project "Personal"
  taskman-query.sh by-label "Work"
  taskman-query.sh sql "SELECT * FROM tasks WHERE priority = 5"

EOF
    exit 1
}

# Execute SQL query
sql_query() {
    check_db
    local query="$1"
    sqlite3 "$DB_PATH" "$query"
}

# Show statistics
show_stats() {
    check_db
    cat <<EOF
=== TaskMan Cache Statistics ===

$(sql_query "SELECT 'Last Sync: ' || value FROM cache_metadata WHERE key = 'last_sync';")
$(sql_query "SELECT 'Total Tasks: ' || COUNT(*) FROM tasks;")
$(sql_query "SELECT 'Active Tasks: ' || COUNT(*) FROM tasks WHERE done = 0;")
$(sql_query "SELECT 'Completed Tasks: ' || COUNT(*) FROM tasks WHERE done = 1;")
$(sql_query "SELECT 'Projects: ' || COUNT(*) FROM projects;")
$(sql_query "SELECT 'Parent Tasks: ' || COUNT(*) FROM tasks WHERE parent_task_id IS NULL AND done = 0;")

=== Tasks by Priority ===
$(sql_query "SELECT 'Priority ' || priority || ': ' || COUNT(*) FROM tasks WHERE done = 0 GROUP BY priority ORDER BY priority DESC;")

=== Tasks by Project (Top 5) ===
$(sql_query "SELECT project_name || ': ' || COUNT(*) FROM tasks WHERE done = 0 AND project_name IS NOT NULL GROUP BY project_name ORDER BY COUNT(*) DESC LIMIT 5;")

EOF
}

# Show next tasks to work on
next_tasks() {
    check_db
    local limit="${1:-10}"

    echo "=== Next Tasks to Work On ==="
    echo

    sql_query "
SELECT
    '#' || id || ' ' || title ||
    CASE
        WHEN project_name IS NOT NULL THEN ' [' || project_name || ']'
        ELSE ''
    END ||
    ' (P' || priority || ')' ||
    CASE
        WHEN due_date IS NOT NULL THEN ' - Due: ' || due_date
        ELSE ''
    END
FROM tasks
WHERE done = 0
  AND parent_task_id IS NULL
ORDER BY
  CASE
    WHEN due_date IS NOT NULL AND due_date <= date('now', '+3 days') THEN 0
    ELSE 1
  END,
  priority DESC,
  due_date ASC
LIMIT $limit;
"
}

# Show workload for this week
workload_this_week() {
    check_db

    echo "=== Workload This Week ==="
    echo

    sql_query "
SELECT
    project_name || ': ' || COUNT(*) || ' tasks (' ||
    SUM(CASE WHEN priority >= 4 THEN 1 ELSE 0 END) || ' high priority)'
FROM tasks
WHERE done = 0
  AND due_date BETWEEN date('now') AND date('now', '+7 days')
  AND project_name IS NOT NULL
GROUP BY project_name
ORDER BY SUM(CASE WHEN priority >= 4 THEN 1 ELSE 0 END) DESC, COUNT(*) DESC;
"

    echo
    echo "Total: $(sql_query "SELECT COUNT(*) FROM tasks WHERE done = 0 AND due_date BETWEEN date('now') AND date('now', '+7 days');")" tasks this week
}

# Show tasks for a specific project
project_tasks() {
    check_db
    local project_name="$1"

    echo "=== Tasks for Project: $project_name ==="
    echo

    sql_query "
SELECT
    '#' || id || ' ' || title ||
    ' (P' || priority || ')' ||
    CASE
        WHEN due_date IS NOT NULL THEN ' - Due: ' || due_date
        ELSE ''
    END
FROM tasks
WHERE done = 0
  AND project_name = '$project_name'
ORDER BY priority DESC, due_date ASC;
"
}

# Show tasks by label
tasks_by_label() {
    check_db
    local label="$1"

    echo "=== Tasks with Label: $label ==="
    echo

    sql_query "
SELECT
    '#' || t.id || ' ' || t.title ||
    CASE
        WHEN t.project_name IS NOT NULL THEN ' [' || t.project_name || ']'
        ELSE ''
    END ||
    ' (P' || t.priority || ')' ||
    CASE
        WHEN t.due_date IS NOT NULL THEN ' - Due: ' || t.due_date
        ELSE ''
    END
FROM tasks t
JOIN task_labels tl ON t.id = tl.task_id
WHERE tl.label_name = '$label'
  AND t.done = 0
ORDER BY t.priority DESC, t.due_date ASC;
"
}

# Show tasks due soon
due_soon() {
    check_db
    local days="${1:-3}"

    echo "=== Tasks Due in Next $days Days ==="
    echo

    sql_query "
SELECT
    '#' || id || ' ' || title ||
    CASE
        WHEN project_name IS NOT NULL THEN ' [' || project_name || ']'
        ELSE ''
    END ||
    ' (P' || priority || ')' ||
    ' - Due: ' || due_date
FROM tasks
WHERE done = 0
  AND due_date BETWEEN date('now') AND date('now', '+$days days')
ORDER BY due_date ASC, priority DESC;
"
}

# Show high-priority tasks
high_priority() {
    check_db

    echo "=== High Priority Tasks (Priority >= 4) ==="
    echo

    sql_query "
SELECT
    '#' || id || ' ' || title ||
    CASE
        WHEN project_name IS NOT NULL THEN ' [' || project_name || ']'
        ELSE ''
    END ||
    ' (P' || priority || ')' ||
    CASE
        WHEN due_date IS NOT NULL THEN ' - Due: ' || due_date
        ELSE ''
    END
FROM tasks
WHERE done = 0
  AND priority >= 4
ORDER BY priority DESC, due_date ASC;
"
}

# Show parent tasks
parent_tasks() {
    check_db

    echo "=== Parent Tasks with Subtasks ==="
    echo

    sql_query "
SELECT
    '#' || t.id || ' ' || t.title ||
    CASE
        WHEN t.project_name IS NOT NULL THEN ' [' || t.project_name || ']'
        ELSE ''
    END ||
    ' (P' || t.priority || ')' ||
    ' - ' || (SELECT COUNT(*) FROM tasks WHERE parent_task_id = t.id) || ' subtasks'
FROM tasks t
WHERE t.done = 0
  AND t.parent_task_id IS NULL
  AND EXISTS (SELECT 1 FROM tasks WHERE parent_task_id = t.id)
ORDER BY t.priority DESC;
"
}

# Show cache age
cache_age() {
    check_db

    local last_sync
    last_sync=$(sql_query "SELECT value FROM cache_metadata WHERE key = 'last_sync';")

    if [ -z "$last_sync" ]; then
        echo "Cache has never been synced"
        return
    fi

    echo "Last sync: $last_sync"

    # Calculate age in seconds (simplified - just show the timestamp)
    # A proper age calculation would require date parsing, keeping it simple for now
    echo
    echo "To refresh: /taskman-refresh"
}

# Main command dispatcher
main() {
    if [ $# -eq 0 ]; then
        usage
    fi

    local command="$1"
    shift

    case "$command" in
        sql)
            [ $# -eq 0 ] && { echo "Error: SQL query required"; exit 1; }
            sql_query "$*"
            ;;
        stats)
            show_stats
            ;;
        next-tasks)
            next_tasks "$@"
            ;;
        workload-this-week)
            workload_this_week
            ;;
        project)
            [ $# -eq 0 ] && { echo "Error: Project name required"; exit 1; }
            project_tasks "$1"
            ;;
        by-label)
            [ $# -eq 0 ] && { echo "Error: Label name required"; exit 1; }
            tasks_by_label "$1"
            ;;
        due-soon)
            due_soon "$@"
            ;;
        high-priority)
            high_priority
            ;;
        parents)
            parent_tasks
            ;;
        cache-age)
            cache_age
            ;;
        help|--help|-h)
            usage
            ;;
        *)
            echo "Error: Unknown command '$command'"
            echo
            usage
            ;;
    esac
}

main "$@"
