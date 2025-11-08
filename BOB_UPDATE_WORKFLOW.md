# Bob Update & Sync Workflow

How to keep your Bob fork in sync with upstream PAI while preserving your customizations.

---

## The Three-Way Sync

```
┌──────────────────────┐
│  Upstream PAI        │  danielmiessler/Personal_AI_Infrastructure
│  (Origin Source)     │
└──────────┬───────────┘
           │
           │ git fetch upstream
           │ git merge upstream/main
           ▼
┌──────────────────────┐
│  Bob Fork            │  wally-kroeker/Bob
│  (Your Repo)         │  /home/walub/projects/Personal_AI_Infrastructure/
└──────────┬───────────┘
           │
           │ symlinks
           ▼
┌──────────────────────┐
│  ~/.claude/          │  Runtime Installation
│  (Active System)     │
└──────────────────────┘
```

**Data Flow:**
1. Upstream releases updates
2. You pull updates into Bob fork
3. Resolve conflicts (if any)
4. Changes immediately visible in `~/.claude/` (via symlinks)

---

## Weekly Sync: Upstream → Bob Fork

Run this weekly to stay current with upstream improvements.

### Step 1: Check for Upstream Changes

```bash
cd /home/walub/projects/Personal_AI_Infrastructure

# Fetch latest from upstream (doesn't change your code)
git fetch upstream

# See what's new
echo "Upstream commits you don't have yet:"
git log HEAD..upstream/main --oneline --graph

# See which files changed
echo ""
echo "Files modified in upstream:"
git diff --name-status HEAD..upstream/main
```

**Review the changes** - look for:
- Hook improvements
- New skills
- Documentation updates
- Breaking changes

### Step 2: Merge Upstream Changes

**If no conflicts expected (clean merge):**

```bash
cd /home/walub/projects/Personal_AI_Infrastructure

# Make sure you're on main
git checkout main

# Merge upstream
git merge upstream/main -m "chore(project/bob): sync with upstream PAI $(date +%Y-%m-%d)"

# Push to your fork
git push origin main

echo "✅ Synced with upstream, pushed to Bob fork"
```

**If conflicts expected:**

```bash
cd /home/walub/projects/Personal_AI_Infrastructure

# Create a merge branch first
git checkout -b merge/upstream-$(date +%Y%m%d)

# Attempt merge
git merge upstream/main

# If conflicts occur, Git will tell you which files
# Fix conflicts manually, then:
git add [conflicted-files]
git commit -m "chore(project/bob): merge upstream with conflict resolution"

# Test everything works (restart Claude Code, verify)

# If good, merge to main
git checkout main
git merge merge/upstream-$(date +%Y%m%d)
git push origin main

# Clean up merge branch
git branch -d merge/upstream-$(date +%Y%m%d)
```

### Step 3: Handle Common Conflicts

**Conflict in `.claude/skills/CORE/SKILL.md`:**

This will happen often - upstream updates the template, you've customized yours.

```bash
# During merge conflict:
# 1. Open the file
vim .claude/skills/CORE/SKILL.md

# 2. You'll see conflict markers:
#    <<<<<<< HEAD (your version)
#    [your customizations]
#    =======
#    [upstream changes]
#    >>>>>>> upstream/main

# 3. Strategy:
#    - Keep YOUR personal data (contacts, preferences)
#    - Adopt upstream's new structure/features
#    - Manually merge the best of both

# 4. Remove conflict markers
# 5. Test the file is valid

# 6. Mark resolved
git add .claude/skills/CORE/SKILL.md
git commit -m "chore(project/bob): merge CORE skill - preserved customizations"
```

**Conflict in hooks:**

Upstream improved a hook, but you haven't modified it.

```bash
# Take upstream version (usually safe)
git checkout --theirs .claude/hooks/[hook-name].ts
git add .claude/hooks/[hook-name].ts

# Or take your version
git checkout --ours .claude/hooks/[hook-name].ts
git add .claude/hooks/[hook-name].ts

# Or manually merge
vim .claude/hooks/[hook-name].ts
# Edit to combine both
git add .claude/hooks/[hook-name].ts

git commit -m "chore(project/bob): resolve hook conflict"
```

### Step 4: Verify After Merge

