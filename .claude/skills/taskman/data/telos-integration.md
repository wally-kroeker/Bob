# TaskMan ↔ Telos Integration Guide

**Purpose:** Connect TaskMan task execution with Telos strategic planning
**Status:** Active integration enabled
**Last Updated:** 2025-11-28

---

## Integration Overview

TaskMan operates in three layers:

1. **Strategic Planning** (Telos) → Define goals, risks, active leads
2. **Task Execution** (TaskMan) → Create and complete Telos-aligned tasks
3. **Strategic Documentation** (Telos LOG) → Record wins and learnings

This integration ensures every task drives measurable progress toward Telos goals.

---

## Automatic Context Loading

When TaskMan skill activates, it automatically loads Telos context:

### Files Loaded on Activation
- `~/.claude/skills/telos/data/goodfields.md` (GoodFields business strategy)
- `~/.claude/skills/telos/data/fablab.md` (FabLab infrastructure goals)
- `~/.claude/skills/telos/data/personal.md` (Personal goals & life balance)

### What Bob Understands from Telos
```
GoodFields Strategy:
- G1: Land first client by Nov 15 (CRITICAL - severance deadline)
- G2: $10k/month recurring by March 1
- G3: Privacy-first consultant reputation
- G4: Repeatable service offerings

Active Leads (with next action dates):
- Manitoba Hydro (decision expected Nov 28-29)
- Circuit & Chisel (warm lead, door open)
- Rees Security Assessment (quote due next week)
- Mario (follow-up next week)

Risk Register (Priority Order):
- R1: Severance runs out in ~10 weeks (HIGHEST)
- R2: No client pipeline or recurring revenue
- R3: Rejection sensitivity delays outreach
- R4: Unclear service positioning
```

---

## Priority Framework (Telos-Aligned)

### Priority 5 (Blocker)
**Tasks blocking Telos R1 (GoodFields first client revenue)**

Direct impact on G1 deadline (Nov 15) or revenue urgency:
- "Manitoba Hydro interview prep"
- "Create Rees security assessment quote"
- "CRA business registration"
- "Client proposal deadline"

**Signal phrases:** "urgent", "ASAP", "client deadline", "[active lead name]"

### Priority 4 (Critical)
**Tasks addressing Telos R1-R3 (client pipeline, positioning, rejection sensitivity)**

Drive needle toward first client and clear positioning:
- "Client outreach follow-up"
- "Service positioning document"
- "GoodFields website/branding"
- "Warm lead [name] next action"

**Signal phrases:** "client", "warm lead", "outreach", "positioning"

### Priority 3 (High)
**FabLab infrastructure + GoodFields capability building**

Build expertise and proof-of-concept for consulting:
- "Sovereign Mesh Phase [X] implementation"
- "Infrastructure documentation"
- "FabLab security project"
- "Demo setup for client"

**Signal phrases:** "Sovereign Mesh", "infrastructure", "FabLab", "documentation"

### Priority 2 (Medium)
**Personal maintenance, learning, steady progress**

Support personal sustainability and skill growth:
- "Health routine" (exercise, sleep)
- "Housework/YardWork"
- "Learning task"
- "Personal project (non-urgent)"

**Signal phrases:** "health", "personal", "learning", "house"

### Priority 1 (Low)
**Nice-to-have, long-term aspirational**

Backlog items, creative projects, future exploration:
- "WookieFoot lyrics transcription"
- "Community building"
- "Someday/backlog"
- "Research (non-urgent)"

**Signal phrases:** "someday", "when I get to it", "creative", "backlog"

---

## Task Creation with Telos Alignment

### Bob's Decision Process for Priority Assignment

When creating a task, Bob asks:

```
1. Does this directly block GoodFields G1 (first client by Nov 15)?
   YES → Priority 5 (Blocker)

2. Does this address GoodFields R1-R3 urgently?
   YES → Priority 4 (Critical)

3. Does this build FabLab capability or address FabLab risks?
   YES → Priority 3 (High)

4. Is this personal maintenance or learning?
   YES → Priority 2 (Medium)

5. Everything else
   → Priority 1 (Low)
```

