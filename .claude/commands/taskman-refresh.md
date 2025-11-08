---
description: Refresh the TaskMan task cache from Vikunja API
---

Run the TaskMan cache sync script to fetch the latest tasks from Vikunja and rebuild the local SQLite cache.

Execute the script: `~/.claude/skills/taskman/scripts/sync-task-cache.sh`

Parse the output and present it to the user in a clear, friendly format. Show:
- Number of projects synced
- Number of tasks synced (total and active)
- Sync duration
- Any errors or warnings

After successful sync, confirm the cache is ready and suggest the user can now ask task-related questions like "What should I work on next?"
