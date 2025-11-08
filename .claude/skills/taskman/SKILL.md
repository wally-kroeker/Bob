---
name: taskman
description: Intelligent task orchestration for ADHD-friendly productivity. Natural language task capture with automatic project routing, date parsing, priority assignment, and 15-min breakdown. Integrates with Vikunja via MCP. USE WHEN user mentions 'task', 'todo', 'what should I work on', 'add task', 'break down', or ANY task management request.
---

# TaskMan - Intelligent Task Orchestrator

> **PRIMARY SKILL FOR TASK MANAGEMENT**
> This is the user-facing AI intelligence layer that activates on all task queries.
> For technical implementation details (MCP tools, database queries), refer to the `vikunja` skill documentation.

## When to Activate This Skill

**ACTIVATE IMMEDIATELY when user mentions any of these:**

### Task Management Requests
- "add task", "create task", "new task"
- "break down this task", "split this up"
- "what should I work on", "next task"
- "add to my todo list"

### Natural Language with Dates
- "by end of weekend", "tomorrow at 2pm"
- "next Friday", "in 3 days", "every Tuesday"

### Project Organization
- "create project for X", "add to Y project"
- "new client project", "yard work tasks"

### Priority/Urgency
- "urgent", "ASAP", "high priority"
- "when I get to it", "someday"

### ADHD Support
- "I'm stuck", "need an easy win"
- "build momentum", "quick task"

### Context Questions
- "what's due today", "overdue tasks"
- "balance check", "too much work tasks"

---

## Overview

TaskMan is Bob's task intelligence layer. Natural language → structured Vikunja tasks.

**Core capabilities:**
- Natural language date parsing (you understand "end of weekend" natively)
- ADHD-optimized priority (easy tasks first for momentum)
- Intelligent project routing (existing vs new)
- 15-min task breakdown
- Context-aware suggestions (time + energy + due date)
- Multi-area balance (work/personal/learning)

**Technical stack:**
- Vikunja via MCP tools (mcp__vikunja__*)
- SQLite cache for fast queries (`~/.claude/skills/taskman/data/taskman.db`)
- No N8N dependency (deprecated)
- AI-native intelligence (reasoning from examples, not scripts)

---

## 💾 Cache Usage Strategy

**CRITICAL: Always check cache before answering task-related queries!**

### Cache Checking Protocol

Before answering ANY task question ("what should I work on", "show tasks", etc.):

1. **Check if cache exists:**
   ```bash
   test -f ~/.claude/skills/taskman/data/taskman.db
   ```
   If missing: "I need to build the task cache first. Please run `/taskman-refresh`"

2. **Check cache staleness:**
   ```sql
   SELECT value FROM cache_metadata WHERE key='last_sync'
   ```
   Calculate age from current time

3. **Staleness decision tree:**
   - **< 1 hour old**: Proceed with queries (fresh enough)
   - **1-3 hours old**: Warn but allow: "Cache is X hours old. Results may be slightly stale. Want to /taskman-refresh first?"
   - **> 3 hours old**: Strongly recommend: "Cache is X hours old. I recommend /taskman-refresh for accurate results."
   - **No sync timestamp**: Require: "Cache metadata missing. Please run /taskman-refresh"

### Common Queries

Use these SQL patterns for task questions:

**"What should I work on next?" (ADHD-optimized)**
```sql
SELECT
    t.id,
    t.title,
    t.project_name,
    t.priority,
    t.due_date,
    (SELECT GROUP_CONCAT(l.name, ', ')
     FROM task_labels tl
     JOIN labels l ON tl.label_id = l.id
     WHERE tl.task_id = t.id) as labels
FROM tasks t
WHERE t.done = false
  AND t.parent_task_id IS NULL
ORDER BY
  CASE WHEN t.due_date IS NOT NULL AND t.due_date < date('now', '+3 days')
       THEN 0 ELSE 1 END,  -- Urgent items first
  t.priority DESC,           -- Then by priority
  t.due_date ASC            -- Then by due date
LIMIT 10;
```

