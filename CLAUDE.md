# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

## 📋 Project Overview

**Personal AI Infrastructure (PAI)** is an open-source personal AI system that orchestrates life and work using Claude Code with a skills-based context management architecture. It provides:

- **Skills System**: Modular context bundles loaded on-demand for specialized capabilities
- **Voice Integration**: ElevenLabs-powered text-to-speech notifications with multiple agent voices
- **Agent Framework**: Pre-configured agents (engineer, architect, pentester, designer, researcher variants)
- **Command System**: User-defined commands for common workflows
- **Hook System**: Claude Code hooks for session management, documentation, and automation
- **CLI Integration**: Custom shell aliases and statusline integration

---

## 🏗️ Architecture

### Core Structure

```
PAI/
├── skills/                 # Modular context bundles for specialized domains
│   ├── PAI/               # Core PAI system context (always available)
│   ├── create-skill/      # Framework for creating new skills
│   ├── prompting/         # Prompt engineering and optimization
│   ├── research/          # Research methodology
│   ├── ffuf/              # Web fuzzing tool integration
│   ├── fabric/            # Fabric pattern integration
│   └── alex-hormozi-pitch/ # Business pitch framework
├── agents/                # Pre-configured agent personas (not activated by default)
│   ├── engineer.md        # Full-stack engineer persona
│   ├── architect.md       # System architect persona
│   ├── pentester.md       # Security testing persona
│   ├── designer.md        # UI/UX designer persona
│   ├── *-researcher.md    # Various research personas
├── commands/              # CLI commands that trigger workflows
│   ├── capture-learning.md
│   ├── conduct-research.md
│   ├── create-hormozi-pitch.md
│   └── load-dynamic-requirements.md
├── hooks/                 # Claude Code hook implementations (TypeScript)
│   ├── session-start hooks (load-core-context, initialize-pai-session)
│   ├── capture-tool-output.ts
│   ├── capture-session-summary.ts
│   ├── update-documentation.ts
│   └── context-compression-hook.ts
├── voice-server/          # ElevenLabs voice notification server (macOS/Bun)
├── documentation/         # Reference materials and guides
├── settings.json          # Claude Code settings (hooks, MCP servers, permissions)
├── PAI.md                 # Global context loaded on every prompt (via hook)
├── README.md              # Project overview and quickstart
└── setup.sh               # Installation and initialization script
```

### Key Architectural Patterns

**Skills-Based Context Loading (v0.5.0+)**:
- Each skill is a SKILL.md file with frontmatter defining trigger conditions
- Skills are loaded on-demand via `SessionStart` hook based on system state
- Core PAI skill always loads to establish identity and preferences
- Reduces token overhead: 92.5% reduction vs previous hook-based system

**Hook System** (settings.json):
- `SessionStart`: Loads PAI core context and initializes session
- `UserPromptSubmit`: Updates tab titles based on current task
- `PostToolUse`: Captures tool outputs for analytics
- `SessionEnd`: Summarizes session work
- `PreCompact`: Context compression before context overflow

**MCP Servers** (.mcp.json):
- Multiple MCP servers integrated for specialized capabilities
- Examples: httpx (web analysis), content (personal archive), naabu (port scanning), Stripe, Ref (doc search)
- See `.mcp.json` for full server list

---

## 🚀 Common Development Tasks

### Setting Up a Development Environment

```bash
# Install PAI system-wide
./setup.sh

# Install voice server (macOS only, requires Bun)
cd voice-server
./install.sh

# Verify installation
cd voice-server
./status.sh
```

### Working with Skills

**Create a new skill**:
```bash
# Use the create-skill framework
# 1. Navigate to skills/create-skill
# 2. Use templates in skills/create-skill/templates/
# 3. Follow SKILL.md frontmatter structure
```

**Structure of a Skill** (see `skills/*/SKILL.md`):
```yaml
---
name: skill-name
description: What this skill does and when to activate it
---

# Skill Title

## When to Activate This Skill
- Trigger conditions/phrases

## [Content Sections]
- Detailed context and procedures
```

**Key skill locations**:
- `skills/PAI/SKILL.md` - Core identity and preferences (always active)
- `skills/create-skill/SKILL.md` - Framework for creating skills
- `skills/*/SKILL.md` - Domain-specific skills

### Voice Server Operations

```bash
# Start voice server
cd voice-server && ./start.sh

# Stop voice server
cd voice-server && ./stop.sh

# Check status
cd voice-server && ./status.sh

# Restart (if hung)
cd voice-server && ./restart.sh

# View logs
cd voice-server && tail -f ~/.launchagents/com.pai.voiceserver.plist
```