### Task Creation Template with Telos Context

```javascript
mcp__vikunja__vikunja_tasks({
  subcommand: 'create',
  projectId: 12,  // GoodFields/Business Development
  title: 'Create security assessment quote for Rees client',
  priority: 5,    // P5: Blocks R1 (first client revenue)
  description: `CONTEXT: First consulting engagement opportunity. Client has 35 employees, 35 PCs, few servers, Office 365 cloud. Rees will markup and present to client.

SUCCESS CRITERIA: Complete quote with scope, deliverables, timeline, pricing. Template ready for future assessments (addresses G4).

TIME ESTIMATE: 2-3 hours (research assessment types, build pricing model, document methodology)

DEPENDENCIES: Need to clarify with Rees: full environment scope, what prompted request, deliverable expectations, tooling requirements.

TELOS ALIGNMENT: GoodFields G1 (first client by Nov 15), R1 (revenue urgency), G4 (repeatable offerings)`,
  dueDate: '2025-12-06T23:59:59Z',  // "Next week"
  labels: [4, 11, 14, 18],  // Work, AdminWork, Computer, Important
  assignees: [3]  // Bob (Orchestrator) or delegate to Mario (Engineer)
})
```

### Key Template Sections

**CONTEXT:** Why this matters
- Link to Telos goal or risk
- Business impact if not done
- Why it's urgent (deadline or lead opportunity)

**SUCCESS CRITERIA:** How you know it's done
- Specific deliverables
- Quality standards
- Measurable completion

**TIME ESTIMATE:** How long it takes
- Helps with workload planning
- Supports ADHD executive function
- Enables "I have 30 min" queries

**DEPENDENCIES:** What's blocking/unlocked
- What needs to happen first
- What this unblocks next
- Clarifications needed

**TELOS ALIGNMENT:** Strategic significance
- Which goal (G1-G4)
- Which risk (R1-R4)
- Business impact statement

---

## Telos → TaskMan → Telos LOG Workflow

### Strategic Loop Example

```
1. TELOS PLANNING (strategic overview)
   - GoodFields R1: Severance deadline urgent
   - Active lead: Manitoba Hydro (decision Nov 28-29)
   - Action: Prepare interview

2. TASKMAN CREATION (execution plan)
   - Create P5 task: "Prepare Manitoba Hydro interview"
   - Assign to Bob (Orchestrator)
   - Due: 2025-11-28 EOD
   - Labels: Work, DeepWork, Computer, Important
   - Description includes Telos alignment

3. TASK EXECUTION
   - Bob/Bill research company, prepare talking points
   - Create presentation/talking points
   - Mark task complete

4. TELOS LOG UPDATE (strategic documentation)
   - Update goodfields.md CURRENT STATE
   - Document outcome: "Manitoba Hydro interview completed Nov 28"
   - Record learnings: What went well, pain points
   - Strategic significance: "Addresses R1 urgency, moves toward G1 deadline"
   - Next actions: "Expect decision within 48 hours"
```

---

## Cache Queries for Telos-Aware Views

### High-Priority Tasks (P4-P5: GoodFields R1)
```sql
SELECT t.id, t.title, t.project_name, t.priority, t.due_date
FROM tasks t
WHERE t.done = false
  AND t.priority >= 4  -- P4-P5: GoodFields urgency
  AND t.project_name LIKE 'GoodFields%'
ORDER BY t.priority DESC, t.due_date ASC
LIMIT 10;
```

Result: Shows all GoodFields tasks blocking R1 (first client) → Bob focuses here first

### FabLab Infrastructure Tasks (P3: Capability Building)
```sql
SELECT t.id, t.title, t.project_name, t.priority
FROM tasks t
WHERE t.done = false
  AND t.priority = 3  -- P3: High but not urgent
  AND t.project_name LIKE 'FabLab%' OR t.project_name LIKE 'Sovereign Mesh%'
ORDER BY t.due_date ASC;
```