```bash
# Restart Claude Code
# Verify:
# - No hook errors
# - Bob identity intact
# - Custom skills still work
# - New upstream features work (if any)

# If everything good:
git push origin main
```

---

## Daily Work: Edit Custom Skills

Your normal workflow editing skills and configurations.

### Editing Custom Skills

```bash
cd /home/walub/projects/Personal_AI_Infrastructure

# Edit a skill
vim .claude/skills/cognitive-loop/SKILL.md

# Changes are IMMEDIATELY visible to Claude Code (via symlinks)
# Test in Claude Code

# Commit when satisfied
git add .claude/skills/cognitive-loop/
git commit -m "docs(project/bob): update cognitive-loop skill context"
git push origin main
```

### Editing Settings

```bash
cd /home/walub/projects/Personal_AI_Infrastructure

# Edit your personal settings
vim settings.json.personal

# Restart Claude Code to apply changes

# Settings are gitignored, don't commit unless you want to
# (Usually only commit if you changed structure, not just values)
```

### Creating a New Custom Skill

```bash
cd /home/walub/projects/Personal_AI_Infrastructure

# Create new skill directory
mkdir -p .claude/skills/my-new-skill

# Create SKILL.md with frontmatter
cat > .claude/skills/my-new-skill/SKILL.md << 'EOF'
---
name: My New Skill
description: |
  Brief description of what this skill does
---

# Extended context

[Your skill content here]
EOF

# If skill has data, create data directory and gitignore it
mkdir -p .claude/skills/my-new-skill/data
echo ".claude/skills/my-new-skill/data/" >> .gitignore

# Test skill loads in Claude Code

# Commit skill (data is gitignored)
git add .claude/skills/my-new-skill/
git add .gitignore
git commit -m "feat(project/bob): add my-new-skill #build-log !milestone"
git push origin main
```

---

## Monthly: Update wallykroeker.com Build Log

When you reach milestones with Bob improvements:

```bash
cd /home/walub/projects/Personal_AI_Infrastructure

# Make improvements to Bob
# ...multiple commits...

# When ready to document milestone:
git log --oneline --since="1 month ago" | grep '!milestone'

# Use those commits to update your build log
# (See wallykroeker.com publishing loop documentation)
```

---

## Contributing Back to Upstream PAI

When you create something valuable for the PAI community:

### Step 1: Identify What to Contribute

**Good candidates:**
- Bug fixes in hooks
- Documentation improvements
- New utility scripts
- Generic skills (not personal)
- Improvements to core PAI features

**Don't contribute:**
- Personal customizations (Bob identity)
- Your custom skills (cognitive-loop, etc.)
- Your settings.json.personal
- Anything with your personal data

### Step 2: Create Contribution Branch

```bash
cd /home/walub/projects/Personal_AI_Infrastructure

# Sync with upstream first
git fetch upstream
git checkout main
git merge upstream/main

# Create contrib branch
git checkout -b contrib/your-feature-name

# Make your improvements
vim .claude/hooks/some-improvement.ts

# Test thoroughly

# Commit
git commit -m "feat: improve hook error handling

- Better error messages
- Graceful degradation
- Improved logging"

# Push to YOUR fork
git push origin contrib/your-feature-name
```

### Step 3: Create Pull Request

```bash
# Using GitHub CLI
gh pr create \
  --base danielmiessler/Personal_AI_Infrastructure:main \
  --head wally-kroeker:contrib/your-feature-name \
  --title "feat: improve hook error handling" \
  --body "**Description:**
Improved error handling in hooks with better messages and graceful degradation.

**Testing:**
Tested in WSL2 environment with Bun runtime.

**Type:** Enhancement
**Breaking Changes:** None"

# Or create PR manually on GitHub web interface
```

### Step 4: After PR Merged

```bash
cd /home/walub/projects/Personal_AI_Infrastructure

# Switch back to main
git checkout main

# Sync with upstream (now includes your contribution)
git fetch upstream
git merge upstream/main

# Delete local contrib branch
git branch -d contrib/your-feature-name

# Delete remote contrib branch
git push origin --delete contrib/your-feature-name

# Push synced main
git push origin main
```

---

## Emergency: Rollback a Bad Merge

If you merged upstream and things broke:

### Option 1: Revert the Merge (Safe)

