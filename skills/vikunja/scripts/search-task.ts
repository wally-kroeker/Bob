#!/usr/bin/env bun

/**
 * Search for a task by title (case-insensitive)
 */

const VIKUNJA_URL = process.env.VIKUNJA_URL;
const VIKUNJA_API_KEY = process.env.VIKUNJA_API_KEY || process.env.Vikunja_API_Key;

if (!VIKUNJA_URL || !VIKUNJA_API_KEY) {
  console.error("❌ Error: VIKUNJA_URL and VIKUNJA_API_KEY must be set in .env file");
  process.exit(1);
}

const searchTerm = process.argv[2];
if (!searchTerm) {
  console.error("Usage: bun search-task.ts <search term>");
  process.exit(1);
}

interface VikunjaTask {
  id: number;
  title: string;
  description: string;
  done: boolean;
  priority: number;
  due_date: string | null;
  project_id: number;
  related_tasks?: {
    subtask?: Array<any>;
    parenttask?: Array<any>;
  };
}

async function vikunjaRequest<T>(endpoint: string): Promise<T> {
  const url = `${VIKUNJA_URL}${endpoint}`;
  const response = await fetch(url, {
    headers: {
      "Authorization": `Bearer ${VIKUNJA_API_KEY}`,
      "Content-Type": "application/json",
    },
  });

  if (!response.ok) {
    throw new Error(`HTTP ${response.status}: ${response.statusText}`);
  }

  return await response.json();
}

async function main() {
  try {
    console.log(`🔍 Searching for tasks matching: "${searchTerm}"\n`);

    const tasks = await vikunjaRequest<VikunjaTask[]>("/api/v1/tasks/all");

    // Search in title (case-insensitive)
    const matches = tasks.filter(task =>
      task.title.toLowerCase().includes(searchTerm.toLowerCase())
    );

    if (matches.length === 0) {
      console.log("❌ No tasks found matching that search term.");
      process.exit(0);
    }

    console.log(`📋 Found ${matches.length} task${matches.length === 1 ? '' : 's'}:\n`);

    matches.forEach((task, index) => {
      const priorityIcon = task.priority >= 4 ? "🔴" : task.priority >= 2 ? "🟡" : "🟢";
      const statusIcon = task.done ? "✅" : "⬜";
      const subtaskCount = task.related_tasks?.subtask?.length || 0;
      const parentCount = task.related_tasks?.parenttask?.length || 0;

      console.log(`${index + 1}. ${statusIcon} ${priorityIcon} ${task.title}`);
      console.log(`   ID: ${task.id}`);
      console.log(`   Status: ${task.done ? "COMPLETED" : "ACTIVE"}`);

      if (subtaskCount > 0) {
        const completedSubtasks = task.related_tasks?.subtask?.filter(st => st.done).length || 0;
        console.log(`   Parent task with ${subtaskCount} subtasks (${completedSubtasks} completed)`);
      }

      if (parentCount > 0) {
        console.log(`   Subtask of: ${task.related_tasks?.parenttask?.[0]?.title || "Unknown"}`);
      }

      if (task.description && task.description.length < 200) {
        console.log(`   Description: ${task.description.substring(0, 100)}${task.description.length > 100 ? '...' : ''}`);
      }

      console.log('');
    });

  } catch (error) {
    console.error("❌ Failed to search tasks:", error);
    process.exit(1);
  }
}

main();
