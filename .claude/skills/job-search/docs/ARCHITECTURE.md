# Job Search System Architecture

**Version**: 0.1 (Initial Design)
**Status**: In Development
**Last Updated**: 2025-12-14

---

## System Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    USER INTERACTION LAYER                    │
│  (Claude Code CLI / Daily Digest / Job Analysis Requests)   │
└────────────────────┬────────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────────┐
│                   ORCHESTRATION LAYER                        │
│  - Job Search Skill (SKILL.md)                              │
│  - Profile Manager (reads profile.md)                       │
│  - Application Tracker (applications.json)                  │
│  - Leads Pipeline (leads.json for GoodFields)               │
└────────┬──────────────────┬──────────────────┬──────────────┘
         │                  │                  │
┌────────▼─────┐  ┌─────────▼────────┐  ┌──────▼─────────────┐
│ DATA SOURCES │  │ ANALYSIS ENGINE  │  │ MATERIALS GENERATOR│
│              │  │                  │  │                    │
│ - Job Boards │  │ - Skills Match   │  │ - Resume Variants  │
│ - APIs       │  │ - Culture Fit    │  │ - Cover Letters    │
│ - Scrapers   │  │ - Compensation   │  │ - Portfolio Links  │
│ - MCP Servers│  │ - Flag Detection │  │ - Voice Matching   │
│ - RSS Feeds  │  │ - Scoring        │  │                    │
└──────────────┘  └──────────────────┘  └────────────────────┘
         │                  │                  │
         └──────────────────┴──────────────────┘
                            │
┌───────────────────────────▼──────────────────────────────────┐
│                   AUTOMATION LAYER                           │
│  - Daily Digest (cron → morning brief)                       │
│  - Follow-up Reminders (Vikunja integration)                │
│  - Pipeline Updates (applications.json tracking)             │
│  - Telos Logging (activity capture in personal.md)          │
└──────────────────────────────────────────────────────────────┘
```

---

## Core Components

### 1. Data Sources Layer

**Challenge**: Most job boards block AI scraping, many don't have official APIs.

**Multi-Strategy Approach**:

**A. Official APIs** (Preferred)
- Indeed API (if available)
- LinkedIn Jobs API (requires authentication)
- Glassdoor API (company research)
- Other board-specific APIs

**B. MCP Servers** (Emerging)
- Check for job search MCP servers
- Standardized interface if available
- Community-maintained connectors

**C. Third-Party Aggregators**
- Services that consolidate multiple boards
- Examples: RapidAPI job search endpoints, Adzuna, etc.
- Pricing vs. coverage tradeoff

**D. RSS Feeds** (Where Available)
- Many boards offer RSS for search queries
- Lightweight, doesn't trigger anti-scraping
- Limited to what boards expose

**E. Email Parsing** (Fallback)
- Indeed job alerts → structured data extraction
- Forward alerts to parsing endpoint
- Semi-manual but reliable

**F. Respectful Scraping** (Last Resort)
- Playwright/Puppeteer with rate limiting
- Human-like behavior patterns
- Only for boards without alternatives
- Respect robots.txt and terms of service

**Data Source Priorities** (Based on Research):
1. MCP servers (if they exist for job search)
2. Official APIs (Indeed, etc.)
3. Third-party aggregators (RapidAPI, Adzuna)
4. RSS feeds
5. Email alert parsing
6. Respectful scraping (last resort)

---

### 2. Profile Manager

**File**: `data/profile.md`

**Responsibilities**:
- Single source of truth for search criteria
- Skills matrix, green/red flags, preferences
- Compensation expectations, geographic limits
- Deal-breakers and values alignment

**Usage**:
- Read on skill activation
- Reference during job analysis
- Update as criteria evolve

---

### 3. Analysis Engine

**Input**: Raw job posting (URL, text, or structured data)

**Processing Pipeline**:

```python
def analyze_job(posting):
    # 1. Parse job description
    structured_data = parse_posting(posting)

    # 2. Skills matching
    skills_match = calculate_match(
        required=structured_data.requirements,
        user_skills=profile.skills_matrix
    )  # Returns % match

    # 3. Flag detection
    green_flags = detect_flags(structured_data, profile.green_flags)
    red_flags = detect_flags(structured_data, profile.red_flags)

    # 4. Culture research
    culture_fit = research_company(
        company=structured_data.company,
        sources=['glassdoor', 'linkedin', 'reddit']
    )

    # 5. Compensation benchmarking
    comp_analysis = benchmark_salary(
        role=structured_data.title,
        location=structured_data.location,
        listed_salary=structured_data.salary
    )

    # 6. Scope clarity scoring
    scope_score = assess_scope_clarity(structured_data.description)

    # 7. Overall recommendation
    recommendation = generate_recommendation(
        skills_match, green_flags, red_flags,
        culture_fit, comp_analysis, scope_score
    )

    return {
        'skills_match': skills_match,
        'green_flags': green_flags,
        'red_flags': red_flags,
        'culture_fit': culture_fit,
        'compensation': comp_analysis,
        'scope_clarity': scope_score,
        'recommendation': recommendation,
        'priority': calculate_priority()
    }