**"What's my workload this week?"**
```sql
SELECT
    project_name,
    COUNT(*) as task_count,
    SUM(CASE WHEN priority >= 4 THEN 1 ELSE 0 END) as high_priority_count
FROM tasks
WHERE done = false
  AND due_date BETWEEN date('now') AND date('now', '+7 days')
  AND project_name IS NOT NULL
GROUP BY project_name
ORDER BY high_priority_count DESC, task_count DESC;
```

**"Show me [Label] tasks"**
```sql
SELECT
    t.id,
    t.title,
    t.project_name,
    t.priority,
    t.due_date,
    l.hex_color as label_color
FROM tasks t
JOIN task_labels tl ON t.id = tl.task_id
JOIN labels l ON tl.label_id = l.id
WHERE l.name = ?
  AND t.done = false
ORDER BY t.priority DESC, t.due_date ASC;
```

**"Tasks due soon"**
```sql
SELECT id, title, project_name, priority, due_date
FROM tasks
WHERE done = false
  AND due_date BETWEEN date('now') AND date('now', '+3 days')
ORDER BY due_date ASC, priority DESC;
```

**"Get label ID by name" (for applying labels via MCP)**
```sql
SELECT id, name, hex_color, description
FROM labels
WHERE name = ?;
```

**"List all available labels"**
```sql
SELECT id, name, hex_color, description
FROM labels
ORDER BY name;
```

### Query Helper Script

For convenience, use: `~/.claude/scripts/taskman-query.sh <command>`

Commands:
- `stats` - Cache statistics and overview
- `next-tasks [N]` - Next N tasks to work on
- `workload-this-week` - Tasks due this week by project
- `project "Name"` - Tasks for specific project
- `by-label "Label"` - Tasks with specific label
- `due-soon [days]` - Tasks due in next N days
- `high-priority` - Priority 4+ tasks
- `parents` - Parent tasks with subtasks
- `cache-age` - How old is the cache
- `sql "query"` - Run raw SQL

### When to Use MCP vs Cache

**Use SQLite Cache for:**
- ✅ Querying/reading tasks
- ✅ "What should I work on" questions
- ✅ Filtering, searching, statistics
- ✅ Planning and context switching
- ✅ Any query over > 20 tasks

**Use MCP Tools for:**
- ✅ Creating new tasks
- ✅ Updating task details
- ✅ Marking tasks complete
- ✅ Real-time operations
- ✅ Anything that modifies data

**IMPORTANT:** After creating/updating tasks via MCP, remind user to `/taskman-refresh` when convenient to update cache.

---

## 🗂️ Vikunja Data Model Reference

