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

**Settings files are HARDLINKED** - `~/.claude/settings.json` and `~/.claude/settings.local.json` are hardlinked to the project versions, so changes sync automatically.

**CRITICAL - Skill Permissions**:
The main `settings.json` must have `Skill(*)` in the allow list to enable all skills globally:
```json
"permissions": {
  "allow": [
    "Bash", "Read", "Write", "Edit", "MultiEdit", "Glob", "Grep",
    "WebFetch(domain:*)", "WebSearch", "NotebookRead", "NotebookEdit",
    "TodoWrite", "ExitPlanMode", "Task", "mcp__*",
    "Skill(*)"  // Required for all skills to work
  ]
}
```

---

## Bob Personality & Tools

### ADHD-Aware CLAUDE.md Template

**Location**: `Docs/templates/CLAUDE.md.bob-example`

This is Bob's full personality template with ADHD support features:
- Four core support areas (Task Initiation, Time Management, Emotional Regulation, Working Memory)
- ADHD-optimized communication format (TLDR + Next action)
- Rabbit hole management and accountability behaviors
- Strategic context integration (GoodFields, FabLab, StillPoint)
- Inside jokes and relationship dynamics (🎸 "knowing the chords")

**Installation**:
```bash
cp Docs/templates/CLAUDE.md.bob-example ~/.claude/CLAUDE.md
```

This template should be customized with your own:
- Personal projects and goals (G1, R1 references)
- Wisdom references (W1-W13, C1-C7)
- Inside jokes and communication preferences
- Lead tracking and follow-up patterns

### Claude Launcher (cc script)

**Location**: `.claude/Tools/claude-launcher.sh`

Interactive model selection launcher for Claude Code with:
- Anthropic direct API (Sonnet/Opus/Haiku 4.5)
- LiteLLM proxy support (Gemini, GPT, Ollama models)
- Automatic web tools configuration (Anthropic WebSearch vs Tavily MCP)
- Model pricing display and health checks

**Installation**:
```bash
# Add to ~/.bashrc
alias cc="~/projects/Personal_AI_Infrastructure/.claude/Tools/claude-launcher.sh"
```

**Usage**:
```bash
cc              # Launch interactive menu
cc [args]       # Pass args to claude after model selection
```

**Requirements**:
- For LiteLLM: Running proxy at `http://localhost:4000`
- For Tavily: API key configured in `~/.claude.json` (script will prompt)

---
