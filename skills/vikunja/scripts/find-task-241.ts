#!/usr/bin/env bun

const VIKUNJA_URL = process.env.VIKUNJA_URL;
const VIKUNJA_API_KEY = process.env.VIKUNJA_API_KEY || process.env.Vikunja_API_Key;

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
  const tasks = await vikunjaRequest<any[]>("/api/v1/tasks/all");

  console.log(`Total tasks fetched: ${tasks.length}`);
  console.log(`Task IDs range: ${Math.min(...tasks.map(t => t.id))} to ${Math.max(...tasks.map(t => t.id))}`);

  const task241 = tasks.find(t => t.id === 241);

  if (task241) {
    console.log("\n✅ Found task 241:");
    console.log(JSON.stringify(task241, null, 2));
  } else {
    console.log("\n❌ Task 241 NOT in /api/v1/tasks/all response");
    console.log("\nThis means the API endpoint doesn't return ALL tasks.");
    console.log("Likely reasons:");
    console.log("- Task 241 is in a different project not included");
    console.log("- Task 241 is archived");
    console.log("- API has default filters (date range, project, etc.)");
  }
}

main();
