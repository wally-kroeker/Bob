# CORE Skill - Personal Setup

The `SKILL.md` file in this directory is a **template** for your personal AI identity and context.

## Setup Instructions

**For new installations:**

1. Copy the template to your personal version:
   ```bash
   cp SKILL.md data/SKILL.md.personal
   ```

2. Edit `data/SKILL.md.personal` with your personal information:
   - Your AI's name and personality
   - Your contacts and email addresses
   - Your stack preferences
   - Your security warnings

3. The `data/` directory is gitignored - your personal data stays private.

## Why This Pattern?

- **Repository**: `SKILL.md` stays as a template (safe to commit publicly)
- **Runtime**: `data/SKILL.md.personal` contains your actual personal data (gitignored)
- **Pattern**: Follows same approach as `settings.json` → `settings.json.personal`

## Current Setup

This Bob fork repository:
- ✅ `SKILL.md` - Template from upstream (committed)
- ✅ `data/SKILL.md.personal` - Your personal version (gitignored)
- ✅ `.gitignore` has wildcard pattern: `.claude/skills/*/data/`

Claude Code runtime will use the template from the repo. Customize `data/SKILL.md.personal` for your actual personal context.
