# Contributing Workflow for Bob

This document explains how to work with your personal Bob fork while contributing back to the upstream PAI project.

---

## 📚 Repository Architecture

You have **two repositories** linked together:

```
Your Personal Fork (GitHub)
├── URL: https://github.com/wally-kroeker/Bob
├── Local reference: origin
└── Purpose: Your personal Bob assistant + local changes

Upstream PAI (GitHub)
├── URL: https://github.com/danielmiessler/Personal_AI_Infrastructure
├── Local reference: upstream
└── Purpose: Original PAI project - receive updates from here
```

**In your local repository:**

```bash
# View your remotes
git remote -v

# Expected output:
# origin    https://github.com/wally-kroeker/Bob.git (fetch)
# origin    https://github.com/wally-kroeker/Bob.git (push)
# upstream  https://github.com/danielmiessler/Personal_AI_Infrastructure (fetch)
# upstream  https://github.com/danielmiessler/Personal_AI_Infrastructure (push)
```

---

## 🌳 Branch Strategy

### Main Branches

**`main` branch:**
- Your personal, stable version of Bob
- Contains your customizations
- What your `~/.claude/` installation uses
- Push to this branch regularly as backup

**Contribution branches:**
- Format: `contrib/feature-name` or `contrib/fix-description`
- Purpose: Changes you want to submit back to upstream PAI
- Example: `contrib/add-claude-md`, `contrib/fix-voice-server-docs`

### Branch Flow

```
┌─ main (your personal Bob)
│  ├─ CLAUDE.md
│  ├─ .gitignore (enhanced)
│  ├─ Your customizations
│  └─ Never force-push!
│
├─ contrib/add-claude-md (for upstream PR)
│  ├─ Branch from: upstream/main
│  └─ Target: Create PR to upstream
│
└─ contrib/fix-docs
   ├─ Branch from: upstream/main
   └─ Target: Create PR to upstream
```

---

## 🚀 Daily Workflows

### Workflow 1: Sync Your Fork with Upstream Updates

When upstream PAI gets updated, pull those changes into your Bob:

```bash
# Step 1: Fetch latest from upstream (doesn't change anything yet)
git fetch upstream

# Step 2: See what's new
git log HEAD..upstream/main --oneline
# Shows commits in upstream that you don't have

# Step 3: Merge upstream changes into your main
git checkout main
git merge upstream/main

# Step 4: Push to your fork (backup)
git push origin main
```

**What's happening:**
```
Before:
Your main:     A--B--C
Upstream main: A--B--C--D--E

After merge:
Your main:     A--B--C--D--E
Upstream main: A--B--C--D--E
```

**If there are conflicts:**
```bash
# Git will tell you which files conflict
# Edit the files to keep what you want
git add [fixed-files]
git commit -m "Merge: resolve conflicts with upstream/main"
git push origin main
```

---

### Workflow 2: Create a Contribution for Upstream

When you want to contribute a fix or feature back to PAI:

```bash
# Step 1: Make sure main is synced with upstream
git fetch upstream
git checkout main
git merge upstream/main

# Step 2: Create a contribution branch
git checkout -b contrib/my-feature

# Step 3: Make your changes (edit files, test, etc.)
# Example: You improve documentation, add a skill, fix a bug
nano CLAUDE.md
# ... edit file ...

# Step 4: Stage and commit your changes
git add CLAUDE.md
git commit -m "docs: improve CLAUDE.md documentation

- Added clarification on skills system
- Fixed typo in architecture section
- Expanded examples"

# Step 5: Push to YOUR fork (not upstream!)
git push origin contrib/my-feature
# This pushes to: wally-kroeker/Bob

# Step 6: Create Pull Request on GitHub
# Go to: https://github.com/wally-kroeker/Bob
# Click: "Contribute" → "Open pull request"
# Make sure:
#   - base: danielmiessler/Personal_AI_Infrastructure:main
#   - head: wally-kroeker/Bob:contrib/my-feature
# Write description and submit
```

