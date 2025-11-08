# Bob Setup Guide - Complete Installation

**Complete setup guide for Bob, Wally's personal fork of the Personal AI Infrastructure (PAI) project adapted for WSL2.**

---

## 📋 What Is Bob?

**Bob** is a personal AI assistant built on the [Personal AI Infrastructure (PAI)](https://github.com/danielmiessler/Personal_AI_Infrastructure) framework. This fork customizes PAI for:

- **WSL2/Linux environment** (Windows with WSL2)
- **Custom skills** (task management, writing practice, business strategy)
- **Personal data privacy** in a public fork
- **Integration** with personal projects and workflows

**Repository Structure**:
- **Upstream**: [danielmiessler/Personal_AI_Infrastructure](https://github.com/danielmiessler/Personal_AI_Infrastructure) (original PAI framework)
- **This Fork**: [wally-kroeker/Bob](https://github.com/wally-kroeker/Bob) (your customizations)
- **Environment**: WSL2, Bun runtime, Claude Code

---

## 🎯 Fork Philosophy: Customization, Not Hiding

**Important Concept**: This fork is about **version controlling your customizations**, not hiding PAI itself.

### What's Public (Committed to Your Fork):
- ✅ Custom skills (cognitive-loop, taskman, telos) - **framework code**
- ✅ Setup documentation (BOB_MANUAL_SETUP.md, etc.)
- ✅ Custom commands and slash commands
- ✅ Template files (settings.json, CORE/SKILL.md with [CUSTOMIZE] placeholders)

### What's Private (Gitignored):
- ❌ Personal data (contacts, emails, API keys)
- ❌ `*.personal` files (actual settings, MCP configs)
- ❌ `*/data/` directories in skills (actual personal content)
- ❌ `.env` files (API keys and secrets)

**The Pattern**: Framework code is public, personal data is gitignored. You can share your skills and contribute back upstream without exposing private information.

---

## 🏗️ Architecture Overview

### Two-Tier System

```
┌────────────────────────────────────────────────────────┐
│ Bob Fork Repository (Version Controlled)               │
│ /home/walub/projects/Personal_AI_Infrastructure/       │
│                                                         │
│ PUBLIC (Committed):                                     │
│ ├── .claude/skills/*/SKILL.md (templates)              │
│ ├── .claude/hooks/ (framework code)                    │
│ ├── .claude/commands/ (slash commands)                 │
│ ├── settings.json (template with ${PAI_DIR})           │
│ └── BOB_*.md (documentation)                           │
│                                                         │
│ PRIVATE (Gitignored):                                   │
│ ├── settings.json.personal (actual config)             │
│ ├── .mcp.json.personal (MCP servers + tokens)          │
│ ├── .env (API keys)                                    │
│ ├── .claude/skills/*/data/ (personal content)          │
│ └── MY_*.md (personal notes)                           │
└────────────────────────────────────────────────────────┘
                        │
                        │ symlinked
                        ▼
┌────────────────────────────────────────────────────────┐
│ Runtime Installation (~/.claude/)                      │
│                                                         │
│ Symlinked from repo:                                    │
│ ├── skills/ → repo/.claude/skills/                     │
│ ├── hooks/ → repo/.claude/hooks/                       │
│ ├── commands/ → repo/.claude/commands/                 │
│ ├── settings.json → repo/settings.json.personal        │
│ └── .mcp.json → repo/.mcp.json.personal                │
│                                                         │
│ Real directories (not in repo):                         │
│ ├── history/ (session logs)                            │
│ ├── scratchpad/ (temporary work)                       │
│ └── data/ (runtime data)                               │
└────────────────────────────────────────────────────────┘
```

**Key Benefits**:
- Edit skills in repo → changes immediately visible via symlinks
- Version control your customizations
- Contribute improvements back upstream
- Keep personal data private with gitignore
- No build step, no deployment

---

## 🚀 Quick Start (New Installation)

### Prerequisites

1. **WSL2** on Windows ([Microsoft Docs](https://learn.microsoft.com/en-us/windows/wsl/install))
2. **Bun** JavaScript runtime:
   ```bash
   curl -fsSL https://bun.sh/install | bash
   ```
3. **Git** configured:
   ```bash
   git config --global user.name "Your Name"
   git config --global user.email "your@email.com"
   ```
4. **Claude Code** ([claude.ai/code](https://claude.ai/code))

### Installation Steps

**Option 1: Start Fresh (Recommended)**

```bash
# 1. Clone YOUR fork (replace with your GitHub username)
git clone https://github.com/YOUR-USERNAME/Bob.git Personal_AI_Infrastructure
cd Personal_AI_Infrastructure

# 2. Add upstream remote
git remote add upstream https://github.com/danielmiessler/Personal_AI_Infrastructure
git fetch upstream

# 3. Verify remotes
git remote -v
# Should show:
#   origin    https://github.com/YOUR-USERNAME/Bob.git
#   upstream  https://github.com/danielmiessler/Personal_AI_Infrastructure
```

**Option 2: Fork Wally's Bob**

If you want to start with my customizations:

```bash
# 1. Fork wally-kroeker/Bob on GitHub to YOUR-USERNAME/Bob

# 2. Clone your fork
git clone https://github.com/YOUR-USERNAME/Bob.git Personal_AI_Infrastructure
cd Personal_AI_Infrastructure

# 3. Add upstreams
git remote add upstream https://github.com/danielmiessler/Personal_AI_Infrastructure
git remote add wally https://github.com/wally-kroeker/Bob
git fetch --all
```

### Configuration

```bash
# 1. Create personal environment file
cp .env.example .env
nano .env
# Add your API keys:
#   PERPLEXITY_API_KEY=your_key
#   GOOGLE_API_KEY=your_key
#   OPENAI_API_KEY=your_key (if using)

# 2. Create personal settings
cp settings.json settings.json.personal
nano settings.json.personal
# Update:
#   "env": {
#     "PAI_DIR": "/home/YOUR-USERNAME/projects/Personal_AI_Infrastructure/.claude"
#   }

# 3. Create personal MCP config (if needed)
cp .mcp.json.example .mcp.json.personal
nano .mcp.json.personal
# Add your MCP server configurations
```

### Runtime Installation

See **BOB_MANUAL_SETUP.md** for detailed step-by-step installation to `~/.claude/`.

Quick version:
```bash
# Install PAI to runtime
./setup.sh

# Or manual installation (if setup.sh doesn't work on WSL2):
# See BOB_MANUAL_SETUP.md for complete manual process
```

---

## 🔐 Security Model: Data/Code Separation

### The Privacy Pattern

All personal data is kept private via **gitignore patterns**:

```gitignore
# Settings (personal configs)
*.personal
settings.json.personal
.mcp.json.personal

# Secrets
.env
.env.*

# Personal notes
MY_*.md

# Skill data (all skills)
.claude/skills/*/data/
```

### CORE Skill Privacy (Critical!)

The CORE skill contains your AI's identity and your personal contacts. **Never commit personal data!**

**Pattern**:
- `CORE/SKILL.md` - Template with [CUSTOMIZE] placeholders (committed, public-safe)
- `CORE/data/SKILL.md.personal` - Your actual personal data (gitignored, private)

**Setup**:
```bash
cd .claude/skills/CORE

# 1. Copy template to personal version
cp SKILL.md data/SKILL.md.personal

# 2. Edit personal version with real data
nano data/SKILL.md.personal
# Replace [CUSTOMIZE] with:
#   - Your AI's name
#   - Your real contacts and emails
#   - Your preferences
#   - Your security warnings

# 3. Verify data/ is gitignored
git status
# Should NOT show data/SKILL.md.personal
```

The `data/` directory is gitignored by wildcard pattern, so your personal information stays private.

### Custom Skills Privacy

When creating custom skills with personal data:

```bash
# Create skill
mkdir -p .claude/skills/my-skill

# Framework code (committed)
nano .claude/skills/my-skill/SKILL.md

# Personal data (gitignored)
mkdir .claude/skills/my-skill/data
nano .claude/skills/my-skill/data/my-data.md
# Automatically gitignored by .claude/skills/*/data/ pattern
```

### Pre-Commit Safety

Pre-commit hooks automatically scan for secrets:

```bash
# Caught by pre-commit:
git commit
# 🔍 Running pre-commit safety checks...
# ⚠️  WARNING: Possible secret pattern detected
```

**Always verify before committing**:
```bash
# 1. Check repository
git remote -v

# 2. Review changes
git status
git diff --cached

# 3. Ensure no personal data
git status | grep -E "(\.env|\.personal|data/)"
# These should be untracked, not staged
```

---

## 🎯 Understanding Your Fork Position

### "X Commits Ahead" is Normal

```bash
git status
# Your branch is ahead of 'upstream/main' by 12 commits.
```

**This is CORRECT!** Those commits are YOUR customizations:
- Custom skills (cognitive-loop, taskman, telos)
- WSL2 documentation
- Custom commands
- Personal workflow integrations

### Upstream Deletions Are Expected

When you sync with upstream, you may see Daniel delete files you have (taskman, vikunja, personal commands). **This is fine** - he's cleaning up his personal content from the public framework.

**Your fork philosophy**:
- Upstream = PAI framework
- Your fork = Framework + YOUR customizations
- Being ahead = Having customizations (good!)
- Upstream deletions = He removed his personal stuff (doesn't affect yours)

---

## 📚 Custom Skills in This Fork

### cognitive-loop
**Purpose**: Daily Substack publishing practice with AI-powered memory

**Features**:
- Proactive workflow checklist
- AI-powered quote extraction
- Theme tracking across posts
- Writing streak monitoring
- Voice preservation (reviews previous posts)

**Memory Files** (`data/` - gitignored):
- `published-posts.md` - Archive with themes, quotes
- `recurring-themes.md` - Theme evolution
- `writing-streak.md` - Streak tracking

### taskman
**Purpose**: ADHD-friendly task management with Vikunja integration

**Features**:
- Natural language task capture
- AI-native date parsing
- Project routing intelligence
- Priority using ADHD momentum principle
- Context-aware suggestions (time/energy)

**Architecture**:
- Read: SQLite cache (fast)
- Write: MCP tools → Vikunja API (authoritative)
- Sync: `/taskman-refresh` command

**Data** (`data/taskman.db` - gitignored):
- 208 tasks, 14 projects, 18 labels

### telos
**Purpose**: Business strategy, goals, leads tracking

**Features**:
- Mission, vision, unique value
- Goal tracking with deadlines
- Risk monitoring (runway, pipeline)
- Active leads management
- Decision filters and wisdom

**Why it matters**: Bob uses Telos to hold you accountable using YOUR goals.

### vikunja
**Purpose**: Technical reference for Vikunja API

**Key Decision**: Removed user-facing triggers. Pure documentation skill to support TaskMan.

---

## 🔄 Daily Workflow

### Working on Custom Skills

```bash
cd /home/walub/projects/Personal_AI_Infrastructure

# Edit skill
nano .claude/skills/cognitive-loop/SKILL.md

# Changes immediately visible in Claude Code (via symlink)

# Commit when satisfied
git add .claude/skills/cognitive-loop/
git commit -m "feat(project/bob): improve cognitive-loop context"
git push origin main
```

### Creating New Custom Skills

```bash
# Create skill directory
mkdir -p .claude/skills/my-new-skill

# Create SKILL.md with frontmatter
cat > .claude/skills/my-new-skill/SKILL.md << 'EOF'
---
name: my-new-skill
description: |
  What this skill does and when to activate
---

# My New Skill

## When to Activate
- Trigger phrases

## Content
[Your skill documentation]
EOF

# If skill has personal data, use data/ directory
mkdir .claude/skills/my-new-skill/data
# Automatically gitignored

# Test in Claude Code

# Commit skill (data stays private)
git add .claude/skills/my-new-skill/
git commit -m "feat(project/bob): add my-new-skill"
git push origin main
```

### Syncing with Upstream PAI

```bash
# Weekly: Fetch upstream changes
git fetch upstream

# Review what's new
git log HEAD..upstream/main --oneline

# Merge improvements
git merge upstream/main

# Push to your fork
git push origin main
```

See **BOB_UPDATE_WORKFLOW.md** for detailed sync procedures.

---

## 🧪 Testing & Validation

### Verify Installation

```bash
# Check symlinks
ls -la ~/.claude/
# Should show symlinks to repo

# Check personal files gitignored
git status
# Should NOT show:
#   - .env
#   - settings.json.personal
#   - .mcp.json.personal
#   - .claude/skills/*/data/
```

### Test Claude Code

1. Open Claude Code
2. Ask: "Who are you?" → Should respond as "Bob" (or your AI's name)
3. Check skills: `/skill cognitive-loop` (if you have it)
4. Verify custom commands work

### Test Custom Skills

```bash
# In Claude Code:

# Test TaskMan (if configured)
"What's my next task?"

# Test cognitive-loop (if configured)
"Help me write today's post"

# Test Telos (if configured)
"What are my current goals?"
```

---

## 📖 Documentation Reference

### This Fork's Documentation

| File | Purpose |
|------|---------|
| **BOB_SETUP.md** | This file - overall setup guide |
| **BOB_MANUAL_SETUP.md** | Step-by-step installation to ~/.claude/ |
| **BOB_UPDATE_WORKFLOW.md** | Git fork workflows and syncing |
| **CLAUDE.md** | Development guide for working on Bob repo |

### Upstream PAI Documentation

| File | Purpose |
|------|---------|
| **README.md** | PAI project overview |
| **skills/create-skill/** | Skill creation framework |
| **skills/prompting/** | Prompt engineering guide |

---

## 🆘 Troubleshooting

### "Bob doesn't load / wrong identity"

**Check**:
```bash
# 1. Settings symlink
readlink -f ~/.claude/settings.json
# Should point to: /path/to/repo/settings.json.personal

# 2. Personal settings content
cat ~/.claude/settings.json | jq '.env.PAI_DIR'
# Should show your repo .claude directory

# 3. CORE skill personal data
cat .claude/skills/CORE/data/SKILL.md.personal | head -20
# Should have YOUR data, not [CUSTOMIZE]
```

### "Git wants to commit personal data"

**Fix**:
```bash
# Check what's staged
git status

# If personal files appear:
git reset HEAD .env
git reset HEAD settings.json.personal
git reset HEAD .claude/skills/*/data/

# Verify gitignore
cat .gitignore | grep -A 3 "Custom skill data"
# Should show: .claude/skills/*/data/
```

### "Merge conflicts with upstream"

Usually in CORE/SKILL.md where upstream updated the template.

**Strategy**:
1. Keep CORE/SKILL.md as template (from upstream)
2. Your personal data is safe in CORE/data/SKILL.md.personal (gitignored)
3. Accept upstream's template changes

```bash
# During merge conflict:
git checkout --theirs .claude/skills/CORE/SKILL.md
git add .claude/skills/CORE/SKILL.md
git commit
```

### "Accidentally committed secrets"

**Immediate action**:
```bash
# 1. ROTATE THE SECRET IMMEDIATELY (API provider website)

# 2. Remove from history (if only in your fork):
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch .env" \
  --prune-empty --tag-name-filter cat -- --all

git push origin --force --all

# 3. Review and fix .gitignore
```

---

## 🎯 Next Steps

After completing setup:

1. **Customize Personal Data**:
   - Edit `.claude/skills/CORE/data/SKILL.md.personal`
   - Replace all [CUSTOMIZE] placeholders
   - Add your real contacts, preferences

2. **Create Your First Custom Skill**:
   - Use `skills/create-skill/` as template
   - Document YOUR workflow
   - Keep framework code public, data private

3. **Test Thoroughly**:
   - Verify Bob loads with your identity
   - Test custom skills work
   - Ensure gitignore protects personal data

4. **Contribute Back** (Optional):
   - Document WSL2 learnings
   - Create generally useful skills
   - Submit PRs to upstream PAI

---

## 📞 Resources

- **Upstream PAI**: https://github.com/danielmiessler/Personal_AI_Infrastructure
- **Wally's Bob Fork**: https://github.com/wally-kroeker/Bob
- **wallykroeker.com**: https://wallykroeker.com/blog/building-bob-personal-ai-infrastructure-on-wsl
- **Claude Code**: https://claude.ai/code
- **Bun Runtime**: https://bun.sh
- **WSL2 Docs**: https://learn.microsoft.com/en-us/windows/wsl/

---

**Maintained by**: Wally Kroeker
**License**: MIT (inherited from upstream PAI)
**Last Updated**: 2025-11-08
