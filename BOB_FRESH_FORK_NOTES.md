# Bob Fresh Fork - Migration Notes

**Date**: 2025-12-06
**Upstream**: PAI v0.9.1
**Previous Fork**: Archived at ~/bob-archive-20251206-184823/

## What Changed

**Fresh Start**: Abandoned conflicted merge, forked fresh from upstream

**Upstream Version**: v0.9.1 (2025-12-04)
- Fixed PAI_DIR configuration
- Platform-agnostic installation
- Observability dashboard refactor
- Generic agent identity

## Migrated Assets

**Custom Skills** (6):
1. cognitive-loop - Daily writing + Substack
2. telos - Business strategy
3. taskman - Vikunja integration
4. financial-system - Firefly III
5. agent-observability - Dashboard
6. vikunja - Technical reference

**Custom Agents** (1):
- cfo - Financial advisor

**Custom Scripts** (3):
- taskman-query.sh
- vikunja-db-query.sh
- archive-ai-tasks.sh

**Personal Data**: All preserved in ~/.claude/ (gitignored)

## Architecture

**Repository** (/home/walub/projects/Personal_AI_Infrastructure/):
- Clean upstream PAI v0.9.1 + Bob's custom skills
- NO sensitive data (all gitignored)
- Can contribute improvements upstream

**Runtime** (~/.claude/):
- Bob's personality (CLAUDE.md)
- Personal data (telos, financial, cognitive-loop)
- API credentials (.env, .mcp.json.personal)
- Sensitive business data

## Git Workflow

**Remotes**:
- origin: danielmiessler/Personal_AI_Infrastructure (upstream)
- bob: wally-kroeker/Bob (your fork)

**Sync with Upstream**:
```bash
git fetch origin
git merge origin/main
# Custom skills preserved, upstream updates adopted
```

**Push Custom Changes**:
```bash
git push bob main
```

## Archive Recovery

If needed, restore old Bob:
```bash
ARCHIVE_DIR=~/bob-archive-20251206-184823
mv "$ARCHIVE_DIR/bob-fork-repo" /home/walub/projects/Personal_AI_Infrastructure
rm -rf ~/.claude
mv "$ARCHIVE_DIR/runtime-claude" ~/.claude
```

## Next Maintenance

- Weekly: Sync with upstream (git fetch origin && git merge origin/main)
- Monthly: Review new upstream skills
- As needed: Update custom skills

## API Keys & Configuration

**Status**: ✅ RESTORED (2025-12-06 19:07:00)

**Restored Files**:
- `~/.claude/.env` - All API keys restored from archive
- `~/.claude/.env.example` - Template with Bob-specific sections added
- `~/.claude/.mcp.json` - MCP server configuration restored
- `~/.claude/CLAUDE.md` - Bob's personality preserved

**Configured API Keys**:
- ✅ Perplexity API (perplexity-researcher agent)
- ✅ Google Gemini API (gemini-researcher agent)
- ✅ Replicate API (image/video generation)
- ✅ OpenAI API (cognitive-loop image generation)
- ✅ Firefly III API (financial-system skill)
- ✅ Vikunja API (taskman skill)
- ⚠️  ElevenLabs API (placeholder - configure if needed)
- ⚠️  BrightData API (placeholder - configure if needed)

---

## CLAUDE.md Template Sync (2025-12-13)

**Problem**: Runtime `~/.claude/CLAUDE.md` is not in git, making it difficult to sync Bob's personality across multiple PC installations.

**Solution**: Template-based sync workflow using `docs/templates/CLAUDE.md.bob` as version-controlled reference.

**Architecture**:
- **Runtime** (`~/.claude/CLAUDE.md`): Active personality file used by Claude Code (NOT in git)
- **Template** (`docs/templates/CLAUDE.md.bob`): Version-controlled reference (IN git, safe to share)
- **Sync Direction**: Runtime → Template → Git → Other machines

**Workflow for Primary Machine**:
```bash
# After updating runtime CLAUDE.md
cp ~/.claude/CLAUDE.md /home/walub/projects/Personal_AI_Infrastructure/docs/templates/CLAUDE.md.bob

# Commit to Bob fork
cd /home/walub/projects/Personal_AI_Infrastructure
git add docs/templates/CLAUDE.md.bob
git commit -m "docs(project/bob): update CLAUDE.md template #build-log"
git push origin main
```

**Workflow for Secondary Machines**:
```bash
# Pull latest from Bob fork
cd /home/walub/projects/Personal_AI_Infrastructure
git pull origin main

# Copy template to runtime
cp docs/templates/CLAUDE.md.bob ~/.claude/CLAUDE.md
```

**What's in the Template**:
- Core Identity (Bob as AI assistant)
- ADHD Support (Phase 1 implementation - 2025-12-13)
  - Task initiation, time management, emotional regulation, working memory
  - ADHD-optimized communication format (bullets, TLDR at bottom)
  - Rabbit hole management (gentle nudge after engagement)
  - Daily accountability behaviors
- Bob's voice and relationship patterns
- Strategic context (GoodFields, FabLab, StillPoint)
- Repository management
- Security reminders
- Publishing loop configuration

**Privacy**: Template contains NO sensitive data - safe to commit to public Bob fork. Machine-specific secrets stay in `~/.claude/.env` and other gitignored files.

**Documentation**: See `docs/templates/README.md` for complete sync instructions.

---

## Setup Wizard Issues (2025-12-07)

**Problem**: After running `./bootstrap.sh`, the PAI theme (Bob + green color) didn't show.

**Root Cause**: The setup wizard writes DA/DA_COLOR to:
1. `profile.json` - ✓ correct
2. `.bashrc` exports - ✓ correct

But it DOESN'T update `settings.json` env section, which is what Claude Code's statusline actually reads.

**Manual Fix Applied**:
```json
// ~/.claude/settings.json env section
"DA": "Bob",
"DA_COLOR": "green",
```

**Additional Fix**: Removed duplicate PAI config in bashrc (old one pointed to project folder instead of runtime).

**TODO for Bob Fork**:
- [ ] Update setup wizard to also update settings.json with DA/DA_COLOR
- [ ] Add validation that profile.json and settings.json are in sync

---

**Migration Complete**: 2025-12-06 18:53:00
**API Restoration Complete**: 2025-12-06 19:07:00
**Theme Fix Applied**: 2025-12-07