Result: Shows all FabLab/Sovereign Mesh tasks → Build infrastructure in parallel with business

### Personal Task Balance Check
```sql
SELECT
  CASE
    WHEN t.project_name LIKE 'GoodFields%' THEN 'GoodFields'
    WHEN t.project_name LIKE 'FabLab%' THEN 'FabLab'
    WHEN t.project_name LIKE 'Personal%' THEN 'Personal'
    ELSE 'Other'
  END as area,
  COUNT(*) as completed_this_week,
  ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM tasks WHERE done = true AND done_at > date('now', '-7 days')), 1) as percent
FROM tasks t
WHERE t.done = true
  AND t.done_at > date('now', '-7 days')
GROUP BY area
ORDER BY completed_this_week DESC;
```

Result: If GoodFields >> Personal, suggest balance restoration

### Active Lead Task Tracking
```sql
SELECT t.id, t.title, t.priority, t.due_date
FROM tasks t
WHERE t.done = false
  AND (t.title LIKE '%Manitoba Hydro%'
    OR t.title LIKE '%Circuit & Chisel%'
    OR t.title LIKE '%Rees%'
    OR t.title LIKE '%Mario%')
  AND t.project_name LIKE 'GoodFields%'
ORDER BY t.due_date ASC;
```

Result: Shows all tasks related to active leads → Keeps pipeline visible

---

## Integration with Agent Assignment

When assigning work to agents, align with Telos:

```javascript
// GoodFields business task → Strategic
mcp__vikunja__vikunja_tasks({
  subcommand: 'assign',
  id: taskId,
  assignees: [5]  // Mario (Practical execution)
})

// Architecture/design task → Planning
mcp__vikunja__vikunja_tasks({
  subcommand: 'assign',
  id: taskId,
  assignees: [4]  // Bill (Architect)
})

// Strategic thinking task → Long-term view
mcp__vikunja__vikunja_tasks({
  subcommand: 'assign',
  id: taskId,
  assignees: [40]  // Homer (Strategist)
})
```

---

## Telos Context Activation Triggers

Bob automatically loads Telos context when user says:

### Explicit Telos References
- "what's blocking my goals"
- "show me priorities"
- "GoodFields tasks"
- "FabLab tasks"
- "align with Telos"

### Active Lead References
- "Manitoba Hydro"
- "Circuit & Chisel"
- "Rees"
- "warm lead"
- "client"

### Strategic Keywords
- "first client"
- "revenue"
- "deadline"
- "infrastructure"
- "blocking"

### Implicit (Bob decides to load automatically)
- Creating high-priority (P4-P5) task
- Task mentions client, lead, or business
- Week contains active lead deadline
- Work/life balance seems skewed

---

## Monthly Review: Telos ↔ TaskMan Sync

At end of each month, Bob should:

1. **Review Telos LOG** (strategic document)
   - What was accomplished toward G1-G4?
   - Which risks (R1-R4) were addressed?
   - Major learnings or pivots?

2. **Check TaskMan Completion** (execution record)
   - How many P4-P5 tasks completed?
   - P3 (FabLab) progress?
   - Personal/balance tasks maintained?

3. **Update Next Month's Telos**
   - Adjust priorities based on results
   - Update active leads status
   - Reset priorities for new month

4. **Document in Publishing Loop**
   - Milestones tagged with #build-log go to wallykroeker.com
   - Strategic wins documented in project timeline

---

## Key Principles

1. **Every P5 task is Telos-critical** - Explain why in description
2. **P3+ tasks should add Telos alignment** - Document strategic value
3. **Personal tasks (P2) maintain sustainability** - Don't skip for work
4. **Monthly sync keeps plans realistic** - Adjust based on execution data
5. **LOG updates create strategic narrative** - Telos captures wins
6. **Agent assignments enable delegation** - Multi-agent teams work faster

---

**TaskMan ↔ Telos Integration v1.0**
Created: 2025-11-28
Scope: GoodFields (G1-G4, R1-R4), FabLab (G1-G4), Personal balance
