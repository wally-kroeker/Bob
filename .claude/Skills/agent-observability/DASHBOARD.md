# Dashboard Management

The Agent Observability dashboard requires two services to run:
1. **Server** (Bun backend) - Port 8080
2. **Client** (Vite frontend) - Port 5172

## Unified Dashboard Script

A single script manages both services with simple subcommands:

**Location:** `~/.claude/skills/agent-observability/dashboard.sh`

### Commands

```bash
./dashboard.sh start    # Launch both server and client
./dashboard.sh stop     # Stop both services
./dashboard.sh status   # Check running status
./dashboard.sh restart  # Restart both services
./dashboard.sh logs     # Tail log files (live updates)
./dashboard.sh open     # Open dashboard in browser
```

### Daily Workflow

**Start of day:**
```bash
cd ~/.claude/skills/agent-observability
./dashboard.sh start
./dashboard.sh open
```

**Check status anytime:**
```bash
./dashboard.sh status
```

**View real-time logs:**
```bash
./dashboard.sh logs  # Ctrl+C to exit
```

**End of day:**
```bash
./dashboard.sh stop
```

### Optional: Shell Alias

Add to your `~/.bashrc` or `~/.zshrc` for quick access:

```bash
alias obs='~/.claude/skills/agent-observability/dashboard.sh'
```

Then use short commands:
```bash
obs start
obs status
obs stop
obs logs
obs open
```

### Process Management

**PID Tracking:**
- PIDs stored in: `~/.claude/skills/agent-observability/.dashboard.pids`
- Automatically managed by start/stop commands

**Log Files:**
- Location: `/tmp/agent-obs-logs/`
- `server.log` - Backend service logs
- `client.log` - Frontend service logs

**Port Usage:**
- Server API: `http://localhost:8080`
- WebSocket: `ws://localhost:8080/stream`
- Dashboard UI: `http://localhost:5172`

### Troubleshooting

**Dashboard won't start:**
```bash
# Check if already running
./dashboard.sh status

# Force stop and restart
./dashboard.sh stop
./dashboard.sh start
```

**Check for port conflicts:**
```bash
# Check if port 8080 is in use
lsof -i :8080

# Check if port 5172 is in use
lsof -i :5172
```

**View detailed logs:**
```bash
# Live tail
./dashboard.sh logs

# Or view directly
tail -f /tmp/agent-obs-logs/server.log
tail -f /tmp/agent-obs-logs/client.log
```

**Manual cleanup:**
```bash
# Remove stale PID file
rm ~/.claude/skills/agent-observability/.dashboard.pids

# Find and kill processes manually
ps aux | grep bun
kill <PID>
```

### Architecture

```
dashboard.sh start
    │
    ├─→ Server (PID saved)
    │   └─→ Reads: ~/.claude/history/raw-outputs/YYYY-MM/YYYY-MM-DD_all-events.jsonl
    │   └─→ Listens: http://localhost:8080
    │   └─→ WebSocket: ws://localhost:8080/stream
    │
    └─→ Client (PID saved)
        └─→ Vite dev server
        └─→ Listens: http://localhost:5172
        └─→ Connects to: ws://localhost:8080/stream
```

### What Gets Captured

Once running, the dashboard automatically displays:
- **SessionStart** - New Claude Code session
- **UserPromptSubmit** - User messages
- **PreToolUse** - Before tool execution (Read, Write, Bash, etc.)
- **PostToolUse** - After tool completion
- **Stop** - Main agent completes
- **SubagentStop** - Subagent completes
- **SessionEnd** - Session ends

### Features in the Dashboard

**Swim Lanes:**
- Visual timeline showing bob (main agent) and any subagents
- Parallel execution visible at a glance

**Filtering:**
- By agent name (bob, designer, engineer, pentester, etc.)
- By event type (PreToolUse, PostToolUse, etc.)
- By session ID
- Search event payloads

**Real-time Updates:**
- Events appear as they happen
- WebSocket streaming (no polling)
- Low latency visualization

### Data Storage

Events are stored in JSONL format:
```
~/.claude/history/raw-outputs/YYYY-MM/YYYY-MM-DD_all-events.jsonl
```

**Example event:**
```jsonl
{"source_app":"bob","session_id":"abc123","hook_event_type":"PreToolUse","payload":{...},"timestamp":1234567890,"timestamp_pst":"2025-01-28 14:30:00 PST"}
```

Server keeps last 1000 events in memory for fast streaming.

### Integration with Claude Code

Events are captured via hooks configured in `~/.claude/settings.json`:
- Hooks execute on every tool use
- `capture-all-events.ts` appends to JSONL files
- Server watches JSONL files and streams to dashboard
- Zero database overhead

### See Also

- [README.md](./README.md) - Complete feature documentation
- [SETUP.md](./SETUP.md) - Initial installation guide
- [settings.json.example](./settings.json.example) - Hook configuration template
