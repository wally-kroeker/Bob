# Bob Manual Setup Guide - v0.6.0

**DO NOT USE setup.sh** - This guide is for manual installation to preserve your fork-based workflow.

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│ Bob Fork Repository (Source of Truth)                       │
│ /home/walub/projects/Personal_AI_Infrastructure/            │
│                                                              │
│ Git Tracked:                                                 │
│ ├── .claude/                                                 │
│ │   ├── skills/ (CORE + custom skills)                      │
│ │   ├── hooks/                                               │
│ │   ├── commands/                                            │
│ │   └── agents/                                              │
│ ├── settings.json (TEMPLATE - uses ${PAI_DIR} variables)    │
│ └── [documentation, examples]                                │
│                                                              │
│ Gitignored (Personal):                                       │
│ ├── settings.json.personal (your actual config)             │
│ ├── .env (your API keys)                                    │
│ ├── .mcp.json.personal (your MCP servers)                   │
│ └── .claude/skills/*/data/ (custom skill data)              │
└─────────────────────────────────────────────────────────────┘
                            │
                            │ symlinked
                            ▼
┌─────────────────────────────────────────────────────────────┐
│ Runtime Installation                                         │
│ ~/.claude/                                                   │
│                                                              │
│ Symlinked to Bob fork:                                       │
│ ├── settings.json → ../projects/Personal_AI.../settings...  │
│ ├── .env → ../projects/Personal_AI.../.env                  │
│ ├── skills → ../projects/Personal_AI.../.claude/skills      │
│ ├── hooks → ../projects/Personal_AI.../.claude/hooks        │
│ └── [other framework directories]                           │
│                                                              │
│ Real directories (runtime-only):                             │
│ ├── history/ (session logs)                                 │
│ ├── scratchpad/ (temporary work)                            │
│ └── projects/ (per-project data)                            │
└─────────────────────────────────────────────────────────────┘
```

**Key Principle:**
- Bob fork = version control your customizations
- ~/.claude/ = where Claude Code expects files
- Symlinks bridge the two

---

## Migration: Step-by-Step

### Phase 1: Backup Everything

```bash
# Create timestamped backup
BACKUP_DIR="$HOME/PAI-migration-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "Creating backup at: $BACKUP_DIR"

# Backup entire PAI installation
cp -a /home/walub/PAI "$BACKUP_DIR/PAI-original"

# Backup custom skills with data
cp -a /home/walub/PAI/.claude/skills/cognitive-loop "$BACKUP_DIR/" 2>/dev/null || true
cp -a /home/walub/PAI/.claude/skills/taskman "$BACKUP_DIR/" 2>/dev/null || true
cp -a /home/walub/PAI/.claude/skills/telos "$BACKUP_DIR/" 2>/dev/null || true
cp -a /home/walub/PAI/.claude/skills/vikunja "$BACKUP_DIR/" 2>/dev/null || true

# Backup current settings
cp /home/walub/projects/Personal_AI_Infrastructure/settings.json.personal "$BACKUP_DIR/" 2>/dev/null || true
cp /home/walub/projects/Personal_AI_Infrastructure/.env "$BACKUP_DIR/" 2>/dev/null || true
cp /home/walub/projects/Personal_AI_Infrastructure/.mcp.json.personal "$BACKUP_DIR/" 2>/dev/null || true

# Backup runtime data
cp /home/walub/.claude/history.jsonl "$BACKUP_DIR/" 2>/dev/null || true
cp -a /home/walub/.claude/history "$BACKUP_DIR/" 2>/dev/null || true

echo "✅ Backup complete"
ls -lh "$BACKUP_DIR"
```

**CHECKPOINT:** Verify backup created successfully before proceeding.

---

### Phase 2: Migrate Custom Skills to Bob Fork

```bash
cd /home/walub/projects/Personal_AI_Infrastructure

# Copy custom skills (preserve timestamps and permissions)
echo "Copying custom skills to Bob fork..."
cp -a /home/walub/PAI/.claude/skills/cognitive-loop .claude/skills/ 2>/dev/null || echo "cognitive-loop not found"
cp -a /home/walub/PAI/.claude/skills/taskman .claude/skills/ 2>/dev/null || echo "taskman not found"
cp -a /home/walub/PAI/.claude/skills/telos .claude/skills/ 2>/dev/null || echo "telos not found"
cp -a /home/walub/PAI/.claude/skills/vikunja .claude/skills/ 2>/dev/null || echo "vikunja not found"

# Copy commands directory if it exists
if [ -d "/home/walub/.claude/commands" ]; then
  echo "Copying commands directory..."
  cp -a /home/walub/.claude/commands .claude/
fi

# Verify copy
echo "✅ Verifying custom skills in Bob fork:"
ls -la .claude/skills/ | grep -E "cognitive-loop|taskman|telos|vikunja"
```

**Update .gitignore to protect skill data:**

```bash
cd /home/walub/projects/Personal_AI_Infrastructure

# Add data directory protection to .gitignore
cat >> .gitignore << 'EOF'

# Custom skill data (preserve locally, don't commit to public repo)
.claude/skills/cognitive-loop/data/
.claude/skills/taskman/data/
.claude/skills/telos/data/
.claude/skills/vikunja/data/
EOF

# Verify gitignore working
echo "✅ Checking git status (data directories should not appear):"
git status
```

**CHECKPOINT:** Custom skills and their data should be in Bob fork, data directories gitignored.

---

### Phase 3: Update Environment Variables

**Update settings.json.personal:**

```bash
cd /home/walub/projects/Personal_AI_Infrastructure

# Backup current settings.json.personal
cp settings.json.personal settings.json.personal.backup

# Update PAI_DIR using jq (safer than manual edit)
jq '.env.PAI_DIR = "/home/walub/projects/Personal_AI_Infrastructure/.claude"' \
  settings.json.personal > settings.json.personal.tmp \
  && mv settings.json.personal.tmp settings.json.personal

# Verify
echo "✅ PAI_DIR in settings.json.personal:"
jq '.env.PAI_DIR' settings.json.personal
```

**Update ~/.bashrc:**

```bash
# Backup bashrc
cp ~/.bashrc ~/.bashrc.backup

# Update PAI_DIR
sed -i 's|export PAI_DIR="/home/walub/PAI.*"|export PAI_DIR="/home/walub/projects/Personal_AI_Infrastructure/.claude"|' ~/.bashrc

# Verify
echo "✅ PAI_DIR in ~/.bashrc:"
grep 'export PAI_DIR=' ~/.bashrc

# Source to apply to current shell
source ~/.bashrc
echo "✅ Current PAI_DIR: $PAI_DIR"
```

**Update .env if it has PAI_DIR:**

```bash
cd /home/walub/projects/Personal_AI_Infrastructure

# Check if .env has PAI_DIR
if grep -q "PAI_DIR" .env 2>/dev/null; then
  sed -i 's|PAI_DIR=.*|PAI_DIR=/home/walub/projects/Personal_AI_Infrastructure/.claude|' .env
  echo "✅ Updated PAI_DIR in .env"
  grep PAI_DIR .env
else
  echo "⏭️  No PAI_DIR in .env (OK)"
fi
```

**CHECKPOINT:** PAI_DIR should point to `/home/walub/projects/Personal_AI_Infrastructure/.claude` in all three locations.

---

### Phase 4: Rebuild ~/.claude/ Symlinks

**Remove existing symlinks:**

```bash
cd ~/.claude

# List current symlinks
echo "Current symlinks:"
ls -la | grep '^l'

# Remove symlinks (CAREFUL - only removes symlinks, not directories)
rm -f settings.json .env .mcp.json PAI.md statusline-command.sh
rm -f hooks skills commands agents

echo "✅ Old symlinks removed"
```

**Create new symlinks to Bob fork:**

```bash
cd ~/.claude

# Core config files
ln -sf /home/walub/projects/Personal_AI_Infrastructure/settings.json.personal settings.json
ln -sf /home/walub/projects/Personal_AI_Infrastructure/.env .env
ln -sf /home/walub/projects/Personal_AI_Infrastructure/.mcp.json.personal .mcp.json
ln -sf /home/walub/projects/Personal_AI_Infrastructure/statusline-command.sh statusline-command.sh

# Framework directories
ln -sf /home/walub/projects/Personal_AI_Infrastructure/.claude/PAI.md PAI.md
ln -sf /home/walub/projects/Personal_AI_Infrastructure/.claude/hooks hooks
ln -sf /home/walub/projects/Personal_AI_Infrastructure/.claude/skills skills
ln -sf /home/walub/projects/Personal_AI_Infrastructure/.claude/commands commands
ln -sf /home/walub/projects/Personal_AI_Infrastructure/.claude/agents agents

echo "✅ New symlinks created"
ls -la | grep '^l'

# Verify symlinks resolve correctly
echo ""
echo "✅ Verifying symlink targets:"
readlink -f settings.json
readlink -f hooks
readlink -f skills
```

**CHECKPOINT:** All symlinks should point to Bob fork paths.

---

### Phase 5: Verification Testing

**Test PAI_DIR resolution:**

```bash
# Source fresh environment
source ~/.bashrc

# Verify PAI_DIR
echo "PAI_DIR: $PAI_DIR"

# Check expected value
if [ "$PAI_DIR" = "/home/walub/projects/Personal_AI_Infrastructure/.claude" ]; then
  echo "✅ PAI_DIR correct"
else
  echo "❌ PAI_DIR wrong: $PAI_DIR"
fi

# Verify paths exist
test -d "$PAI_DIR" && echo "✅ PAI_DIR directory exists" || echo "❌ PAI_DIR directory missing"
test -d "$PAI_DIR/hooks" && echo "✅ hooks directory exists" || echo "❌ hooks missing"
test -d "$PAI_DIR/skills" && echo "✅ skills directory exists" || echo "❌ skills missing"
test -d "$PAI_DIR/commands" && echo "✅ commands directory exists" || echo "❌ commands missing"
```

**Test hook dependencies:**

```bash
# Test if hooks can find their dependencies
if [ -f "$PAI_DIR/../commands/load-dynamic-requirements.md" ]; then
  echo "✅ load-dynamic-requirements.md found"
else
  echo "❌ load-dynamic-requirements.md missing"
fi

# Test hook execution (dry run)
PAI_DIR="$PAI_DIR" bun $PAI_DIR/hooks/load-core-context.ts 2>&1 | head -10
```

**Verify custom skills accessible:**

```bash
echo "✅ Custom skills in runtime:"
ls -la "$PAI_DIR/skills/" | grep -E "cognitive-loop|taskman|telos|vikunja"

# Verify data is present
for skill in cognitive-loop taskman telos vikunja; do
  if [ -d "$PAI_DIR/skills/$skill/data" ]; then
    echo "✅ $skill/data: $(du -sh "$PAI_DIR/skills/$skill/data" | cut -f1)"
  else
    echo "⏭️  $skill/data: not present (OK if skill doesn't use data)"
  fi
done

# Check SKILL.md files exist
for skill in CORE cognitive-loop taskman telos vikunja; do
  test -f "$PAI_DIR/skills/$skill/SKILL.md" && echo "✅ $skill/SKILL.md" || echo "❌ $skill missing SKILL.md"
done
```

**Test Claude Code can read settings:**

```bash
# Verify settings.json is readable
echo "✅ Settings.json PAI_DIR:"
cat ~/.claude/settings.json | jq '.env.PAI_DIR'

# Verify hooks use variable paths
echo "✅ Sample hook command:"
cat ~/.claude/settings.json | jq '.hooks.SessionStart[0].hooks[0].command'
```

**CHECKPOINT:**
- ✅ PAI_DIR resolves correctly
- ✅ Hooks can find dependencies
- ✅ Custom skills visible
- ✅ Settings readable

**Now restart Claude Code and verify Bob loads without errors.**

---

### Phase 6: Clean Up Old Installation

**⚠️  ONLY AFTER CLAUDE CODE WORKS SUCCESSFULLY!**

**Archive old PAI installation:**

```bash
cd /home/walub

# Create archive
tar -czf PAI-old-installation-$(date +%Y%m%d).tar.gz PAI/

# Verify archive
ls -lh PAI-old-installation-*.tar.gz
echo "Archive contains:"
tar -tzf PAI-old-installation-*.tar.gz | head -20

# Move to safe location
mkdir -p ~/backups
mv PAI-old-installation-*.tar.gz ~/backups/

echo "✅ Old installation archived to ~/backups/"
```

**Rename (don't delete yet) old PAI:**

```bash
# Safer than deleting - rename first
mv /home/walub/PAI /home/walub/PAI.old

echo "✅ Old PAI renamed to PAI.old"
echo "   Test Claude Code for 1 week, then run:"
echo "   rm -rf /home/walub/PAI.old"
```

**CHECKPOINT:** Claude Code should still work. If not, restore from backup.

---

### Phase 7: Commit Custom Skills to Bob Fork

```bash
cd /home/walub/projects/Personal_AI_Infrastructure

# Check what's new
git status

# Add custom skills (data directories are gitignored)
git add .claude/skills/cognitive-loop/
git add .claude/skills/taskman/
git add .claude/skills/telos/
git add .claude/skills/vikunja/

# Add commands if copied
git add .claude/commands/

# Add updated .gitignore
git add .gitignore

# Commit with milestone
git commit -m "feat(project/bob): migrate custom skills to v0.6.0 structure #build-log !milestone

Migrated custom skills from legacy installation:
- cognitive-loop: Daily writing practice + Substack publishing
- taskman: ADHD-friendly task orchestration with Vikunja
- telos: Business strategy and personal compass tracking
- vikunja: Task management system integration

Updated .gitignore to protect skill data directories.
Migration to clean v0.6.0 structure complete."

# Push to your fork
git push origin main

echo "✅ Custom skills committed and pushed to Bob fork"
```

---

## Post-Migration Verification Checklist

Run through this checklist:

- [ ] Claude Code starts without hook errors
- [ ] Bob identity loads (ask "Who are you?")
- [ ] Custom skills accessible (check with Skill tool)
- [ ] CORE skill shows your personal data
- [ ] PAI_DIR environment variable correct
- [ ] Can edit skills in Bob fork, changes appear immediately
- [ ] Git status shows data directories gitignored
- [ ] Old /home/walub/PAI/ archived and renamed

---

## Troubleshooting

### "Hook errors on startup"

Check PAI_DIR:
```bash
echo $PAI_DIR
# Should be: /home/walub/projects/Personal_AI_Infrastructure/.claude
```

Test hook manually:
```bash
PAI_DIR="$PAI_DIR" bun ~/.claude/hooks/load-core-context.ts
```

### "Custom skill not found"

Verify symlink:
```bash
ls -la ~/.claude/skills
# Should point to: /home/walub/projects/Personal_AI_Infrastructure/.claude/skills
```

Check skill exists:
```bash
ls -la /home/walub/projects/Personal_AI_Infrastructure/.claude/skills/
```

### "Settings.json changes not applying"

Check symlink:
```bash
readlink -f ~/.claude/settings.json
# Should be: /home/walub/projects/Personal_AI_Infrastructure/settings.json.personal
```

Restart Claude Code completely.

---

**Next:** See `BOB_UPDATE_WORKFLOW.md` for how to sync with upstream PAI and maintain your fork.