**What's happening:**

```
Before push:
Your fork main:  A--B--C (synced with upstream)
contrib branch:  A--B--C--D (your new commit)

After push:
GitHub fork:     A--B--C
GitHub fork:     contrib/my-feature: A--B--C--D

PR created:
Base (upstream): A--B--C
Head (your fork): A--B--C--D ← "Please merge D into upstream!"
```

---

### Workflow 3: Merge Contribution Back to Your Main

After you push a contribution branch, merge it back to your main so you have it locally:

```bash
# Step 1: Switch back to main
git checkout main

# Step 2: Merge your contribution
git merge contrib/my-feature

# Step 3: Push to your fork
git push origin main

# Step 4 (Optional): Delete the contribution branch
git branch -d contrib/my-feature
git push origin --delete contrib/my-feature
# Deleting is optional - keeps things tidy
```

---

### Workflow 4: Update Main with Upstream + Your Changes

If both upstream AND your local main have changed:

```bash
# Step 1: Fetch upstream
git fetch upstream

# Step 2: Check what's different
git log HEAD..upstream/main --oneline

# Step 3: Rebase (keep your commits on top)
git checkout main
git rebase upstream/main
# OR merge (create a merge commit)
git checkout main
git merge upstream/main

# Step 4: Push (may need force if using rebase)
git push origin main
# If rebase: git push origin main --force-with-lease
```

**Rebase vs Merge explanation:**

```
Merge approach (creates merge commit):
upstream/main: A--B--C--D
your main:     A--B--E--F
After merge:   A--B--C--D--M (M = merge commit)
                    └--E--F--┘

Rebase approach (replays your commits):
upstream/main: A--B--C--D
your main:     A--B--E--F
After rebase:  A--B--C--D--E'--F' (replayed after D)
```

**Recommendation for learning:** Use `git merge` (simpler, creates visible merge commits). Rebase is more advanced.

---

## 🔄 Complete Example: Contribute a Feature

Let's walk through the complete flow:

```bash
# 1. Start with clean, synced main
git checkout main
git fetch upstream
git merge upstream/main
git push origin main

# 2. Create contribution branch
git checkout -b contrib/add-git-cheatsheet

# 3. Create the file
cat > GIT_CHEATSHEET.md << 'EOF'
# Git Cheatsheet for Bob

## Daily Commands
...
EOF

# 4. Commit the change
git add GIT_CHEATSHEET.md
git commit -m "docs: add git cheatsheet for daily reference

- Basic command reference
- Workflow examples
- Troubleshooting tips"

# 5. Push to your fork
git push origin contrib/add-git-cheatsheet

# 6. On GitHub: Create PR
#    - base: danielmiessler/Personal_AI_Infrastructure:main
#    - head: wally-kroeker/Bob:contrib/add-git-cheatsheet
#    - Title: docs: add git cheatsheet...
#    - Description: Explain what it does and why useful

# 7. Merge back to your main
git checkout main
git merge contrib/add-git-cheatsheet
git push origin main

# 8. Optional: Clean up branch
git branch -d contrib/add-git-cheatsheet
git push origin --delete contrib/add-git-cheatsheet
```

---

## 🛡️ Safety Rules

### ✅ DO:

- ✅ Create new branches for changes (`contrib/feature-name`)
- ✅ Commit frequently with clear messages
- ✅ Sync from upstream regularly (weekly recommended)
- ✅ Test locally before pushing
- ✅ Use descriptive branch names
- ✅ Push to `origin` (your fork), not `upstream`
- ✅ Create PRs from your fork to upstream

### ❌ DON'T:

