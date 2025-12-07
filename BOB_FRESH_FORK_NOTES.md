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

**Note**: API keys and credentials were not migrated automatically (they were symlinks to the old repo).

**To restore**:
1. Edit `.claude/.env` with your API keys (use `.claude/.env.example` as template)
2. Edit `.claude/.mcp.json.personal` with MCP server credentials
3. Verify `.claude/CLAUDE.md` has Bob's personality (already present)

**Required API Keys**:
- OpenAI API (for cognitive-loop image generation)
- ElevenLabs API (for voice notifications, if used)
- Firefly III API (for financial-system)
- Vikunja credentials (for taskman)

---

**Migration Complete**: 2025-12-06 18:53:00
