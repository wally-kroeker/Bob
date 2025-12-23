---
name: job-search
description: Intelligent job search and application system. Two-phase approach - Phase 1 finds stable income roles, Phase 2 sources GoodFields consulting contracts. USE WHEN user mentions job hunting, looking for work, needs income, wants contract opportunities, OR discusses employment search.
---

# Job Search - Intelligent Employment & Contract Sourcing

**Auto-activates when:** User discusses job searching, employment needs, contract opportunities, or income generation.

## Core Functionality

### Phase 1: Income Stability (Active Priority)
Find stable employment that matches your skills, values, and need for work-life boundaries.

**Focus:**
- Contract roles preferred (consulting-style, defined scope)
- Security architecture / advisory positions (NOT split operational roles)
- Remote-friendly or Winnipeg-local
- Clear goals, defined scope, ability to disconnect at end of day
- Companies that actually care about people, not just lip service

**Output:**
- Daily digest of 3-5 qualified roles
- Application materials drafted and ready for review
- Skills match scoring and culture fit analysis
- Application tracking and follow-up reminders

### Phase 2: GoodFields Contract Pipeline (Parallel/Future)
Source consulting projects that build GoodFields practice.

**Focus:**
- Security assessments, AI implementation, architecture advisory
- Project-based ($5k-$50k range)
- Manitoba preferred but remote OK
- Aligns with GoodFields positioning

**Output:**
- Weekly contract opportunity digest
- Proposal templates ready for customization
- Pipeline tracking and revenue forecasting

## File Structure

```
~/.claude/skills/job-search/
├── SKILL.md (this file)
├── data/
│   ├── profile.md (your skills, preferences, green/red flags)
│   ├── applications.json (tracking submitted applications)
│   ├── leads.json (contract opportunities for GoodFields)
│   └── resume-base.md (your base resume content)
├── scripts/
│   ├── daily-digest.sh (cron job trigger)
│   ├── analyze-job.py (job posting analysis)
│   └── generate-materials.py (resume/cover letter generator)
└── docs/
    ├── ARCHITECTURE.md (system design)
    ├── DATA-SOURCES.md (job boards, APIs, access methods)
    └── ROADMAP.md (implementation phases)
```

## On Activation

1. **Read profile** (`data/profile.md`) - your skills, preferences, deal-breakers
2. **Check application status** (`data/applications.json`) - what's in flight
3. **Review leads pipeline** (`data/leads.json`) - GoodFields contract opportunities
4. **Surface priorities**:
   - New roles matching criteria
   - Follow-ups due
   - Application materials needing review
   - Pipeline status summary

## During Conversation

### Job Analysis
When user shares a job posting:
- Parse for green/red flags
- Calculate skills match score
- Research company culture (Glassdoor, LinkedIn sentiment)
- Benchmark compensation
- Assess scope clarity (defined role vs "everything all the time")
- Draft application materials if it's a good fit

### Application Management
- Track what's been applied to (no duplicates)
- Monitor status (applied, interview, rejected, offer)
- Reminder follow-ups (1 week after application, etc.)
- Learn from patterns (what works, what doesn't)

### Materials Generation
- **Resume variants**: Tailor base resume to role requirements
- **Cover letters**: Authentic voice (not generic AI slop), connects experience to needs
- **Portfolio links**: Which projects to highlight (FabLab, Bob, etc.)
- Uses Wally's actual voice from Cognitive Loop, Telos entries

### Contract Sourcing (Phase 2)
- Monitor RFPs, project boards, consulting platforms
- Match to GoodFields capabilities
- Draft proposals using templates
- Track pipeline, win/loss analysis

## Daily Automation

**Morning digest** (triggered by cron):
```
MORNING BRIEF - [Date]

JOB SEARCH STATUS:
- X new roles matching criteria
- Y follow-ups due this week
- Z applications awaiting response

TOP MATCH: [Role Title] - [Company]
- Skills match: [Score]%
- Green flags: [List]
- Red flags: [List]
- Application materials: [Status]

ACTIONS NEEDED:
1. [Priority action]
2. [Follow-up reminder]
3. [Other items]

Ready to review roles?
```

## Integration Points

- **Telos**: Job search activity logged in personal.md
- **Vikunja**: Application follow-ups as tasks with due dates
- **Publishing Loop**: Contract wins documented as milestones
- **Firefly III**: Track application costs, contract revenue

## Success Metrics

**Phase 1:**
- Time to first interview
- Application response rate
- Quality of role matches (% meeting green flag criteria)
- Successful placement (stable income secured)

**Phase 2:**
- Contract pipeline value
- Proposal win rate
- Average project value
- GoodFields revenue growth

## Key Principles

1. **Quality over quantity** - 5 perfect-fit applications > 50 spray-and-pray
2. **Authentic voice** - Application materials sound like Wally, not ChatGPT
3. **Values alignment** - No ethical compromises for a paycheck
4. **Strategic patience** - Better to wait for right fit than take wrong role
5. **Data-driven learning** - Track what works, iterate on approach

## Current Status

- **Phase**: Initial build
- **Priority**: Data source research in progress
- **Next milestone**: v1 working with at least 2 data sources + application tracking

---

**This skill serves immediate survival (income) while building toward long-term vision (GoodFields consulting practice).**
