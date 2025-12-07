#!/bin/bash
# Vikunja Database Query Helper
# Provides complex query capabilities beyond MCP limitations
# Uses direct PostgreSQL access for parent task filtering, multi-label queries, etc.

set -e

# Database credentials
DB_HOST="taskman"
DB_USER="vikunja"
DB_NAME="vikunja"
DB_PASSWORD="XXQat2Mlldt73NGqFmZmHrteCpySYSBWODrg6/UDdCg="

# Helper function to execute SQL query
execute_query() {
    local query="$1"
    ssh "$DB_HOST" "cd ~/vikunja-prod && docker compose exec -T -e PGPASSWORD='$DB_PASSWORD' db psql -U $DB_USER -d $DB_NAME -t -c \"$query\""
}

# Search for parent tasks (tasks that have subtasks but are not subtasks themselves)
search_parent_tasks() {
    local keyword="${1,,}"  # Convert to lowercase
    local status="${2:-active}"  # Default to active tasks

    local done_filter
    if [ "$status" = "active" ]; then
        done_filter="AND t.done = false"
    elif [ "$status" = "done" ]; then
        done_filter="AND t.done = true"
    else
        done_filter=""  # all tasks
    fi

    local query="
    SELECT
        t.id,
        t.title,
        CASE WHEN t.done THEN 'Done' ELSE 'Active' END as status,
        (SELECT COUNT(*) FROM task_relations tr WHERE tr.task_id = t.id AND tr.relation_kind = 'subtask') as subtasks
    FROM tasks t
    WHERE LOWER(t.title) LIKE '%${keyword}%'
        $done_filter
        AND NOT EXISTS (
            SELECT 1 FROM task_relations tr2
            WHERE tr2.task_id = t.id AND tr2.relation_kind = 'parenttask'
        )
        AND EXISTS (
            SELECT 1 FROM task_relations tr3
            WHERE tr3.task_id = t.id AND tr3.relation_kind = 'subtask'
        )
    ORDER BY t.id;"

    echo "=== Parent Tasks Matching '$1' ($status) ==="
    execute_query "$query" | column -t -s '|'
}

# Search by multiple labels (AND logic)
search_by_labels() {
    local label1="$1"
    local label2="$2"
    local status="${3:-active}"

    local done_filter
    if [ "$status" = "active" ]; then
        done_filter="AND t.done = false"
    elif [ "$status" = "done" ]; then
        done_filter="AND t.done = true"
    else
        done_filter=""
    fi

    local query="
    SELECT DISTINCT
        t.id,
        t.title,
        CASE WHEN t.done THEN 'Done' ELSE 'Active' END as status,
        array_agg(DISTINCT l.title) as labels
    FROM tasks t
    JOIN label_tasks lt1 ON t.id = lt1.task_id
    JOIN labels l1 ON lt1.label_id = l1.id
    JOIN label_tasks lt2 ON t.id = lt2.task_id
    JOIN labels l2 ON lt2.label_id = l2.id
    LEFT JOIN label_tasks lt_all ON t.id = lt_all.task_id
    LEFT JOIN labels l ON lt_all.label_id = l.id
    WHERE LOWER(l1.title) = LOWER('$label1')
        AND LOWER(l2.title) = LOWER('$label2')
        $done_filter
    GROUP BY t.id, t.title, t.done
    ORDER BY t.id;"

    echo "=== Tasks with '$label1' AND '$label2' labels ($status) ==="
    execute_query "$query" | column -t -s '|'
}

# Get task hierarchy (parent + all subtasks)
get_task_hierarchy() {
    local task_id="$1"

    local query="
    WITH RECURSIVE task_tree AS (
        -- Start with the specified task
        SELECT
            t.id,
            t.title,
            t.done,
            0 as level,
            t.id::text as path
        FROM tasks t
        WHERE t.id = $task_id

        UNION ALL

        -- Recursively get subtasks
        SELECT
            t.id,
            t.title,
            t.done,
            tt.level + 1,
            tt.path || ' > ' || t.id::text
        FROM tasks t
        JOIN task_relations tr ON t.id = tr.other_task_id
        JOIN task_tree tt ON tr.task_id = tt.id
        WHERE tr.relation_kind = 'subtask'
    )
    SELECT
        REPEAT('  ', level) || id as task_id,
        title,
        CASE WHEN done THEN 'Done' ELSE 'Active' END as status
    FROM task_tree
    ORDER BY path;"

    echo "=== Task Hierarchy for Task #$task_id ==="
    execute_query "$query" | column -t -s '|'
}