```bash
cd /home/walub/projects/Personal_AI_Infrastructure

# Find the merge commit
git log --oneline --graph -10

# Revert the merge (creates new commit)
git revert -m 1 [merge-commit-hash]

# Push
git push origin main

# Fix issues at your leisure, then re-merge
```

### Option 2: Hard Reset (Destructive)

**⚠️  ONLY if you haven't pushed yet!**

```bash
cd /home/walub/projects/Personal_AI_Infrastructure

# Reset to before merge
git reset --hard HEAD~1

# Your local changes are gone
# (Good thing you have backups!)
```

### Option 3: Restore from Backup

**If everything is broken:**

```bash
# Find your latest backup
ls -lth ~/PAI-migration-backup-*/

# Restore Bob fork
BACKUP="[path-to-backup]"
rm -rf /home/walub/projects/Personal_AI_Infrastructure
cp -a "$BACKUP/PAI-original" /home/walub/projects/Personal_AI_Infrastructure

# Restart Claude Code
```

---

## Maintenance Calendar

### Weekly
- [ ] Fetch upstream changes (`git fetch upstream`)
- [ ] Review what's new (`git log HEAD..upstream/main`)
- [ ] Merge if significant updates

### Monthly
- [ ] Full sync with upstream
- [ ] Review custom skills for cleanup
- [ ] Update build log with milestones
- [ ] Check for new PAI features to adopt

### Quarterly
- [ ] Backup custom skill data
- [ ] Review and clean scratchpad
- [ ] Archive old session history
- [ ] Review settings.json for cruft

---

## Quick Reference Commands

```bash
# Check current state
git remote -v                    # Verify origin/upstream
git status                       # What's changed locally
git log --oneline -5             # Recent commits

# Sync with upstream
git fetch upstream               # Get latest (safe, doesn't merge)
git log HEAD..upstream/main      # See what's new
git merge upstream/main          # Merge changes

# Work on custom skills
cd /home/walub/projects/Personal_AI_Infrastructure
vim .claude/skills/[skill-name]/SKILL.md
git add .claude/skills/[skill-name]/
git commit -m "docs(project/bob): update [skill-name]"
git push origin main

# Create contribution
git checkout -b contrib/feature-name
# ...make changes...
git push origin contrib/feature-name
gh pr create --base danielmiessler/Personal_AI_Infrastructure:main

# Verify installation
echo $PAI_DIR                    # Should be Bob fork .claude dir
ls -la ~/.claude/skills          # Should point to Bob fork
readlink -f ~/.claude/hooks      # Verify symlink target
```

---

## File Organization Rules

### Git Tracked (in Bob fork):
- `.claude/skills/*/SKILL.md` - Skill definitions
- `.claude/hooks/*.ts` - Hook scripts
- `.claude/commands/*.md` - Slash commands
- `.claude/agents/*.md` - Agent personas
- `settings.json` - Template (with ${PAI_DIR} variables)
- Documentation files

### Gitignored (private):
- `settings.json.personal` - Your actual config
- `.env` - Your API keys
- `.mcp.json.personal` - Your MCP servers
- `.claude/skills/*/data/` - Custom skill data
- `MY_*.md` - Personal notes

### Not in Repo (runtime only):
- `~/.claude/history/` - Session logs
- `~/.claude/scratchpad/` - Temporary work
- `~/.claude/projects/` - Per-project state

---

## Getting Help

**If sync breaks:**
1. Don't panic - you have backups
2. Check `git status` to see what's conflicted
3. Review conflict in files
4. Ask Bob for help analyzing the conflict
5. Worst case: revert the merge

**If upstream made breaking changes:**
1. Read upstream CHANGELOG/release notes
2. Review their migration guide
3. Test in a branch first
4. Ask in PAI discussions if unclear

**If you accidentally committed secrets:**
1. Rotate the secret IMMEDIATELY
2. Remove from history: `git filter-branch` or BFG Repo-Cleaner
3. Force push (if only in your fork)
4. Review .gitignore to prevent reoccurrence

---

**This workflow lets you:**
- ✅ Stay current with upstream PAI improvements
- ✅ Preserve your Bob customizations
- ✅ Contribute improvements back to PAI community
- ✅ Track your custom skills in version control
- ✅ Share your Bob setup with others