```

**Outputs**:
- Skills match percentage
- Green/red flag lists
- Culture fit score
- Compensation analysis
- Application priority (high/medium/low)
- Recommendation (apply/maybe/skip)

---

### 4. Application Materials Generator

**Inputs**:
- Job posting analysis
- User profile (skills, experience)
- Base resume content
- Voice samples (from Cognitive Loop, Telos)

**Outputs**:
- **Resume variant**: Tailored to role, highlights relevant skills
- **Cover letter**: Authentic voice, connects story to needs
- **Portfolio links**: Which projects to emphasize (FabLab, Bob, etc.)

**Key Principle**: Sound like Wally, not generic ChatGPT.

**Implementation**:
```python
def generate_cover_letter(job_analysis, profile, voice_samples):
    # 1. Extract key points from job
    key_requirements = job_analysis.top_requirements
    company_values = job_analysis.culture_research

    # 2. Match experience to requirements
    relevant_experience = match_experience(
        requirements=key_requirements,
        experience=profile.experience
    )

    # 3. Generate draft using voice samples
    draft = create_draft(
        role=job_analysis.title,
        company=job_analysis.company,
        experience=relevant_experience,
        voice_model=build_voice_model(voice_samples)
    )

    # 4. Ensure authenticity (not corporate BS)
    final = ensure_authentic_voice(draft)

    return final
```

---

### 5. Application Tracker

**File**: `data/applications.json`

**Schema**:
```json
{
  "applications": [
    {
      "id": "APP001",
      "job_id": "external-job-id",
      "company": "Example Corp",
      "role": "Security Architect",
      "job_board": "Indeed",
      "url": "https://...",
      "applied_date": "2025-12-15",
      "status": "applied",
      "next_action": "follow_up",
      "next_action_date": "2025-12-22",
      "materials_sent": {
        "resume": "resume_v3_security_focus.pdf",
        "cover_letter": "cover_example_corp.pdf",
        "portfolio_links": ["fablab", "bob"]
      },
      "notes": "Recruiter warm lead, Hayley at Affinity",
      "skills_match": 92,
      "green_flags": ["remote-friendly", "architecture-focus"],
      "red_flags": [],
      "priority": "high",
      "timeline": [
        {"date": "2025-12-15", "event": "applied"},
        {"date": "2025-12-18", "event": "recruiter_call_scheduled"}
      ]
    }
  ],
  "metadata": {
    "total_applications": 1,
    "response_rate": 0.0,
    "avg_skills_match": 92.0,
    "last_updated": "2025-12-15"
  }
}
```

**Operations**:
- Add new application
- Update status (applied → interview → offer/reject)
- Set follow-up reminders
- Track response patterns
- Generate statistics

---

### 6. Leads Pipeline (Phase 2 - GoodFields)

**File**: `data/leads.json`

**Schema**:
```json
{
  "leads": [
    {
      "id": "LEAD001",
      "company": "Manitoba SMB Example",
      "contact": "Decision Maker Name",
      "project_type": "security_assessment",
      "estimated_value": 10000,
      "source": "Rees referral",
      "status": "proposal_sent",
      "next_action": "follow_up",
      "next_action_date": "2025-12-20",
      "timeline": [
        {"date": "2025-12-02", "event": "initial_contact"},
        {"date": "2025-12-10", "event": "proposal_sent"}
      ],
      "notes": "35 employees, Office 365, fairly simple environment"
    }
  ],
  "metadata": {
    "pipeline_value": 10000,
    "active_leads": 1,
    "proposal_win_rate": 0.0
  }
}
```

---

### 7. Daily Automation

**Cron Job**: `~/.claude/skills/job-search/scripts/daily-digest.sh`

**Triggers**: Every morning (8:00 AM local time)

**Workflow**:
1. Fetch new jobs from all data sources
2. Run analysis engine on each
3. Filter to top 3-5 matches
4. Generate application materials for high-priority roles
5. Check for follow-up reminders
6. Compile morning brief
7. Display to user (or send notification)

**Morning Brief Format**:
```
MORNING BRIEF - Dec 16, 2025

JOB SEARCH STATUS:
- 3 new roles matching your criteria
- 2 follow-ups due this week
- 5 applications awaiting response (avg 4 days old)

TOP MATCH: Security Architect (Contract) - Manitoba Hydro Infrastructure
├─ Skills match: 92%
├─ Green flags: Remote-friendly, architecture focus, clear scope
├─ Red flags: None detected
├─ Compensation: $110-130/hr (market rate)
└─ Application materials: Drafted and ready for review

OTHER MATCHES:
2. IT Security Consultant - Remote Canada (85% match)
3. OT Security Specialist - Winnipeg (78% match)

FOLLOW-UPS DUE:
- Rees security assessment (8 days since quote sent)
- Josh meeting prep (tomorrow 1pm)

GOODFIELDS PIPELINE:
- 1 active lead ($10k proposal sent, awaiting response)

