# Bob Setup Guide

Complete setup and configuration guide for Bob, a personal fork of the Personal AI Infrastructure (PAI) project.

---

## 📋 Overview

**Bob** is Wally's personalized AI assistant built on the PAI framework. This fork customizes the upstream PAI project for:
- WSL2/Linux environment
- Simplified hooks configuration
- Integration with personal publishing loop system
- Custom skills and workflow automation

**Repository Structure**:
- **Upstream**: [danielmiessler/Personal_AI_Infrastructure](https://github.com/danielmiessler/Personal_AI_Infrastructure)
- **This Fork**: [wally-kroeker/Bob](https://github.com/wally-kroeker/Bob)
- **Environment**: WSL2 on Windows, Bun 1.3.0, Claude Code

---

## 🏗️ Architecture Overview

### Two-Tier Data Architecture

Bob uses a two-tier system to separate public code from private data:

#### Tier 1: Repository (Public-Safe)
**Location**: `/home/walub/projects/Personal_AI_Infrastructure/`
**Purpose**: Template code and framework
**Git Status**: Tracked, can be shared/contributed upstream

```
/home/walub/projects/Personal_AI_Infrastructure/
├── skills/              # Skill templates (public)
├── agents/              # Agent templates (public)
├── commands/            # Command templates (public)
├── hooks/               # Hook implementation (public)
├── documentation/       # Public docs
├── settings.json        # TEMPLATE with ${PAI_DIR} variables
├── .env.example         # Template (no real keys)
├── CLAUDE.md            # Project development guide
├── BOB_SETUP.md         # This file
└── CONTRIBUTING_WORKFLOW.md  # Git workflows
```

#### Tier 2: Runtime Installation (Private)
**Location**: `~/.claude/`
**Purpose**: Actual personal data and configuration
**Git Status**: NOT tracked, completely private

```
~/.claude/
├── skills/
│   └── PAI/
│       └── SKILL.md     # Your REAL personal data
├── settings.json        # Symlinked from *.personal files
├── .mcp.json            # Your real MCP server configs
├── .env                 # API keys (if copied here)
├── hooks/               # Installed hook scripts
├── commands/            # Installed commands
├── history/             # Session logs (captured automatically)
└── scratchpad/          # Temporary work
    └── YYYY-MM-DD-*/    # Timestamped test directories
```

### Personal Files (Gitignored in Repository)

These files live in the repository directory but are NEVER committed:

- `*.personal` - Personal config files (settings.json.personal, .mcp.json.personal)
- `MY_*.md` - Personal documentation (MY_CUSTOMIZATIONS.md)
- `.env` - API keys and secrets

---

## 🚀 Initial Setup

### Prerequisites

1. **WSL2** installed on Windows
2. **Bun** JavaScript runtime
   ```bash
   curl -fsSL https://bun.sh/install | bash
   ```
3. **Git** configured with your identity
   ```bash
   git config --global user.name "Your Name"
   git config --global user.email "your@email.com"
   ```
4. **Claude Code** installed ([claude.ai/code](https://claude.ai/code))

### Clone and Configure

```bash
# 1. Clone your Bob fork
git clone https://github.com/wally-kroeker/Bob.git Personal_AI_Infrastructure
cd Personal_AI_Infrastructure

# 2. Add upstream remote
git remote add upstream https://github.com/danielmiessler/Personal_AI_Infrastructure
git fetch upstream

# 3. Verify remotes
git remote -v
# Should show:
#   origin    https://github.com/wally-kroeker/Bob.git
#   upstream  https://github.com/danielmiessler/Personal_AI_Infrastructure
```

### Environment Configuration

```bash
# 1. Copy environment template
cp .env.example .env

# 2. Edit with your API keys
nano .env

# Required for research agents:
#   PERPLEXITY_API_KEY=your_key
#   GOOGLE_API_KEY=your_key
# Optional:
#   OPENAI_API_KEY=your_key
#   APIFY_API_TOKEN=your_token
```

### Personal Configuration Files

```bash
# 1. Create personal settings (if not exists)
cp settings.json settings.json.personal
nano settings.json.personal
# Update:
#   - DA: "Bob"
#   - Any personal preferences

# 2. Create personal MCP config (if not exists)
cp .mcp.json.example .mcp.json.personal
nano .mcp.json.personal
# Add your MCP server configurations and API tokens
```

---

## 📁 File Organization

### What Goes Where?

| Data Type | Location | Git Status | Purpose |
|-----------|----------|------------|---------|
| **API Keys** | `.env` in repo root | ❌ Gitignored | Secrets, never committed |
| **Personal Settings** | `settings.json.personal` | ❌ Gitignored | Your Claude Code config |
| **Personal MCP** | `.mcp.json.personal` | ❌ Gitignored | MCP servers with tokens |
| **Personal Notes** | `MY_CUSTOMIZATIONS.md` | ❌ Gitignored | Setup notes, private docs |
| **Runtime Config** | `~/.claude/skills/PAI/SKILL.md` | ❌ Outside repo | Real personal data |
| **Template Settings** | `settings.json` in repo | ✅ Committed | Portable template |
| **Framework Code** | `skills/`, `agents/`, etc. | ✅ Committed | Public-safe code |
| **Documentation** | `*.md` files (except MY_*) | ✅ Committed | Public docs |

### Security Rules

**NEVER commit**:
- `.env` files (API keys)
- `*.personal` files (personal config)
- `MY_*.md` files (personal notes)
- `~/.claude/*` contents (private data)

**ALWAYS check before commit**:
```bash
# 1. Check which repo you're in
git remote -v

# 2. Review what you're committing
git status
git diff

# 3. Ensure no secrets
git diff | grep -i "api_key\|token\|password"
```

---

## 🎯 Global Configuration (~/.claude/CLAUDE.md)

Bob's runtime behavior is controlled by `~/.claude/CLAUDE.md`, which contains:

- Core Bob identity and personality
- Repository management instructions
- Personal data architecture explanation
- Security reminders
- When to update the Bob repository
- Publishing loop integration

This file is loaded on every Claude Code session and guides Bob's behavior.

---

## 🔄 Git Workflows

### Daily Personal Work

Working on Bob customizations (not for upstream):

```bash
# Make changes on main branch
git checkout main
nano skills/my-custom-skill/SKILL.md

# Commit to your fork
git add skills/my-custom-skill/
git commit -m "feat(project/bob): add custom skill"
git push origin main
```

### Contributing to Upstream

Contributing improvements back to PAI:

```bash
# 1. Sync with upstream first
git fetch upstream
git checkout main
git merge upstream/main

# 2. Create contribution branch
git checkout -b contrib/my-feature

# 3. Make changes
nano documentation/some-improvement.md

# 4. Commit
git add documentation/some-improvement.md
git commit -m "docs: improve setup documentation"

# 5. Push to YOUR fork
git push origin contrib/my-feature

# 6. Create PR on GitHub:
#    Base: danielmiessler/Personal_AI_Infrastructure:main
#    Head: wally-kroeker/Bob:contrib/my-feature
```

### Syncing with Upstream

Keep Bob updated with upstream PAI improvements:

```bash
# Fetch latest from upstream
git fetch upstream

# See what's new
git log HEAD..upstream/main --oneline

# Merge into your main
git checkout main
git merge upstream/main

# Push to your fork
git push origin main
```

---

## 🛠️ Installation to ~/.claude/

### Option 1: Run setup.sh (Recommended)

```bash
cd /home/walub/projects/Personal_AI_Infrastructure
./setup.sh
```

This installs:
- Skills to `~/.claude/skills/`
- Hooks to `~/.claude/hooks/`
- Commands to `~/.claude/commands/`
- Settings (symlinked from `settings.json.personal`)

### Option 2: Manual Installation

```bash
# Create directory structure
mkdir -p ~/.claude/{skills,hooks,commands,history,scratchpad}

# Copy/install components
cp -r skills/* ~/.claude/skills/
cp -r hooks/* ~/.claude/hooks/
cp -r commands/* ~/.claude/commands/

# Symlink settings
ln -sf $(pwd)/settings.json.personal ~/.claude/settings.json
ln -sf $(pwd)/.mcp.json.personal ~/.claude/.mcp.json
```

### Customize Personal Data

After installation:

```bash
# Edit your REAL personal data (not the template!)
nano ~/.claude/skills/PAI/SKILL.md

# Replace [CUSTOMIZE] placeholders with:
# - Your real contacts
# - Your projects
# - Your preferences
# - Financial data sources (if needed)
```

---

## 🧪 Testing & Validation

### Verify Installation

```bash
# Check directory structure
ls -la ~/.claude/

# Expected:
#   skills/
#   hooks/
#   commands/
#   settings.json -> /path/to/settings.json.personal
#   .mcp.json -> /path/to/.mcp.json.personal
```

### Test Claude Code Integration

1. Open Claude Code
2. Verify Bob loads: Check for session-start hook message
3. Ask: "Who are you?" → Should respond as "Bob"
4. Check skills loaded: "List available skills"

### Test API Integrations

```bash
# Test research agents (requires API keys in .env)
# In Claude Code:
"Do research on latest AI developments"

# Should invoke:
# - perplexity-researcher (if PERPLEXITY_API_KEY set)
# - gemini-researcher (if GOOGLE_API_KEY set)
# - claude-researcher (built-in, no key needed)
```

---

## 📚 Key Differences from Upstream PAI

### Hooks Configuration

**Bob** (Simplified):
- SessionStart: load-core-context.ts only
- All other hooks: disabled

**Upstream PAI** (Full):
- SessionStart: load-core-context.ts + initialize-pai-session.ts
- PostToolUse: capture-tool-output.ts
- SessionEnd: capture-session-summary.ts
- UserPromptSubmit: update-tab-titles.ts
- PreCompact: context-compression-hook.ts

**Rationale**: Simplified for faster startup and reduced complexity during initial setup phase.

### Environment

**Bob**: WSL2/Linux on Windows
**Upstream**: Primarily macOS (voice server requires macOS)

**Implications**:
- Voice server features disabled (macOS-only)
- Path conventions: Unix-style (`/home/walub/...`)
- Package manager: Bun for JS/TS, uv for Python

---

## 🔐 Security Best Practices

### Pre-Commit Checks

**ALWAYS before committing**:

```bash
# 1. Verify repository
git remote -v

# 2. Check staged files
git status

# 3. Review changes
git diff --cached

# 4. Scan for secrets
git diff --cached | grep -iE "(api_key|token|password|secret)"

# 5. Verify gitignore working
git status | grep -E "(\.env|\.personal|MY_)"
# Should see these files as untracked, NOT staged
```

### API Key Management

- ✅ Store in `.env` file (gitignored)
- ✅ Use environment variables in code
- ✅ Never hardcode in scripts or config
- ✅ Rotate keys regularly
- ✅ Use minimum permissions for each key

### Personal Data Protection

- ✅ Real contacts only in `~/.claude/skills/PAI/SKILL.md`
- ✅ Financial data in encrypted vault or outside git
- ✅ Session history in `~/.claude/history/` (private)
- ✅ Test files in `~/.claude/scratchpad/` (temporary)

---

## 📖 Documentation Files

### Repository Files (Git-Tracked)

- **README.md**: Project overview and quickstart
- **CLAUDE.md**: Development guide for working on Bob
- **BOB_SETUP.md**: This comprehensive setup guide
- **CONTRIBUTING_WORKFLOW.md**: Git fork workflows
- **SECURITY.md**: Security guidelines

### Personal Files (Gitignored)

- **MY_CUSTOMIZATIONS.md**: Your personal setup notes
- **settings.json.personal**: Your Claude Code settings
- **.mcp.json.personal**: Your MCP server configs

### Runtime Files (Outside Repo)

- **~/.claude/CLAUDE.md**: Bob's runtime instructions (global)
- **~/.claude/skills/PAI/SKILL.md**: Your real personal data

---

## 🎯 Next Steps

After completing setup:

1. **Review Documentation**:
   - Read CONTRIBUTING_WORKFLOW.md for git workflows
   - Review CLAUDE.md for development guidance

2. **Customize Personal Data**:
   - Edit `~/.claude/skills/PAI/SKILL.md` with real contacts
   - Add project information
   - Configure financial data sources (if needed)

3. **Test Functionality**:
   - Verify Bob loads correctly
   - Test research agents with API keys
   - Try creating a test skill

4. **Integrate with Workflow**:
   - Connect to publishing loop system
   - Set up MCP servers for your needs
   - Create custom commands for your workflow

5. **Contribute Back**:
   - Document learnings
   - Create useful skills or improvements
   - Submit PRs to upstream PAI

---

## 🆘 Troubleshooting

### "Bob doesn't load / behaves like default PAI"

**Check**:
- Is `~/.claude/CLAUDE.md` created with Bob instructions?
- Is `~/.claude/settings.json` symlinked to `settings.json.personal`?
- Does `settings.json.personal` have `DA: "Bob"`?

### "API keys not working"

**Check**:
- Are keys in `.env` file?
- Correct format: `PERPLEXITY_API_KEY=pk-xxx-your-key`
- No quotes around values
- No spaces around `=`
- Keys actually valid (test on provider website)

### "Git push rejected"

**Check**:
```bash
git remote -v
# Ensure pushing to origin (your fork), not upstream
git push origin main  # Explicit remote
```

### "Accidentally committed secrets"

**Immediately**:
```bash
# If not pushed yet:
git reset HEAD~1
git add .  # Re-add without secrets
git commit -m "your message"

# If already pushed to YOUR fork (not upstream):
# 1. Rotate the exposed keys IMMEDIATELY
# 2. Remove from git history (careful!):
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch .env" \
  --prune-empty --tag-name-filter cat -- --all
git push origin --force --all
```

---

## 📞 Resources

- **Upstream PAI**: https://github.com/danielmiessler/Personal_AI_Infrastructure
- **Your Fork**: https://github.com/wally-kroeker/Bob
- **Claude Code**: https://claude.ai/code
- **Bun Runtime**: https://bun.sh
- **WSL2 Docs**: https://learn.microsoft.com/en-us/windows/wsl/

---

## 📝 Change Log

**2025-10-21**: Initial Bob setup and documentation
- Forked from upstream PAI
- Configured for WSL2 environment
- Simplified hooks configuration
- Created comprehensive documentation
- Integrated with publishing loop system

---

**Maintained by**: Wally Kroeker
**License**: MIT (inherited from upstream PAI)
**Last Updated**: 2025-10-21
