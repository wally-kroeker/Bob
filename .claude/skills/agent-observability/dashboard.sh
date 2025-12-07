#!/bin/bash
# Agent Observability Dashboard Manager
# Usage: dashboard.sh {start|stop|status|restart|logs|open}

SKILL_DIR="$HOME/.claude/skills/agent-observability"
PID_FILE="$SKILL_DIR/.dashboard.pids"
LOG_DIR="/tmp/agent-obs-logs"

# Create log directory
mkdir -p "$LOG_DIR"

start_dashboard() {
    # Check if already running
    if [ -f "$PID_FILE" ]; then
        echo "⚠️  Dashboard may already be running."
        echo "   Run '$0 stop' first or check '$0 status'"
        return 1
    fi

    echo "🚀 Starting Agent Observability Dashboard..."
    echo ""

    # Start server
    cd "$SKILL_DIR/apps/server" || exit 1
    bun run dev > "$LOG_DIR/server.log" 2>&1 &
    SERVER_PID=$!
    echo "  ✅ Server started (PID: $SERVER_PID)"
    echo "     • URL: http://localhost:8080"
    echo "     • Log: $LOG_DIR/server.log"

    # Wait for server to initialize
    sleep 1

    # Start client
    cd "$SKILL_DIR/apps/client" || exit 1
    bun run dev > "$LOG_DIR/client.log" 2>&1 &
    CLIENT_PID=$!
    echo ""
    echo "  ✅ Client started (PID: $CLIENT_PID)"
    echo "     • URL: http://localhost:5172"
    echo "     • Log: $LOG_DIR/client.log"

    # Save PIDs
    echo "$SERVER_PID" > "$PID_FILE"
    echo "$CLIENT_PID" >> "$PID_FILE"

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📊 Dashboard ready: http://localhost:5172"
    echo "🛑 To stop: $0 stop"
    echo "📈 Check status: $0 status"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

stop_dashboard() {
    if [ ! -f "$PID_FILE" ]; then
        echo "⚠️  No PID file found. Dashboard may not be running."
        echo "   Check running processes with: ps aux | grep bun"
        return 1
    fi

    echo "🛑 Stopping Agent Observability Dashboard..."
    echo ""

    # Read PIDs and stop each process
    while IFS= read -r pid; do
        if ps -p "$pid" > /dev/null 2>&1; then
            if kill "$pid" 2>/dev/null; then
                echo "  ✅ Stopped process $pid"
            else
                echo "  ⚠️  Failed to stop process $pid (trying SIGKILL)"
                kill -9 "$pid" 2>/dev/null
            fi
        else
            echo "  ℹ️  Process $pid already stopped"
        fi
    done < "$PID_FILE"

    # Remove PID file
    rm "$PID_FILE"

    echo ""
    echo "✅ Dashboard stopped successfully"
}

status_dashboard() {
    echo "📊 Agent Observability Dashboard Status"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    if [ ! -f "$PID_FILE" ]; then
        echo "❌ Dashboard is NOT running"
        echo ""
        echo "To start: $0 start"
        return 1
    fi

    # Check each process
    RUNNING_COUNT=0
    while IFS= read -r pid; do
        if ps -p "$pid" > /dev/null 2>&1; then
            PROCESS_NAME=$(ps -p "$pid" -o comm= 2>/dev/null)
            echo "  ✅ Process $pid is running ($PROCESS_NAME)"
            RUNNING_COUNT=$((RUNNING_COUNT + 1))
        else
            echo "  ❌ Process $pid is NOT running"
        fi
    done < "$PID_FILE"

    echo ""
    if [ $RUNNING_COUNT -eq 2 ]; then
        echo "✅ Dashboard is RUNNING"
    elif [ $RUNNING_COUNT -eq 1 ]; then
        echo "⚠️  Dashboard is PARTIALLY running (one service down)"
    else
        echo "❌ Dashboard is DOWN (no services running)"
    fi

    echo ""
    echo "🌐 Access URLs:"
    echo "  • Dashboard: http://localhost:5172"
    echo "  • Server API: http://localhost:8080"
    echo ""
    echo "📝 Logs:"
    if [ -d "$LOG_DIR" ]; then
        echo "  • Server: $LOG_DIR/server.log"
        echo "  • Client: $LOG_DIR/client.log"
        echo ""
        echo "  View logs: $0 logs"
    fi
}

restart_dashboard() {
    echo "🔄 Restarting dashboard..."
    stop_dashboard
    sleep 1
    start_dashboard
}

show_logs() {
    if [ ! -d "$LOG_DIR" ]; then
        echo "❌ No logs directory found"
        return 1
    fi

    echo "📝 Tailing logs (Ctrl+C to exit)..."
    echo ""
    tail -f "$LOG_DIR"/*.log
}

open_browser() {
    URL="http://localhost:5172"
    echo "🌐 Opening dashboard in browser: $URL"

    # Try different browser openers
    if command -v xdg-open &> /dev/null; then
        xdg-open "$URL" 2>/dev/null
    elif command -v open &> /dev/null; then
        open "$URL" 2>/dev/null
    else
        echo "⚠️  Could not detect browser opener."
        echo "   Please open manually: $URL"
    fi
}

show_usage() {
    cat << EOF
Agent Observability Dashboard Manager

Usage: $0 {start|stop|status|restart|logs|open}

Commands:
  start    - Start both server and client
  stop     - Stop both services
  status   - Show running status
  restart  - Restart both services
  logs     - Tail log files
  open     - Open dashboard in browser

Examples:
  $0 start          # Start dashboard
  $0 status         # Check if running
  $0 logs           # Watch logs in real-time
  $0 open           # Open in browser
EOF
}

# Main command dispatcher
case "${1:-}" in
    start)
        start_dashboard
        ;;
    stop)
        stop_dashboard
        ;;
    status)
        status_dashboard
        ;;
    restart)
        restart_dashboard
        ;;
    logs)
        show_logs
        ;;
    open)
        open_browser
        ;;
    -h|--help|help)
        show_usage
        ;;
    "")
        echo "❌ No command specified"
        echo ""
        show_usage
        exit 1
        ;;
    *)
        echo "❌ Unknown command: $1"
        echo ""
        show_usage
        exit 1
        ;;
esac