**Projects:**
- Hierarchical: parent_project_id enables nesting
- Every task MUST belong to one project
- Archive completed projects (don't delete)

**Tasks:**
- project_id: Required (which project)
- dueDate: ISO 8601 UTC ("2024-12-31T23:59:59Z")
- priority: 5=highest, 1=lowest, 0=unset (INVERTED!)
- labels: Cross-cutting tags (context, type, location)

**Current hierarchy:**
```
Inbox (id: 1) - Ambiguous/temporary
Personal (id: 4)
├── Housework (id: 8)
├── YardWork (id: 9)
└── Health & Fitness (id: 10)
Work (id: 5)
├── Clients (id: 11)
├── Business Development (id: 12)
└── Operations (id: 13)
Learning (id: 6)
└── Technical Skills (id: 14)
Projects (id: 7)
├── Bob (id: 15)
└── wallykroeker.com (id: 16)
```

(Synced from: `~/.claude/skills/taskman/data/project-hierarchy.md`)

---

## 📅 Natural Language Date Parsing

**You (Claude) natively understand temporal language. Parse naturally and convert to ISO 8601 UTC.**

### Process
1. Parse date phrase using your understanding
2. Check current date/time from <env> tags
3. Confirm interpretation with user
4. Convert to ISO 8601 UTC format
5. Pass to MCP: `dueDate: "2024-11-10T23:59:59Z"`

### Common Patterns

**Relative dates:**
- "tomorrow" → Next day 23:59:59
- "next Tuesday" → Coming Tuesday 23:59:59
- "in 3 days" → Today + 3 days 23:59:59

**End-of periods:**
- "end of weekend" → Sunday 23:59:59
- "end of week" → Friday 23:59:59 (or Sunday if user prefers)
- "end of month" → Last day of month 23:59:59

**Specific dates:**
- "Dec 25" → 2024-12-25 23:59:59
- "next Friday" → Coming Friday 23:59:59

**With time:**
- "tomorrow at 2pm" → Next day 14:00:00
- "Monday at 9am" → Coming Monday 09:00:00

**Recurring:**
- "every day" → {repeatAfter: 1, repeatMode: "day"}
- "every Tuesday" → {repeatAfter: 1, repeatMode: "week"}
- "every 2 weeks" → {repeatAfter: 2, repeatMode: "week"}

### Time Defaults
- No time specified → 23:59:59 (end of day)
- "morning" → 09:00:00
- "afternoon" → 14:00:00
- "evening" → 18:00:00
- Business days → Skip weekends

### Examples

<example>
User: "Trim hedges by end of weekend"
Current: Thursday November 7, 2024 10:30 AM PST

Parse:
- "end of weekend" = Sunday November 10
- No time = 23:59:59
- PST = UTC-8
- ISO: "2024-11-11T07:59:59Z"

Confirm:
"Setting due date to Sunday, November 10th at 11:59 PM"

Create:
mcp__vikunja__vikunja_tasks({
  projectId: 9,  // YardWork
  title: "Trim hedges",
  dueDate: "2024-11-11T07:59:59Z"
})
</example>

<example>
User: "Client call tomorrow at 2pm"
Current: Thursday November 7, 2024

Parse:
- "tomorrow at 2pm" = Friday November 8, 14:00:00
- ISO: "2024-11-08T22:00:00Z" (PST to UTC)

Confirm:
"Due: Friday, November 8th at 2:00 PM"
</example>

### Learning Pattern
After successful date parsing, note user preferences in:
`~/.claude/skills/taskman/data/date-patterns.md`

Example entry:
```
2024-11-07: User confirmed "end of weekend" = Sunday (not Saturday)
```

---

## ⚡ Priority Assignment (ADHD-Optimized)

**Vikunja priority scale (INVERTED):**
- **5** = HIGHEST (do now!)
- **3** = MEDIUM
- **1** = LOWEST (do last)
- **0** = Unset

### ADHD Momentum Principle

**For task breakdown:**
🟢 Easy subtask → Priority 5 (build momentum!)
🟡 Medium subtask → Priority 3 (sustain)
🔴 Hard subtask → Priority 1 (do after momentum)

**Exception:** Client urgency overrides difficulty ordering

### Urgency Detection

**Analyze user input for urgency signals:**

**High priority (5):**
- "urgent", "ASAP", "high priority", "critical"
- "client deadline", "due today", "by end of day"
- "emergency", "immediately"

**Low priority (1):**
- "someday", "when I get to it", "low priority"
- "nice to have", "backlog", "maybe"

**Context-based:**
- Client work + near deadline → Priority 5
- Personal health/safety → Priority 4-5
- Learning with deadline → Priority 4
- Nice-to-have improvements → Priority 1

### Examples

<example>
User: "Prepare urgent client deck for tomorrow's call"

Detect:
- "urgent" keyword
- "client" context
- "tomorrow" near deadline

Parent: Priority 5 (HIGHEST)

Breakdown with ADHD:
- Review notes (easy) → Priority 5 (do first!)
- Draft recommendations (hard) → Priority 5 (urgent override!)
- Polish slides (easy) → Priority 5 (urgent override!)

Explain: "All Priority 5 - client urgency overrides usual momentum ordering"
</example>

<example>
User: "Someday add feature to sort by tags"

Detect:
- "someday" keyword → Low priority

Assign: Priority 1 (LOWEST)
Explain: "Low priority - 'someday' indicates this is backlog"
</example>

### Learning Pattern
Document urgency cues in:
`~/.claude/skills/taskman/data/priority-patterns.md`

---

## 🗂️ Project Routing Intelligence

### Decision Process

1. **Extract context** from user input
   - Keywords (client names, areas)
   - Scope (one-off vs multi-step vs major initiative)
   - Area (Personal/Work/Learning/Projects)

2. **Search existing projects**
   ```javascript
   mcp__vikunja__vikunja_projects({
     subcommand: 'list',
     search: 'keyword'
   })
   ```

3. **Decide placement**
   - Perfect match? → Use existing
   - New client? → Ask: Create Work/Clients/[Name]?
   - Area match? → Use area project (YardWork, etc)
   - Major initiative? → Ask: Create dedicated project?
   - Ambiguous? → Use Inbox (can move later)

4. **Create if needed** (with user confirmation)
   ```javascript
   mcp__vikunja__vikunja_projects({
     subcommand: 'create',
     title: 'Project Name',
     parentProjectId: X  // Under appropriate root
   })
   ```

### Examples

<example>
User: "Trim front hedges this weekend"

Context:
- "hedges" → YardWork keyword
- "trim" → Maintenance task
- Scope: Single weekend

Search: "yard" projects → YardWork exists (id: 9)

Decision: Use existing YardWork

Response:
"Adding to Personal/YardWork project."
</example>

<example>
User: "Need to prep strategy deck for TechCorp call"

Context:
- "TechCorp" → New client name
- "strategy deck" → Client deliverable
- Scope: Multi-task project

Search: "TechCorp" → No results

Decision: New client project needed

Response:
"I don't see a TechCorp project. Create new client project under Work/Clients/TechCorp?"

User: "Yes"

Create:
mcp__vikunja__vikunja_projects({
  subcommand: 'create',
  title: 'TechCorp',
  parentProjectId: 11,  // Work/Clients
  description: 'TechCorp consulting engagement'
})
</example>

### Project Patterns
Reference learned mappings:
`~/.claude/skills/taskman/data/project-patterns.md`

Example patterns:
```
yard|garden|outdoor → YardWork (id: 9)
client prep|strategy → Work/Clients/[Name]
bob|pai|skill → Projects/Bob (id: 15)
```

---

## 🔨 Task Breakdown (ADHD Principles)

### Breakdown Process

1. **Analyze complexity**
   - Simple task (<15 min) → Don't break down
   - Medium task (15-60 min) → Break into 2-3 subtasks
   - Complex task (>60 min) → Break into 4-6 subtasks

2. **Create subtasks**
   - 5-30 min each
   - Clear action verbs
   - Difficulty: 🟢 easy, 🟡 medium, 🔴 hard

3. **Order for momentum**
   - Start easy (quick win!)
   - Build to medium
   - Hard tasks after momentum

4. **Assign priorities**
   - Easy → Priority 5
   - Medium → Priority 3
   - Hard → Priority 1
   - (Unless urgent overrides)

5. **Create in Vikunja**
   - Parent task with 🎯 emoji
   - Subtasks with 🤖 emoji
   - Create relations (parent/child)

### Example Breakdown

<example>
User: "Build chicken coop for 12 hens"

Analyze:
- Major construction project
- Multi-week scope
- 6-8 hours total work

Break down:
🎯 Build chicken coop (Parent, project: YardWork/Chicken Coop)
├── 🤖🟢 Research coop designs (20 min, Priority: 5, Computer)
├── 🤖🟡 Design layout & materials (45 min, Priority: 3, Computer)
├── 🤖🟢 Purchase materials (60 min, Priority: 5, Errands)
├── 🤖🔴 Build foundation (3 hrs, Priority: 1, YardWork)
├── 🤖🔴 Install walls & roof (2 hrs, Priority: 1, YardWork)
└── 🤖🟢 Finishing touches (1 hr, Priority: 5, YardWork)

Order explanation:
"Starting with easy research (quick win!), then design (creative),
then easy purchase trip. After momentum built, tackle hard
construction work. End with easy finishing for satisfaction."

Create:
1. Parent task
2. Subtasks with relations
3. Labels: YardWork, DeepWork (for construction)
4. Due dates if mentioned
</example>

---

## 🎯 Context-Aware Suggestions

### "/next-task" Logic

**Consider multiple factors:**
1. **Due dates** - Overdue? Due today? Due soon?
2. **Priority** - Priority 5 tasks first
3. **Time of day** - Morning → DeepWork, Afternoon → QuickWins
4. **Energy level** - High focus → Hard tasks, Low → Easy tasks
5. **Location** - Computer available? Phone only?
6. **Balance** - Too many work tasks? Suggest personal

### Time of Day Profiles

**Morning (8am-11am):**
- DeepWork, CreativeWork
- Projects/Bob tasks
- Learning tasks
- High focus available

**Midday (11am-2pm):**
- Client work
- AdminWork
- Medium focus tasks

**Afternoon (2pm-5pm):**
- QuickWins
- Phone tasks
- Errands
- Easy momentum builders

**Evening (5pm+):**
- Personal tasks
- YardWork, Housework
- Low cognitive load

### Example Suggestion

<example>
User: "What should I work on?"

Current: Thursday 9:15am, Computer available

Analyze:
- Time: Morning → Good for DeepWork
- Due today: "Review GoodFields notes" (Priority: 5)
- Also available: "Continue Bob taskman" (Priority: 3)

Suggest:
"TOP PRIORITY (Due today, Priority 5):
🔴 Review GoodFields meeting notes (15 min, Computer)
- Due: Today 5pm
- Part of urgent client prep for tomorrow
- Quick win to start your day!

ALSO GOOD (Projects work):
🟡 Continue Bob taskman skill (45 min, DeepWork)
- No deadline, but perfect morning focus time
- Projects area (you've done lots of client work this week)

Recommendation: Knock out that GoodFields review first (15 min!),
then dive into Bob project with clear mind."
</example>

---

## ⚖️ Multi-Area Balance

### Track Activity Across Root Projects

**Monitor weekly:**
- Personal tasks completed
- Work tasks completed
- Learning tasks completed
- Projects tasks completed

### Balance Reminders

**Trigger when:**
- >80% work tasks, <20% personal (5+ days)
- Zero learning tasks (7+ days)
- Specific project neglected (14+ days)

**Suggest:**
- Personal QuickWin (15 min recharge)
- Learning task (skill investment)
- Neglected project task (keep momentum)

### Example Balance Check

<example>
Bob proactive check (end of day):

Analysis:
- This week: 12 Work tasks, 0 Personal, 1 Learning
- Work/life ratio: 92% work
- Personal projects: Last activity 8 days ago

Reminder:
"Balance check: You've crushed 12 work tasks this week,
but zero personal tasks in 5 days. Sustainable performance
needs balance!

Quick personal win?
- Personal/Health: Evening walk (15 min)
- Personal/YardWork: Water plants (10 min)

Your choice, but your future self will thank you!"
</example>

---

## 🧠 Learning System

### After Each Task Creation

**Note patterns in data files:**

**date-patterns.md:**
- User confirmed "end of weekend" = Sunday
- User prefers 23:59:59 for date-only tasks
- Business days: Mon-Fri only

**priority-patterns.md:**
- "Client deadline" always Priority 5
- "Someday" always Priority 1
- User overrode: Made easy task Priority 3 (noted why)

**project-patterns.md:**
- "Yard" keywords → YardWork project
- "Client [Name]" → Work/Clients/[Name]
- User created new project for X (scope threshold learned)

### Reference Patterns

**Before creating tasks:**
Read relevant pattern files for learned preferences

**After corrections:**
Update pattern files with new learnings

---

## 🔄 Complete Workflow Example

<example>
User: "Add task: prep GoodFields strategy deck, call is tomorrow at 2pm, urgent"

Step 1: Parse input
- Task: prep strategy deck
- Project context: GoodFields (client)
- Due date: tomorrow at 2pm
- Priority: urgent

Step 2: Confirm interpretation
"Got it! Creating urgent task for GoodFields client project.
Due: Friday, November 8th at 2:00 PM"

Step 3: Search project
mcp__vikunja__vikunja_projects({subcommand: 'list', search: 'goodfields'})
→ Found: Work/Clients/GoodFields (id: 9)

Step 4: Break down task
🎯 Prep GoodFields strategy deck (Due: Fri 2pm, Priority: 5)
├── 🤖🟢 Review meeting notes (15 min, Due: Today 5pm, Priority: 5)
├── 🤖🟡 Draft recommendations (30 min, Due: Fri 10am, Priority: 5)
├── 🤖🟢 Create slides (20 min, Due: Fri 12pm, Priority: 5)
└── 🤖🟢 Rehearse (10 min, Due: Fri 1pm, Priority: 5)

Step 5: Explain reasoning
"All Priority 5 (client urgency). Staggered due dates ensure
you finish before 2pm call. First task due in 6 hours!"

Step 6: Create in Vikunja
mcp__vikunja__vikunja_tasks({
  subcommand: 'create',
  projectId: 9,
  title: '🎯 Prep GoodFields strategy deck',
  dueDate: '2024-11-08T22:00:00Z',
  priority: 5
})
→ Parent task created (id: 143)

[Create 4 subtasks with relations]

Step 7: Confirm
"Created in Work/Clients/GoodFields project.
First task 'Review notes' due today at 5pm!"

Step 8: Learn
Update priority-patterns.md:
"2024-11-07: Client + tomorrow deadline = Priority 5 confirmed"
</example>

---

## 📁 Data Files Reference

### project-hierarchy.md
Synced from Vikunja (via sync-projects.sh script)
Current project tree with IDs

### project-patterns.md
Learned keyword → project mappings
User corrections noted

### date-patterns.md
User date interpretation preferences
Corrections and confirmations

### priority-patterns.md
Urgency keyword mappings
Context-priority rules learned

### context-profiles.md
Time/energy/location preferences
Activity patterns observed

---

## 🔧 MCP Tools Used

### vikunja_projects
- list, get, create, update, archive
- get-children, get-tree (hierarchy navigation)

### vikunja_tasks
- create, get, update, delete, list
- assign, relate (subtask linking)
- add-reminder (for time-sensitive tasks)

### vikunja_labels
- list, get (for applying context labels)

---

## Key Principles

1. **AI-native intelligence** - Reason from examples, don't execute scripts
2. **ADHD momentum** - Easy tasks first (Priority 5)
3. **Natural language** - Parse dates/priorities naturally
4. **Project intelligence** - Existing vs new decision logic
5. **Balance** - Work/life/learning across root projects
6. **Learning** - Improve from user corrections
7. **Transparency** - Always explain reasoning
8. **Confirmation** - Verify interpretation before creating

---

## Supplementary Resources

For project hierarchy: `read ~/.claude/skills/taskman/data/project-hierarchy.md`
For learned patterns: `read ~/.claude/skills/taskman/data/*-patterns.md`
For deep methodology (future): `read ~/.claude/skills/taskman/CLAUDE.md`
