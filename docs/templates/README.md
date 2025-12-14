# Bob Personal Templates

This directory contains template files for Bob's personalized configuration that can be synced across multiple installations.

## Files

### CLAUDE.md.bob
**Source**: `~/.claude/CLAUDE.md` (runtime)
**Purpose**: Bob's global personality configuration with ADHD helper and business partner features
**Updated**: 2025-12-13 (Phase 1: ADHD Support implementation)

**What's Included**:
- Core Identity (Bob as AI assistant)
- ADHD Support (Primary Role)
  - Task initiation protocols
  - Time management tracking
  - Emotional regulation (rejection sensitivity)
  - Working memory support
- Communication format (ADHD-optimized)
- Rabbit hole management
- Daily accountability behaviors
- Bob's voice and relationship patterns
- Strategic context integration (GoodFields, FabLab, StillPoint)
- Repository management
- Security reminders
- Publishing loop configuration

## Sync Workflow

### Initial Setup (New PC Installation)
1. Install PAI/Bob following standard bootstrap process
2. Copy template to runtime:
   ```bash
   cp docs/templates/CLAUDE.md.bob ~/.claude/CLAUDE.md
   ```
3. Verify personality loaded:
   ```bash
   head -20 ~/.claude/CLAUDE.md
   ```

### Keeping Templates Updated
When you modify `~/.claude/CLAUDE.md` on your primary machine:

```bash
# Copy runtime changes back to template
cp ~/.claude/CLAUDE.md /home/walub/projects/Personal_AI_Infrastructure/docs/templates/CLAUDE.md.bob

# Commit to Bob fork
cd /home/walub/projects/Personal_AI_Infrastructure
git add docs/templates/CLAUDE.md.bob
git commit -m "docs(project/bob): update CLAUDE.md template #build-log"
git push origin main
```

### Syncing to Other Machines
On secondary installations:

```bash
# Pull latest from Bob fork
cd /home/walub/projects/Personal_AI_Infrastructure
git pull origin main

# Copy template to runtime
cp docs/templates/CLAUDE.md.bob ~/.claude/CLAUDE.md
```

## Important Notes

**Runtime vs Template**:
- **Runtime** (`~/.claude/CLAUDE.md`): Active file used by Claude Code (NOT in git)
- **Template** (`docs/templates/CLAUDE.md.bob`): Version-controlled reference (IN git)

**Two-Way Sync**:
- Primary machine: Runtime → Template → Git
- Secondary machines: Git → Template → Runtime

**Privacy**:
- Template contains NO sensitive data (no API keys, passwords, personal details beyond business context)
- Safe to commit to public Bob fork
- Machine-specific secrets stay in `~/.claude/.env` and other gitignored files

**Merge Strategy**:
- If runtime CLAUDE.md diverges on multiple machines, choose one as canonical source
- Copy canonical → template → commit → pull on other machines
- Don't try to merge CLAUDE.md conflicts - pick one version

## Version History

- **2025-12-13**: Initial template creation with ADHD Support (Phase 1 implementation)
