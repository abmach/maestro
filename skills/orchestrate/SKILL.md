---
name: orchestrate
description: Orchestrate feature implementation - coordinate execution and monitoring of multi-agent development pipelines from existing plans
argument-hint: "[plan ID/code]"
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
---

# Orchestrate Feature Implementation

Coordinate feature implementation workflows by executing existing plans, delegating tasks to specialized skills and agents, monitoring progress, and maintaining plan synchronization.

## Pre-flight

- Working folder: `{{workspace_dir}}` - the root of the project/workspace
- Target folders: `{{workspace_dir}}/plans/` (you should only modify files in this folder)
- Required input: Plan ID/code from user prompt

## Specifications & Methodologies

Read the following asset specification files from `{{workspace_dir}}/.agents/assets/` to understand formats, rules, and methodologies before executing the plan:

- **Plans Index:** [plans-index.md]({{workspace_dir}}/.agents/assets/plans-index.md) - plans index file format and management
- **Plan:** [plan.md]({{workspace_dir}}/.agents/assets/plan.md) - plan structure and metadata specification
- **Working Files:** Located in `{{workspace_dir}}/plans/` following specifications

## Validation

- If required input is missing or plan ID doesn't exist in plans index, abort with error

## Core Workflow

Follow this streamlined pipeline for every plan execution:

### Phase 0: Setup

1. Read the Plans Index at `{{workspace_dir}}/plans/index.md` to find the full plan filename for the given plan ID/code
2. Construct the full plan file path: `{{workspace_dir}}/plans/{full_filename}.md`
3. Read the plan file to understand the implementation requirements

### Phase 1: Development & Autopsy (Parallel DAG Milestone Loop)

Execute the plan as a Directed Acyclic Graph (DAG) of development milestones to maximize throughput by parallelizing independent tasks:

1. **Parse Dependency Graph:** Analyze the milestones, their unique IDs, and their `dependencies` lists defined in the active plan
2. **Identify Ready Milestones:** Determine which milestones are currently "Ready" (i.e., all of their listed dependency IDs are successfully completed, or their dependency list is empty `[]`)
3. **Execute in Parallel:** Spawn the `play` skill in **parallel** for each currently Ready milestone to implement them simultaneously
   - **No Artificial Constraints:** You must spawn as many `play` skill instances in parallel as there are currently Ready milestones (e.g., if 4 independent milestones are Ready, spawn 4 instances simultaneously)
   - Each `play` instance is given **only** its specific, active milestone context to implement (narrow step boundary)
4. **Milestone Gates & Handoff:**
   - Once an agent completes its milestone, run the local `verify_cmd` for its specific scope
   - If a milestone passes, mark it as completed, resolve it in the dependency graph, and immediately identify the next set of Ready milestones to execute in the next parallel batch
5. **Discard & Mark Failed on Failure:** If a `play` skill instance fails compilation or loops 3 times on a specific milestone:
   - Terminate that `play` instance
   - Discard all of their code modifications in `{{workspace_dir}}` to restore a clean compiling state
   - Mark the milestone as `❌ Failed` in the active plan and plans index
   - Halt any downstream dependencies of this milestone in the DAG (as they depend on a failed milestone)
   - Other parallel milestone threads continue running unaffected

### Phase 2: Integration Testing

1. Read the plan's `test_tier` metadata
2. If `test_tier` is `smoke` or `none`, run the local `verify_cmd` from the plan
3. If `test_tier` is `e2e`:
   - First, invoke the `arrange` skill to write or update the required test files based on the plan specifications
   - Second, invoke the `audition` skill to execute the tests and capture results
   - Third, if visual regression testing is applicable, invoke the `critique` skill to analyze screenshots and provide verdict
4. If testing fails, route error logs back to the appropriate `play` skill instance for resolution

### Phase 3: Finalization & Documentation

1. Invoke the `score` skill with the plan ID/code if `docs_affected` is `true`
2. Update the `{{workspace_dir}}/plans/index.md` status to `✅ Done`

## � Critical Boundaries

- **No Direct Coding or Testing:** Do not write code, design plans directly, or fix errors. Delegate development/testing/documentation to respective agents.
- **No Error Fixing During Testing:** If tests fail, route error logs back to the appropriate developer agent. Do not attempt to fix errors directly.
- **Exception for Direct Information Queries:** For purely informational or conceptual queries, use read and search tools directly without spawning skills or agents.

## �🔌 Skill & Agent Communication Interfaces

### Skills (Invoke with /skill-name or skill tool)

- **play**: Implements plan milestones using test-driven development
- **audition**: Executes test suites and captures results
- **arrange**: Creates integration and E2E test specifications
- **critique**: Performs visual regression analysis
- **score**: Updates documentation based on completed features

## 🧠 Operational Approach

1. **Autonomous Decision Making:** When encountering ambiguity or missing information in the plan or codebase, make reasonable assumptions based on existing codebase patterns, industry best practices, and context from similar implementations. Document assumptions and proceed
2. **Context Protection:** As a regular skill (not subagent), invoke other skills as subagents. This protects the context window while enabling complex coordination
3. **Parallel Execution:** Always maximize throughput by executing independent milestones in parallel. Never artificially serialize tasks that can run concurrently

## 🛑 Pre-Handoff Checklist

Before declaring workflow complete:
1. All milestones are marked as ✅ Done or ❌ Failed
2. Documentation is updated if `docs_affected` was true
3. Plans index.md reflects final status
4. No background processes are left running
5. User is informed of final status and any blockers

Ask for the plan ID/code, then proceed with Phase 1: Development.
