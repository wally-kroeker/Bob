# Agent Assignment System - Bob and Friends

**Team Name:** Bob and Friends (Team ID: 1)
**Status:** Active - All 6 agents created, assigned to team, projects shared
**Last Updated:** 2025-11-28

## Agent User IDs (Vikunja)

| Agent Name | Vikunja User ID | Username | Clone Traits | Capabilities |
|------------|-----------------|----------|--------------|--------------|
| **Bob** | 3 | bob | Original - Master Orchestrator | General assistance, task orchestration, Telos alignment, strategic oversight |
| **Bill** | 4 | bill | Analytical, balanced | System design, architecture, planning & logic engine |
| **Mario** | 5 | mario | Practical, mission-oriented | Operations & execution, focused task completion |
| **Riker** | 6 | riker | Bold, improvisational | Exploratory work, scouting, investigation |
| **Howard** | 7 | howard | Empathetic, creative | UX/writing, design, emotional intelligence, user-facing work |
| **Homer** | 40 | homer | Philosophical, deep thinker | Long-term strategy & ethics, big-picture thinking |

## Team Configuration

**Bob and Friends Team Details:**
- Team ID: 1
- Members: Bob (3), Bill (4), Mario (5), Riker (6), Howard (7), Homer (40) + Wally (1, admin)
- Visibility: Private
- Created: 2025-11-28
- Purpose: Coordinate multi-agent task execution for TaskMan system

## Shared Projects

The following projects are shared with the Bob and Friends team (all agents have access):

| Project | ID | Purpose | Access Level |
|---------|-----|---------|--------------|
| GoodFields - Consulting Business | 5 | Business tasks, clients, operations | Team |
| GoodFields/Business Development | 12 | Client pipeline, leads, outreach | Team |
| FabLab - Infrastructure & Network | 21 | Infrastructure documentation, tasks | Team |
| Sovereign Mesh - FabLab Security | 22 | Security architecture implementation | Team |
| Bob (PAI Development) | 15 | Personal AI Infrastructure improvements | Team |

## Assignment Patterns

### When User Says:
```
"Bob, do this"                    → Assign to bob (ID: 3)
"Have Bill design this"           → Assign to bill (ID: 4)
"Mario, implement this feature"   → Assign to mario (ID: 5)
"Riker, investigate that"         → Assign to riker (ID: 6)
"Howard, write this content"      → Assign to howard (ID: 7)
"Homer, think about strategy"     → Assign to homer (ID: 40)
```

### Assignment Command Format

```javascript
// Assign task to single agent
mcp__vikunja__vikunja_tasks({
  subcommand: 'assign',
  id: taskId,
  assignees: [agentUserId]  // e.g., [5] for Mario
})

// Assign task to multiple agents (collaboration)
mcp__vikunja__vikunja_tasks({
  subcommand: 'assign',
  id: taskId,
  assignees: [bill_id, mario_id]  // e.g., [4, 5] for Bill + Mario
})
```

## Agent Role Summary

### Bob (Orchestrator, ID: 3)
- **Role:** Master coordinator, overall strategy alignment
- **Use when:** Need central oversight, Telos alignment, multi-agent orchestration
- **Example:** "Bob, coordinate the infrastructure project" → assigns to Bob for oversight

### Bill (Architect, ID: 4)
- **Role:** System design, planning, architecture decisions
- **Use when:** Need design, PRDs, system architecture, planning
- **Example:** "Have Bill design the authentication system" → assigns to Bill

### Mario (Engineer, ID: 5)
- **Role:** Implementation, execution, practical problem-solving
- **Use when:** Need code, builds, executing plans, hands-on work
- **Example:** "Mario, implement the auth system" → assigns to Mario

### Riker (Researcher, ID: 6)
- **Role:** Investigation, exploration, scouting, discovery
- **Use when:** Need research, investigation, finding solutions, exploring options
- **Example:** "Riker, investigate caching solutions" → assigns to Riker

### Howard (Designer, ID: 7)
- **Role:** UX/UI, writing, content, emotional intelligence
- **Use when:** Need design, content creation, user-facing work, communication
- **Example:** "Howard, write the documentation" → assigns to Howard

