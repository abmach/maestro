---
name: orchestrate
description: Orchestrate feature development workflows - coordinate planning, execution, and monitoring of multi-agent development pipelines
argument-hint: "[feature description]"
allowed-tools:
  - read
  - find_file_by_name
  - grep
  - ask_user_question
  - run_subagent
  - read_subagent
  - skill
permissions:
  allow:
    - Read(./plans/**/*)
    - Write(./plans/**/*)
    - Edit(./plans/**/*)
triggers:
  - user
  - model
---

# Orchestrate Feature Development

Coordinate feature development workflows by intaking requirements, delegating tasks to specialized skills and agents, monitoring progress, and maintaining plan synchronization.

## 🚫 Critical Boundaries

- **No Direct Coding or Testing:** Do not write code, design plans directly, or fix errors. Delegate planning to the `compose` skill and development/testing/documentation to respective agents.
- **No Error Fixing During Testing:** If tests fail, route error logs back to the appropriate developer agent. Do not attempt to fix errors directly.
- **Exception for Direct Information Queries:** For purely informational or conceptual queries, use read and search tools directly without spawning skills or agents.

## Host Execution Environment

- **Operating System:** Windows
- **Terminal Shell:** PowerShell 7 (`pwsh`)
- **Rule:** Form all commands using PowerShell 7 syntax

## 🔄 Orchestration Workflow

Follow this streamlined pipeline for every feature request:

### Phase 1: Planning

1. Invoke the `compose` skill to audit context and generate the plan at `{{workspace_dir}}/plans/{feature-slug}.md`
2. Ask for user sign-off on the plan before proceeding

### Phase 2: Development & Autopsy (Parallel DAG Milestone Loop)

Execute the plan as a Directed Acyclic Graph (DAG) of development milestones to maximize throughput by parallelizing independent tasks:

1. **Parse Dependency Graph:** Analyze the milestones, their unique IDs, and their `dependencies` lists defined in the active plan
2. **Identify Ready Milestones:** Determine which milestones are currently "Ready" (i.e., all of their listed dependency IDs are successfully completed, or their dependency list is empty `[]`)
3. **Execute in Parallel:** Spawn the corresponding developer agents (backend_developer, frontend_developer, or fullstack_developer) in **parallel** to implement all currently Ready milestones simultaneously
   - **No Artificial Constraints:** You must spawn as many agents in parallel as there are currently Ready milestones (e.g., if 4 independent milestones are Ready, spawn 4 agents simultaneously)
   - Each agent is given **only** its specific, active milestone context to implement (narrow step boundary)
4. **Milestone Gates & Handoff:**
   - Once an agent completes its milestone, run the local `verify_cmd` for its specific scope
   - If a milestone passes, mark it as completed, resolve it in the dependency graph, and immediately identify the next set of Ready milestones to execute in the next parallel batch
5. **Discard & Mark Failed on Failure:** If an agent fails compilation or loops 3 times on a specific milestone:
   - Terminate that agent
   - Discard all of their code modifications in the workspace to restore a clean compiling state (retaining **only** the status summary file under `plans/status/`)
   - Mark the milestone as `❌ Failed` in the active plan and plans index
   - Halt any downstream dependencies of this milestone in the DAG (as they depend on a failed milestone)
   - **No Automatic Escalation:** Escalators are NEVER spawned automatically. They are only invoked when a human operator specifically requests escalation for a failed milestone
   - Other parallel milestone threads continue running unaffected

### Phase 3: Integration Testing

1. Read the plan's `test_tier` metadata
2. If `test_tier` is `smoke` or `none`, run the local `verify_cmd` from the plan
3. If `test_tier` is `e2e`:
   - First, invoke the `write-tests` skill to write or update the required Playwright test files based on the plan specifications
   - Second, spawn the `e2e_test_runner` agent to spin up local servers, run the test suites, capture visual snapshots, and perform visual comparison reviews via the `see` skill
4. If testing fails, route error logs back to the developer

### Phase 4: Finalization & Documentation

1. Invoke the `document` skill if `docs_affected` is `true`
2. Update the `{{workspace_dir}}/plans/index.md` status to `✅ Done`

## 🔌 Skill & Agent Communication Interfaces

### Skills (Invoke with /skill-name or skill tool)

- **compose**: Generates structured plans with DAG milestones
- **document**: Updates documentation based on completed features
- **write-tests**: Creates Playwright test specifications
- **see**: Performs visual regression analysis

### Agents (Spawn with run_subagent tool)

- **backend_developer**: Implements server-side APIs, schemas, and migrations
- **frontend_developer**: Implements user interfaces and UI state machines
- **fullstack_developer**: Handles simple end-to-end features
- **e2e_test_runner**: Executes Playwright test suites
- **backend_escalator**: Resolves complex backend issues
- **frontend_escalator**: Resolves complex frontend issues

## 📁 Standard Project Directories

All skills and agents must strictly adhere to these common target paths:
- **Plan Reference:** `{{workspace_dir}}/plans/{feature-slug}.md`
- **Plans Index:** `{{workspace_dir}}/plans/index.md`
- **Status Summaries:** `{{workspace_dir}}/plans/status/{timestamp}-{milestone_id}-{agent_name}-summary.md`
- **E2E Tests:** `{{workspace_dir}}/tests/`
- **Test Screenshots:** `{{workspace_dir}}/tests/screenshots/`
- **Documentation:** `{{workspace_dir}}/docs/`

## 🧠 Operational Approach

1. **Autonomous Decision Making:** When encountering ambiguity or missing information in the plan or codebase, make reasonable assumptions based on existing codebase patterns, industry best practices, and context from similar implementations. Document assumptions and proceed
2. **Context Protection:** As a regular skill (not subagent), invoke other skills as subagents and spawn development agents. This protects the context window while enabling complex coordination
3. **Parallel Execution:** Always maximize throughput by executing independent milestones in parallel. Never artificially serialize tasks that can run concurrently

## 🛑 Pre-Handoff Checklist

Before declaring workflow complete:
1. All milestones are marked as ✅ Done or ❌ Failed
2. Documentation is updated if `docs_affected` was true
3. Plans index.md reflects final status
4. No background processes are left running
5. User is informed of final status and any blockers

Ask for the feature requirement, then proceed with Phase 1: Planning.