Ready to review roles? [Y/n]
```

---

## Integration Points

### Telos Integration
- Log job search activity in `personal.md`
- Track applications, interviews, outcomes
- Pattern recognition (what works, what doesn't)

### Vikunja Integration
- Create tasks for follow-ups
- Set due dates for application actions
- Track interview prep checklists

### Publishing Loop Integration
- Contract wins logged as milestones
- GoodFields case studies documented
- Build log updates for consulting work

### Firefly III Integration
- Track application costs (if any)
- Log contract revenue
- Financial forecasting based on pipeline

---

## Data Flow Example

**User Action**: "Bob, analyze this LinkedIn job posting" (shares URL)

```
1. User shares LinkedIn URL
   ↓
2. Job Search Skill activates
   ↓
3. Attempt to fetch job data:
   - Try LinkedIn API (if available)
   - Fall back to manual input if blocked
   ↓
4. User pastes job description text
   ↓
5. Analysis Engine processes:
   - Parse requirements
   - Calculate skills match (e.g., 85%)
   - Detect green flags (remote, architecture)
   - Detect red flags (vague scope)
   - Research company culture
   - Benchmark compensation
   ↓
6. Generate recommendation:
   - "Worth applying, but ask about on-call in screening"
   ↓
7. Draft application materials:
   - Resume variant (highlights security architecture)
   - Cover letter (authentic voice, addresses concerns)
   - Portfolio links (FabLab, Bob)
   ↓
8. Present to user for review:
   - "Here's the analysis and draft materials. Apply? [Y/n]"
   ↓
9. If approved:
   - Track in applications.json
   - Set follow-up reminder (7 days)
   - Log in Telos
   ↓
10. Daily digest includes this in "applications awaiting response"
```

---

## Implementation Phases

### Phase 0: Research & Foundation (Current)
- ✅ Skill structure created
- ✅ Profile template defined
- ✅ Architecture documented
- 🔄 Data source research in progress
- ⏳ Select data access strategy

### Phase 1: Manual Analysis (MVP)
- User pastes job descriptions
- Analysis engine processes and scores
- Application materials generator works
- Manual application tracking
- **Goal**: Functional job analysis, no automation yet

### Phase 2: Semi-Automated Tracking
- applications.json tracking works
- Follow-up reminders integrate with Vikunja
- Daily digest (manual trigger, not cron yet)
- **Goal**: Stop losing track of applications

### Phase 3: Data Source Integration
- Implement 1-2 data sources (RSS, API, or MCP)
- Automated job fetching
- Morning digest works
- **Goal**: Stop manually finding jobs

### Phase 4: Full Automation
- Cron-triggered daily digest
- Multi-source aggregation
- Application materials auto-generated
- **Goal**: Wake up to qualified opportunities daily

### Phase 5: GoodFields Pipeline
- Leads tracking (leads.json)
- Contract sourcing automation
- Proposal templates
- Revenue forecasting
- **Goal**: Build consulting practice alongside employment

---

## Technical Stack

**Languages**:
- Python (analysis, scraping, automation)
- Bash (cron jobs, system integration)
- TypeScript (if web interface needed)

**Libraries**:
- `requests` / `httpx` - API calls
- `beautifulsoup4` / `playwright` - Scraping (if needed)
- `json` - Data storage
- `anthropic` - Claude API for analysis/generation
- `feedparser` - RSS parsing (if used)

**Infrastructure**:
- Local files (applications.json, leads.json)
- Cron (daily automation)
- Claude Code CLI (user interface)
- MCP integration (if available)

**Data Storage**:
- JSON files for tracking
- Markdown for profile and documentation
- No database needed (yet)

---

## Privacy & Ethics

**Principles**:
1. **No spam applications** - Quality over quantity, only apply to genuine fits
2. **Respect terms of service** - Don't violate board policies
3. **Rate limiting** - Don't hammer servers
4. **User consent** - Wally reviews and approves all applications
5. **Data minimization** - Only store necessary information
6. **Local-first** - No cloud services unless necessary

---

## Success Metrics

**Phase 1 (Income Stability)**:
- Applications sent: Target 5-10/week
- Response rate: Track and optimize (industry avg ~20%)
- Interview conversion: Track and learn from patterns
- Time to offer: Measure efficiency
- **Primary goal**: Stable income within 1-2 months

**Phase 2 (GoodFields Contracts)**:
- Pipeline value: Track total potential revenue
- Proposal win rate: Optimize based on feedback
- Average project value: Track and increase over time
- Client satisfaction: NPS or referral rate
- **Primary goal**: $50k+ annual consulting revenue

---

## Next Steps

1. ✅ Architecture documented
2. 🔄 Review research agent findings (data sources)
3. ⏳ Select data access strategy
4. ⏳ Build Phase 1 MVP (manual analysis)
5. ⏳ Test with real job postings
6. ⏳ Iterate based on Wally feedback

---

**This architecture balances pragmatism (start simple) with vision (full automation). Build incrementally, learn continuously.**
