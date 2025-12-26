# Bob Fork - Project Memory

## Known Bugs

### ~~settings.json Contains User-Specific PAI_DIR Path~~ FIXED
**Priority**: High
**Found**: 2025-12-26
**Fixed**: 2025-12-26

~~**Problem**: The `.claude/settings.json` file contains `PAI_DIR` with an absolute path (e.g., `/home/bob/.claude`). When pushing from different machines (dev server vs local), this path gets committed and breaks hooks on other machines.~~

**Resolution**: Implemented gitignore + template approach:
1. `settings.json` is now gitignored (machine-specific)
2. `settings.json.example` is the tracked template with placeholders (`__PAI_DIR__`, `__DA__`, `__DA_COLOR__`)
3. Setup script (`configurators/index.ts`) copies template and replaces placeholders if settings.json doesn't exist
4. Each machine has its own settings.json that won't conflict on push/pull

**After cloning/pulling on new machine**:
```bash
# Option 1: Run setup wizard
bash .claude/Tools/setup/bootstrap.sh

# Option 2: Manual copy + replace
cp .claude/settings.json.example .claude/settings.json
sed -i 's|__PAI_DIR__|/home/youruser/.claude|g' .claude/settings.json
sed -i 's|__DA__|YourAssistantName|g' .claude/settings.json
sed -i 's|__DA_COLOR__|green|g' .claude/settings.json
```

---

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

### User CLAUDE.md Templates

The `~/.claude/CLAUDE.md` file defines your AI assistant's personality and how it interacts with you. We provide two files:

**1. Generic Template** - `Docs/templates/CLAUDE.md.template`

Portable template with placeholders for creating your own assistant:
- Core identity and personality traits
- Cognitive support patterns (optional ADHD/executive function support)
- Communication preferences and response format
- Accountability behaviors
- Strategic context for your projects

**Installation**:
```bash
cp Docs/templates/CLAUDE.md.template ~/.claude/CLAUDE.md
# Then customize with your own name, projects, and preferences
```

**2. Wally's Bob** - `Docs/templates/CLAUDE.md.bob`

Working example showing how the template looks when filled in:
- Bob as ADHD helper and business partner
- Specific context (GoodFields, FabLab, StillPoint)
- Inside jokes (🎸 "knowing the chords")
- Integration with telos skill for wisdom references (W1-W15, C1-C7)

Use this as a reference for how to customize the template.

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
