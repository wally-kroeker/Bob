# Bob Fork - Project Memory

## Known Bugs

### ~~Setup Wizard Missing settings.json Update~~ FIXED
**Priority**: Medium
**Found**: 2025-12-07
**Fixed**: 2025-12-23

~~The setup wizard (`bootstrap.sh` → `setup.ts`) writes DA and DA_COLOR to profile.json and shell exports but NOT settings.json.~~

**Resolution**: Added `updateSettingsJson()` function to `.claude/Tools/setup/configurators/index.ts` that now writes DA, DA_COLOR, and PAI_DIR to the settings.json env section during setup.

---

## Git Remote Configuration

**Standard fork convention** (as of 2025-12-23):
```
origin   → wally-kroeker/Bob (your fork)
upstream → danielmiessler/Personal_AI_Infrastructure (original PAI)
```

**Common commands**:
```bash
# Pull updates from upstream PAI
git fetch upstream && git merge upstream/main

# Push changes to your fork
git push origin main
```

---

## Architecture Notes

**Symlink Setup** (runtime → project):

**CRITICAL**: You need BOTH lowercase and Title Case symlinks because:
- Claude Code's `settings.json` uses lowercase paths: `${PAI_DIR}/hooks/...`
- Hook scripts internally use Title Case paths: `${PAI_DIR}/Hooks/...`

Required symlinks in `~/.claude/`:
```bash
# Lowercase (for settings.json)
~/.claude/skills → .../Personal_AI_Infrastructure/.claude/Skills
~/.claude/hooks → .../Personal_AI_Infrastructure/.claude/Hooks
~/.claude/commands → .../Personal_AI_Infrastructure/.claude/Commands
~/.claude/agents → .../Personal_AI_Infrastructure/.claude/Agents

# Title Case (for hook scripts)
~/.claude/Skills → .../Personal_AI_Infrastructure/.claude/Skills
~/.claude/Hooks → .../Personal_AI_Infrastructure/.claude/Hooks
~/.claude/Commands → .../Personal_AI_Infrastructure/.claude/Commands
~/.claude/Agents → .../Personal_AI_Infrastructure/.claude/Agents

# Statusline
~/.claude/statusline-command.sh → .../Personal_AI_Infrastructure/.claude/statusline-command.sh
```

**IMPORTANT - SessionStart:startup hook errors**:
If you see hook errors, you're missing the Title Case symlinks. Fix with:
```bash
cd ~/.claude
# Keep lowercase symlinks, add Title Case ones
ln -s ~/projects/Personal_AI_Infrastructure/.claude/Hooks Hooks
ln -s ~/projects/Personal_AI_Infrastructure/.claude/Skills Skills
ln -s ~/projects/Personal_AI_Infrastructure/.claude/Commands Commands
ln -s ~/projects/Personal_AI_Infrastructure/.claude/Agents Agents
```

**Settings files are NOT symlinked** - runtime has its own copy that must be kept in sync.
