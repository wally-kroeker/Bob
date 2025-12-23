# Bob Fork - Project Memory

## Known Bugs

### Setup Wizard Missing settings.json Update
**Priority**: Medium
**Found**: 2025-12-07

The setup wizard (`bootstrap.sh` → `setup.ts`) writes DA and DA_COLOR to:
- `profile.json` - correct
- `.bashrc` exports - correct

But it does NOT update `settings.json` env section, which is what Claude Code's statusline actually reads.

**Files to modify**:
- `.claude/tools/setup/configurators/index.ts` - add settings.json update
- Consider reading from profile.json on startup to sync values

**Workaround**: Manually edit `~/.claude/settings.json`:
```json
"env": {
  "DA": "Bob",
  "DA_COLOR": "green"
}
```

---

## Architecture Notes

**Symlink Setup** (runtime → project):
- `~/.claude/skills` → project `.claude/skills`
- `~/.claude/hooks` → project `.claude/hooks`
- `~/.claude/commands` → project `.claude/commands`
- `~/.claude/agents` → project `.claude/agents`
- `~/.claude/statusline-command.sh` → project `.claude/statusline-command.sh`

**Settings files are NOT symlinked** - runtime has its own copy that must be kept in sync.
