# Job Search Skill - Quick Start Guide

**Status**: MVP Built, Research In Progress
**Created**: 2025-12-14

---

## What We've Built So Far

### ✅ Working Right Now

1. **Profile System** (`data/profile.md`)
   - Your skills, preferences, green/red flags
   - Single source of truth for job search criteria
   - Update this to refine what you're looking for

2. **Job Analysis Tool** (`scripts/analyze-job.py`)
   - Analyzes job postings against your profile
   - Detects green flags, red flags, deal-breakers
   - Calculates skills match percentage
   - Generates apply/maybe/skip recommendation
   - **You can use this RIGHT NOW**

3. **Architecture** (`docs/ARCHITECTURE.md`)
   - Full system design documented
   - Data pipeline mapped out
   - Integration points defined

### 🔄 In Progress

- **Data Source Research** (2 parallel agents running)
  - Finding MCP servers, APIs, scraping methods
  - Evaluating third-party job aggregators
  - Canadian board-specific solutions
  - **ETA**: Results within 10-15 minutes

### ⏳ Coming Soon

- Automated job fetching from multiple boards
- Application tracking system
- Daily morning digest
- Cover letter generation
- GoodFields contract sourcing

---

## How to Use the MVP (Right Now)

### Option 1: Analyze a Job You Found

```bash
# Copy job description to clipboard, then paste it:
python ~/.claude/skills/job-search/scripts/analyze-job.py --interactive

# Or analyze from a file:
python ~/.claude/skills/job-search/scripts/analyze-job.py --file ~/job-posting.txt

# Or pass directly as argument:
python ~/.claude/skills/job-search/scripts/analyze-job.py "Job description text here..."
```

**Output Example:**
```
============================================================
JOB ANALYSIS RESULTS
============================================================

RECOMMENDATION: APPLY (Priority: high)
Reason: Strong skills match with green flags, no red flags
Overall Score: 92/100

SKILLS MATCH: 85%
Matched skills:
  ✓ Security architecture and design
  ✓ Network security (firewalls, VLANs, segmentation)
  ✓ OT/SCADA security
  ✓ Penetration testing
  ✓ AI system deployment

GREEN FLAGS (3): ✓
  ✓ remote
  ✓ architecture
  ✓ contract

RED FLAGS: None detected ✓

============================================================
```

### Option 2: Use Within Claude Code Session

Just share a job posting with me (paste text or URL) and say:

**"Bob, analyze this job for fit"**

I'll run the analysis tool and give you the breakdown.

---

## File Structure

```
~/.claude/skills/job-search/
├── SKILL.md                    # Skill definition (auto-activates)
├── README.md                   # This file
├── data/
│   ├── profile.md              # Your job search criteria ← EDIT THIS
│   ├── applications.json       # Coming soon (application tracking)
│   ├── leads.json              # Coming soon (GoodFields contracts)
│   └── last-analysis.json      # Last job analyzed (auto-saved)
├── scripts/
│   ├── analyze-job.py          # Job analysis tool ← USE THIS NOW
│   ├── daily-digest.sh         # Coming soon
│   └── generate-materials.py   # Coming soon
└── docs/
    ├── ARCHITECTURE.md         # System design
    ├── DATA-SOURCES.md         # Research findings (in progress)
    └── ROADMAP.md              # Implementation phases
```

---

## Customizing Your Profile

Edit `~/.claude/skills/job-search/data/profile.md` to refine your search criteria:

**Key sections to customize:**
- **Skills Matrix**: Add/remove skills you want to match
- **Green Flags**: What you're looking for in roles
- **Red Flags**: What makes you skip a posting
- **Deal-Breakers**: Automatic no's
- **Compensation Expectations**: Update your rate/salary targets
- **Geographic Preferences**: Remote/Winnipeg/Other

**After editing**, the analysis tool will use your updated criteria immediately.

---

## What Happens Next

### Phase 1: Research Complete (ETA: Today)
- Review data source research findings
- Select 1-2 data sources to implement first
- Decide: Official APIs vs. third-party aggregators vs. RSS feeds

### Phase 2: Automated Job Fetching (ETA: This Week)
- Connect to selected data sources
- Fetch new jobs daily matching your criteria
- Filter using analysis engine

### Phase 3: Application Tracking (ETA: This Week)
- Track what you've applied to
- Set follow-up reminders
- Monitor response patterns

### Phase 4: Morning Digest (ETA: Next Week)
- Cron job runs daily
- Email/CLI digest with top 3-5 matches
- Application materials pre-generated

### Phase 5: GoodFields Pipeline (ETA: After Phase 1 Employment)
- Contract opportunity sourcing
- Proposal generation
- Revenue tracking

---

## Quick Commands

```bash
# Analyze a job
python ~/.claude/skills/job-search/scripts/analyze-job.py --interactive

# View your profile
cat ~/.claude/skills/job-search/data/profile.md

# Edit your profile
code ~/.claude/skills/job-search/data/profile.md
# or
vim ~/.claude/skills/job-search/data/profile.md

# Check last analysis
cat ~/.claude/skills/job-search/data/last-analysis.json | jq
```

---

## Integration with Bob

This skill auto-activates when you mention:
- "job search"
- "looking for work"
- "analyze this job"
- "contract opportunities"

Just ask me to help with job search and I'll use this system.

---

## Current Status Summary

**What works now:**
- ✅ Manual job analysis (paste posting → get recommendation)
- ✅ Profile-based matching
- ✅ Green/red flag detection
- ✅ Skills matching
- ✅ Deal-breaker detection

**What's coming:**
- 🔄 Data source integration (research in progress)
- ⏳ Automated job fetching
- ⏳ Application tracking
- ⏳ Cover letter generation
- ⏳ Daily digest automation

---

## Need Help?

**Within Claude Code session:**
- "Bob, how do I use the job search system?"
- "Bob, analyze this job posting: [paste text]"
- "Bob, what's the status of job search automation?"

**Direct usage:**
```bash
python ~/.claude/skills/job-search/scripts/analyze-job.py --help
```

---

**You can start using the analysis tool right now while we wait for research to complete and build out the automation.**