# Advanced custom search with raw SQL WHERE clause
advanced_search() {
    local where_clause="$1"

    local query="
    SELECT
        t.id,
        t.title,
        CASE WHEN t.done THEN 'Done' ELSE 'Active' END as status,
        array_agg(DISTINCT l.title) as labels
    FROM tasks t
    LEFT JOIN label_tasks lt ON t.id = lt.task_id
    LEFT JOIN labels l ON lt.label_id = l.id
    WHERE $where_clause
    GROUP BY t.id, t.title, t.done
    ORDER BY t.id;"

    echo "=== Advanced Search Results ==="
    execute_query "$query" | column -t -s '|'
}

# Get database statistics
stats() {
    local query="
    SELECT
        'Total Tasks' as metric,
        COUNT(*)::text as count
    FROM tasks
    UNION ALL
    SELECT
        'Active Tasks',
        COUNT(*)::text
    FROM tasks WHERE done = false
    UNION ALL
    SELECT
        'Parent Tasks',
        COUNT(DISTINCT t.id)::text
    FROM tasks t
    WHERE EXISTS (
        SELECT 1 FROM task_relations tr
        WHERE tr.task_id = t.id AND tr.relation_kind = 'subtask'
    )
    UNION ALL
    SELECT
        'Total Labels',
        COUNT(*)::text
    FROM labels;"

    echo "=== Vikunja Database Statistics ==="
    execute_query "$query" | column -t -s '|'
}

# Main CLI
case "${1:-help}" in
    search_parent_tasks|parent)
        search_parent_tasks "$2" "${3:-active}"
        ;;
    search_by_labels|labels)
        if [ -z "$2" ] || [ -z "$3" ]; then
            echo "Error: Requires two label names"
            echo "Usage: $0 search_by_labels LABEL1 LABEL2 [active|done|all]"
            exit 1
        fi
        search_by_labels "$2" "$3" "${4:-active}"
        ;;
    get_hierarchy|hierarchy)
        if [ -z "$2" ]; then
            echo "Error: Requires task ID"
            echo "Usage: $0 get_hierarchy TASK_ID"
            exit 1
        fi
        get_task_hierarchy "$2"
        ;;
    advanced)
        if [ -z "$2" ]; then
            echo "Error: Requires SQL WHERE clause"
            echo "Usage: $0 advanced \"LOWER(title) LIKE '%urgent%' AND done = false\""
            exit 1
        fi
        advanced_search "$2"
        ;;
    stats)
        stats
        ;;
    help|*)
        cat << EOF
Vikunja Database Query Helper
Usage: $0 COMMAND [ARGS]

Commands:
  search_parent_tasks KEYWORD [active|done|all]
      Find parent tasks (with subtasks) matching keyword
      Example: $0 search_parent_tasks goodfields active

  search_by_labels LABEL1 LABEL2 [active|done|all]
      Find tasks with BOTH labels (AND logic)
      Example: $0 search_by_labels Computer DeepWork active

  get_hierarchy TASK_ID
      Show task and all its subtasks in tree format
      Example: $0 get_hierarchy 350

  advanced "SQL_WHERE_CLAUSE"
      Execute custom query with SQL WHERE clause
      Example: $0 advanced "LOWER(title) LIKE '%urgent%' AND done = false"

  stats
      Show database statistics (task counts, labels, etc.)

Status values: active, done, all (default: active)

Note: This script is for complex queries that MCP cannot handle.
      For simple searches, use the Vikunja MCP tools with pagination.
EOF
        ;;
esac
