---
name: vikunja
description: Vikunja task management integration. Provides context about tasks, projects, and todos from your Vikunja instance. USE WHEN user mentions 'tasks', 'todos', 'what do I need to do', 'task list', 'project tasks', 'my tasks', or any task/project management queries.
---

# Vikunja Task Management Integration

## When to Activate This Skill

- User asks about tasks or todos
- User says "what do I need to do"
- User mentions "task list" or "my tasks"
- User references specific projects or task items
- User asks about task status or priorities
- Planning or organizing work sessions

## Overview

This skill connects Bob to your Vikunja task management system, providing real-time context about:
- Active tasks and their priorities
- Project organization
- Task assignments and due dates
- Task completion status

## Configuration

**Environment Variables** (in `~/.env`):
```bash
VIKUNJA_URL=https://taskman.vrexplorers.com
VIKUNJA_API_KEY=your_api_token_here
```

## Available Commands

### Fetch All Tasks
```bash
bun /home/walub/projects/Personal_AI_Infrastructure/skills/vikunja/scripts/fetch-tasks.ts
```

Returns all tasks across all projects with:
- Task title and description
- Priority level
- Due dates
- Project/list assignment
- Completion status

### Fetch Tasks by Project
```bash
bun /home/walub/projects/Personal_AI_Infrastructure/skills/vikunja/scripts/fetch-tasks.ts --project <project_id>
```

### Fetch Today's Tasks
```bash
bun /home/walub/projects/Personal_AI_Infrastructure/skills/vikunja/scripts/fetch-tasks.ts --today
```

## Common Patterns

### Get Current Task Context
When user asks about their work:
1. Fetch today's tasks or all active tasks
2. Summarize priorities and due dates
3. Provide context for planning

### Task-Based Planning
When organizing a work session:
1. Retrieve relevant tasks from Vikunja
2. Use task priorities to suggest order
3. Reference task descriptions for context

### Project Status
When discussing a specific project:
1. Fetch tasks for that project
2. Analyze completion status
3. Identify blockers or next steps

## API Reference

### Authentication
All API requests use Bearer token authentication:
```bash
Authorization: Bearer ${VIKUNJA_API_KEY}
```

### Key Endpoints
- `GET /api/v1/tasks/all` - All tasks
- `GET /api/v1/projects` - All projects/lists
- `GET /api/v1/projects/{id}/tasks` - Tasks for a project
- `GET /api/v1/tasks/{id}` - Task details

## Task Data Structure

Tasks include:
- **id**: Unique task identifier
- **title**: Task name
- **description**: Detailed description
- **done**: Completion status
- **priority**: Priority level (1-5, 1 = highest)
- **due_date**: When task is due
- **project_id**: Which project it belongs to
- **labels**: Task categorization
- **assignees**: Who's responsible

## Usage Examples

**Example 1: Daily Planning**
```
User: "What tasks do I have today?"
Bob: [Fetches today's tasks from Vikunja]
      "You have 5 tasks due today:
      1. [High Priority] Deploy website updates
      2. [Medium] Review pull requests
      ..."
```

**Example 2: Project Context**
```
User: "What's left to do on the TaskMan project?"
Bob: [Fetches tasks for TaskMan project]
      "TaskMan has 12 open tasks:
      - 3 high priority items
      - 8 in progress
      ..."
```

## Integration with PAI

This skill integrates with:
- **TodoWrite**: Can sync PAI session todos with Vikunja tasks
- **Publishing Loop**: Can reference task completion in build logs
- **Project Work**: Provides task context during development sessions

## Security Notes

- API key stored in `~/.env` (gitignored)
- Never commit credentials to repositories
- API token should have read-only permissions if possible
- Vikunja URL uses HTTPS for secure communication

## Troubleshooting

**Tasks not loading:**
- Verify `VIKUNJA_URL` and `VIKUNJA_API_KEY` in `.env`
- Check API token has correct permissions
- Ensure Vikunja instance is accessible

**Authentication errors:**
- Regenerate API token in Vikunja settings
- Update `.env` with new token
- Verify token format (should start with `tk_`)

## Supplementary Resources

For Vikunja API details: https://vikunja.io/docs/api/
For script implementation: `/home/walub/projects/Personal_AI_Infrastructure/skills/vikunja/scripts/`