- ❌ Force push to `main` (use `--force-with-lease` if needed, carefully)
- ❌ Commit API keys, `.env`, or personal data
- ❌ Push directly to `upstream` (you don't have permission anyway)
- ❌ Merge `upstream/main` without testing
- ❌ Create PRs with personal customizations (keep those local)

---

## 🚨 Common Scenarios & Solutions

### Scenario 1: "I messed up a commit"

```bash
# Undo the last commit (keep changes)
git reset --soft HEAD~1

# Or, undo and discard the commit
git reset --hard HEAD~1

# Or, revert the commit (creates new commit that undoes it)
git revert HEAD
```

### Scenario 2: "I pushed to origin by mistake"

```bash
# This is usually fine! origin is your fork
# But if you pushed to upstream, contact repo owner

# To prevent: double-check before pushing
git remote -v
```

### Scenario 3: "I have changes but can't merge from upstream"

```bash
# Commit or stash your changes first
git add .
git commit -m "WIP: work in progress"
# OR
git stash

# Then merge
git merge upstream/main

# If you stashed:
git stash pop
```

### Scenario 4: "I created PR but forgot something"

```bash
# Make the additional changes
git add [files]
git commit -m "docs: additional clarification"

# Push to the same branch
git push origin contrib/my-feature

# GitHub automatically updates the PR!
```

### Scenario 5: "Merge conflicts!"

```bash
# When you see merge conflicts:
git status
# Shows files with conflicts (marked with <<<<<<, ======, >>>>>>)

# Edit the conflicted files to fix them
nano CONFLICTED_FILE.md
# Remove <<<<<<, ======, >>>>>> markers
# Keep the version you want

# Mark as resolved
git add CONFLICTED_FILE.md

# Complete the merge
git commit -m "Merge: resolve conflicts"
```

---

## 📊 Branch Status Commands

```bash
# See all local branches
git branch -a

# See branches tracking upstream
git branch -vv

# See differences between branches
git diff main upstream/main

# See commits not yet pushed
git log origin/main..main --oneline

# See commits not yet pulled from upstream
git log main..upstream/main --oneline
```

---

## 🔗 Reference Commands

```bash
# Clone the repo (already done, for reference)
git clone https://github.com/wally-kroeker/Bob.git
cd Personal_AI_Infrastructure

# Add upstream (already done)
git remote add upstream https://github.com/danielmiessler/Personal_AI_Infrastructure

# Check remotes
git remote -v

# Create and switch to branch
git checkout -b contrib/feature-name

# Switch to existing branch
git checkout main

# List branches
git branch

# Delete branch (local)
git branch -d contrib/old-feature

# Delete branch (remote)
git push origin --delete contrib/old-feature

# Fetch without merging
git fetch upstream

# Merge a branch
git merge upstream/main

# Push to your fork
git push origin main

# Create PR (on GitHub web interface)
```

---

## 📚 Learning Resources

- [Git Documentation](https://git-scm.com/doc)
- [GitHub Fork Workflow](https://guides.github.com/activities/forking/)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [GitHub Pull Request Guide](https://docs.github.com/en/pull-requests)

---

## 🎯 Your Typical Week

```
Monday: Sync main with upstream
git fetch upstream && git merge upstream/main && git push origin main

Tuesday-Thursday: Make changes on main (personal customizations)
git add .
git commit -m "Personal change"
git push origin main

Friday: Create contribution to upstream
git checkout -b contrib/improvement
# Make changes
git push origin contrib/improvement
# Create PR on GitHub

Anytime: Sync from upstream if needed
git fetch upstream && git merge upstream/main
```

---

## ✨ Tips

1. **Commit messages matter** - Future you will thank you
   - Good: `docs: clarify Bob setup instructions`
   - Bad: `fix`

2. **Sync often** - Fewer conflicts if you merge upstream frequently

3. **Test locally** - Before pushing, verify your changes work

4. **Keep main clean** - Don't break main; use branches for experiments

5. **PRs are conversations** - Upstream maintainers may ask for changes

---

## 🆘 Got Stuck?

```bash
# See everything that happened
git log --oneline -10

# See current state
git status

# See what changed
git diff

# See staged changes
git diff --cached

# See the last commit
git show

# Revert to a known good state (use carefully!)
git reset --hard upstream/main
```

Questions? Check the specific section above or review the git cheatsheet!