**Configuration**:
- API Key: Set `ELEVENLABS_API_KEY` in `~/.env`
- Voice ID: Set `ELEVENLABS_VOICE_ID` in `~/.env` (defaults to Kai's voice)
- Port: Set `PORT` in `~/.env` (defaults to 8888)

### Testing and Validation

**Voice server functionality**:
```bash
# Test TTS endpoint
curl -X POST http://localhost:8888/tts \
  -H "Content-Type: application/json" \
  -d '{"text":"Hello world"}'

# Test with custom voice
curl -X POST http://localhost:8888/tts \
  -H "Content-Type: application/json" \
  -d '{"text":"Hello","voice_id":"your-voice-id"}'
```

### Git Workflow

PAI commits should follow conventional commits format:
```bash
# Standard commit
git commit -m "feat(feature-name): description"

# With build-log annotation (triggers documentation update)
git commit -m "feat(pai-core): update skill system #build-log"

# With milestone marker
git commit -m "chore(pai): milestone completion !milestone"
```

---

## 📁 File Conventions

### Skills
- Location: `skills/*/SKILL.md`
- Pattern: YAML frontmatter + markdown content
- Frontmatter fields: `name`, `description`, (optional: `tags`, `triggers`, `dependencies`)

### Agents (Optional Reference)
- Location: `agents/*.md`
- Usage: Can be loaded explicitly via skill or command
- Note: Agents are pre-configured personas, not auto-activated

### Hooks
- Location: `hooks/*.ts`
- Language: TypeScript/Bun
- Activation: Configured in `settings.json` under `hooks` key
- Execution: Runs in Claude Code hook system

### Commands
- Location: `commands/*.md` or `commands/*.ts`
- Purpose: Trigger workflows (e.g., conduct research, capture learning)
- Activation: Via Claude Code `/command` syntax

---

## 🔧 Technology Stack

### Runtime & Package Management
- **JavaScript/TypeScript**: Bun (primary runtime for scripts and voice server)
- **Python**: uv (if Python needed, though primary stack is TS/Bun)

### Key Technologies
- **Claude Code**: IDE integration and automation
- **ElevenLabs API**: Voice notifications and TTS
- **MCP (Model Context Protocol)**: Extensible tool/capability system
- **TypeScript/Bun**: Voice server, hooks, automation

### Development Tools
- Git (version control)
- Bash (shell scripts for installation/management)
- curl (testing voice server endpoints)

---

## 📖 Important Files to Know

| File | Purpose |
|------|---------|
| `PAI.md` | Global context loaded on every prompt (via SessionStart hook) |
| `settings.json` | Claude Code configuration: hooks, MCP servers, permissions |
| `.mcp.json` | MCP server definitions (httpx, content, daemon, Foundry, etc.) |
| `setup.sh` | Installation script for complete PAI setup |
| `voice-server/server.ts` | Voice notification server implementation |
| `skills/PAI/SKILL.md` | Core skill (identity, contacts, preferences) |
| `skills/create-skill/SKILL.md` | Framework for creating new skills |
| `README.md` | Project overview, features, quickstart |

---

## 🎯 Current Project State

**Latest Version**: v0.5.0+ (Skills-based architecture)

**Recent Work**:
- Session-start hook loading PAI skill as bootloader
- Massive repo updates: fixed missing files, hooks, settings
- 92.5% token reduction with skills-based system vs previous hook approach
- Automated documentation updates via pre-commit hooks

**Known Patterns**:
- Skills are the primary context delivery mechanism
- Hooks manage session lifecycle and documentation
- Voice server is macOS-specific (Bun-based)
- All configuration centralized in `settings.json`

---

## ⚠️ Important Notes

### Security
- **`~/.claude/` contains sensitive data** - Never commit to public repos
- Check git remote before committing: `git remote -v`
- Verify you're in the correct repository directory
- The PAI_DIR environment variable defaults to `~/.claude/` for private config

### Hook System
- Hooks are TypeScript files executed by Claude Code
- Pre-configured in `settings.json`
- SessionStart hooks load core context automatically
- Be cautious modifying hook configurations

### Voice Server
- macOS only (uses LaunchAgent for background service)
- Requires ElevenLabs API key
- Runs on port 8888 by default
- See `voice-server/QUICKSTART.md` for detailed setup

### MCP Servers
- Configured in `.mcp.json` with API credentials
- Currently enabled: httpx, content, daemon, Foundry, naabu, brightdata, stripe, Ref, apify, playwright
- Add new servers by extending `.mcp.json` configuration
- See `.mcp.json` for server configuration details