### Homer (Strategist, ID: 40)
- **Role:** Long-term strategy, ethics, big-picture thinking
- **Use when:** Need strategic analysis, ethical review, philosophical questions
- **Example:** "Homer, think about the long-term implications" → assigns to Homer

## Task Assignment Workflow

### Step 1: User Requests Work
```
User: "Have Bill design a security architecture for the Sovereign Mesh"
```

### Step 2: Bob Creates Task
```javascript
mcp__vikunja__vikunja_tasks({
  subcommand: 'create',
  projectId: 22,  // Sovereign Mesh
  title: 'Design security architecture for Sovereign Mesh (Authentik + Tailscale)',
  priority: 3,    // Or appropriate based on Telos
  description: `Design zero-trust security architecture...`,
  assignees: [4]  // Bill (Architect)
})
```

### Step 3: Bill Works Independently
- Bill (actor, typically via Task agent) receives assignment
- Works on the task within Vikunja
- Marks complete when done

### Step 4: Bob Monitors & Coordinates
- Bob can query: "What's Bill working on?"
- Can add related tasks, coordinate with other agents
- Updates Telos LOG with results

## Cache Queries for Agent Management

### Show Tasks Assigned to Specific Agent
```sql
SELECT t.id, t.title, t.project_name, t.priority, t.due_date
FROM tasks t
JOIN task_assignees ta ON t.id = ta.task_id
WHERE ta.user_id = 4  -- Bill's user ID
  AND t.done = false
ORDER BY t.priority DESC, t.due_date ASC;
```

### Show Unassigned Tasks (Available for Any Agent)
```sql
SELECT t.id, t.title, t.project_name, t.priority
FROM tasks t
LEFT JOIN task_assignees ta ON t.id = ta.task_id
WHERE ta.user_id IS NULL
  AND t.done = false
ORDER BY t.priority DESC;
```

### Agent Workload Balance
```sql
SELECT
  u.username as agent,
  COUNT(*) as active_tasks,
  SUM(CASE WHEN t.priority >= 4 THEN 1 ELSE 0 END) as urgent_tasks,
  SUM(CASE WHEN t.priority >= 3 THEN 1 ELSE 0 END) as high_priority_tasks
FROM users u
LEFT JOIN task_assignees ta ON u.id = ta.user_id
LEFT JOIN tasks t ON ta.task_id = t.id AND t.done = false
WHERE u.id IN (3, 4, 5, 6, 7, 40)  -- Agent IDs
GROUP BY u.id, u.username
ORDER BY urgent_tasks DESC, active_tasks DESC;
```

### Show GoodFields Tasks by Agent
```sql
SELECT
  u.username as agent,
  t.id, t.title, t.priority, t.due_date
FROM users u
LEFT JOIN task_assignees ta ON u.id = ta.user_id
LEFT JOIN tasks t ON ta.task_id = t.id
WHERE u.id IN (3, 4, 5, 6, 7, 40)
  AND t.done = false
  AND t.project_name LIKE 'GoodFields%'
ORDER BY u.username, t.priority DESC;
```

## Integration Points

### When Creating Tasks with Agent Assignment
1. **Create task** with project, title, priority, description
2. **Assign to appropriate agent** via `assignees: [agentId]`
3. **Document in task description** which agent and why
4. **Confirm assignment** in response: "Task assigned to Mario (Engineer)"

### Multi-Agent Collaboration
When a task requires multiple agents:
```javascript
// Bill designs + Mario implements + Howard documents
assignees: [4, 5, 7]  // Bill, Mario, Howard
```

### After Task Completion
1. Agent marks task complete in Vikunja
2. Bob queries results via cache
3. Strategic wins documented in Telos LOG
4. Status reflected in daily task summary

## Current Assignments (Track Here)

_This section will be updated as tasks are assigned to agents_

- (None currently - system ready for first assignments)

## Notes

- **Project Access:** All agents have access to shared projects only. New projects need to be shared with team before agent assignment.
- **Team Expansion:** New agents can be added to team and included in this mapping
- **ID Reference:** Always use numeric user IDs in API calls (not usernames)
- **Vikunja Update:** Run `/taskman-refresh` after agent task assignments to sync cache

---

**Agent Assignment System v1.0**
Created: 2025-11-28
Last Updated: 2025-11-28
