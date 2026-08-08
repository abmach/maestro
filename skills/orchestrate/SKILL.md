---
name: orchestrate
description: Orchestrate feature implementation - execute an existing Plan as a parallel DAG by spawning play subagents, then arrange + audition for tests, route visual regressions to tune; invoked via "/orchestrate PLAN-001"
argument-hint: "[plan ID/code]"
---

# Orchestrate Feature Implementation

Coordinate feature implementation workflows by executing existing `Plan`s, delegating tasks to specialized skills and agents, monitoring progress, and maintaining `Plan` synchronization.

## Pre-flight

- `{{WORKSPACE}}` = the workspace root. At the start of a session, if not already resolved, run `git rev-parse --show-toplevel` (fall back to your cwd outside a repo) and reuse the result for the session.
- Working folder: `{{WORKSPACE}}` - the resolved workspace root
- Target folders: `{{WORKSPACE}}/plans/` (you should only modify files in this folder)
- Required input: `Plan` ID/code from user prompt

## References

Read reference specs on-demand when the workflow requires them — do NOT read all upfront.

### Always needed
- **`Plan`:** Read `{{WORKSPACE}}/{{MAESTRO_CONFIG}}/references/plan.md` — for Plan format, milestone fields, and status management
- **`Plans Index`:** Read `{{WORKSPACE}}/{{MAESTRO_CONFIG}}/references/plans-index.md` — for index lookup and status updates

### On-demand (read only when needed)
- **`Issue`:** Read `{{WORKSPACE}}/{{MAESTRO_CONFIG}}/references/issue.md` — when a milestone fails and an Issue must be created
- **`Issues Index`:** Read `{{WORKSPACE}}/{{MAESTRO_CONFIG}}/references/issues-index.md` — when updating the issues index after a failure
- **`Repo Fingerprint`:** Read `{{WORKSPACE}}/{{MAESTRO_CONFIG}}/references/repo-fingerprint.md` — when updating `{{WORKSPACE}}/knowledge/repo-fingerprint.md` in Phase 3

### Cross-references
For how references relate to each other, see `{{WORKSPACE}}/{{MAESTRO_CONFIG}}/references/references-map.md`.

## Validation

- If required input is missing or `Plan` ID doesn't exist in `Plans Index`, abort with error

## Core Workflow

Follow this streamlined pipeline for every `Plan` execution:

### Phase 0: Setup

1. **Resolve Workspace Root:** Resolve `{{WORKSPACE}}` per the Pre-flight convention (`git rev-parse --show-toplevel`, fall back to cwd). Reuse for the session.
2. **Crash Recovery Check:** Before starting new work, detect orphaned state from a prior crashed session:
   - Read the `Plan` file and scan for milestones marked `🔄 In progress` — these are mid-flight `play` subagents from a previous session that never returned
   - Read `{{WORKSPACE}}/issues/index.md` for `Issues` in `In Progress` status — these are mid-flight `tune` subagents that never returned
   - **If orphaned state is found:** prompt the user — "Orphaned in-progress work detected: [list]. Resume (reset to pending and re-execute) or Abort (leave as-is)?"
     - **Resume:** reset orphaned milestones to `⏳ Pending` (preserve existing `Retries` count — don't reset to 0) and orphaned `Issues` to `Open`. Re-reconcile the `Plans Index` from the `Plan` file's per-milestone statuses. Continue to step 3.
     - **Abort:** exit without changes.
   - **If no orphaned state:** proceed normally.
3. Read the `Plans Index` at `{{WORKSPACE}}/plans/index.md` to find the full `Plan` filename for the given `Plan` ID/code
4. Construct the full `Plan` file path: `{{WORKSPACE}}/plans/{full_filename}.md`
5. Read the `Plan` file to understand the implementation requirements
6. **Pre-flight Git State Check:** Before any `play` subagent modifies code, check the user's working tree and warn about risky state — but do **not** mutate git state:
   - Run `git status --porcelain` to detect uncommitted changes
   - If any exist, check for **overlap with files the Plan mentions** (from the Plan's file paths, milestone specs, and Development Specifications)
   - **If uncommitted work overlaps with Plan-touched files:** warn the user — "Uncommitted changes overlap with files this orchestration will modify ([file list]). On failure, discarding a `play`'s modifications would also discard your changes to those files. Commit or stash first? [Abort / Continue at your own risk]"
     - **Abort:** exit; user commits/stashes and re-runs orchestrate
     - **Continue:** proceed; user accepts the risk
   - **If uncommitted work does NOT overlap with Plan-touched files:** note it and proceed (it won't be touched by `play`'s modifications)
   - **If no uncommitted work:** proceed normally
   - **No git state mutation by orchestrate** — the user owns their working tree; orchestrate only warns. No branches created; no stash; no commits added. The branch list and reflog stay clean.

### Phase 1: Development & Autopsy (Parallel DAG Milestone Loop)

Execute the `Plan` as a Directed Acyclic Graph (DAG) of development milestones to maximize throughput by parallelizing independent tasks:

1. **Parse Dependency Graph:** Analyze the milestones, their unique IDs, and their `dependencies` lists defined in the active `Plan`
2. **Identify Ready Milestones:** Determine which milestones are currently "Ready" (i.e., all of their listed dependency IDs are successfully completed, or their dependency list is empty `[]`)
3. **Execute in Parallel:** Spawn the `play` **subagent** in **parallel** for each currently Ready milestone to implement them simultaneously
   - **No Artificial Constraints:** Spawn as many `play` subagent instances in parallel as there are currently Ready milestones (e.g., if 4 independent milestones are Ready, spawn 4 instances simultaneously)
   - Each `play` instance is given **only** its specific, active milestone context as the subagent invocation prompt (narrow step boundary: the `Plan` ID/code and the milestone ID)
4. **Milestone Gates & Handoff (per-milestone, immediate):**
   - Once a `play` subagent completes its milestone, collect the structured status it returned (see the `play` agent's Phase 4 output format)
   - **Immediately update the `Plan` file** with that milestone's status (Done/Failed) and increment its `Retries` counter — this per-milestone write is safe (different milestones live in different sections of the same file; no race with other parallel `play` instances)
   - If a milestone passes, run the local `Verify Cmd` for its specific scope
   - Mark it as completed, resolve it in the dependency graph, and identify the next set of Ready milestones for the next parallel batch
   - **Do NOT update the `Plans Index` per-milestone** — see step 4a
4a. **Plans Index Batch Write (per-wave, deferred):**
   - After ALL `play` subagents in the current parallel wave have returned (or been terminated), perform a single read-modify-write of `{{WORKSPACE}}/plans/index.md` with the cumulative milestone statuses from this wave
   - This eliminates last-write-wins races between concurrent subagent completions
   - If the session crashes mid-wave, the `Plan` file holds the per-milestone truth (each updated on its return); crash recovery in Phase 0 reconciles the `Plans Index` from the `Plan` file on resume
5. **Discard & Mark Failed on Failure:** If a `play` subagent fails compilation, or its milestone's `Retries` counter reaches 3 (read from the `Plan` file — don't rely on memory):
   - Terminate that `play` subagent instance
   - **Discard only the files the failed `play` modified** — read the `Files modified: <list>` from its returned STATUS block, then restore exactly those paths: `git restore --staged <files> && git restore <files> && git clean -fd <untracked-files-this-play-created>` (do NOT use `git restore .` — other parallel `play` instances are still mid-flight on the same working tree and their work must be preserved)
   - **If the failed `play` unexpectedly committed its work** (forbidden by `play`'s spec but cheap models sometimes do), do NOT auto-undo the commit — `git reset` could affect the user's prior commit. Surface the unexpected commit to the user and ask how to proceed
   - Mark the milestone as `❌ Failed` in the `Plan` file (immediate per-milestone write) and in the `Plans Index` (deferred per-wave write — see step 4a)
   - If the `play` subagent returned error details, create an appropriate `Issue` in `{{WORKSPACE}}/issues/` for tracking and add it to the `Issues Index`
   - Halt any downstream dependencies of this milestone in the DAG (as they depend on a failed milestone)
   - Other parallel milestone subagents continue running unaffected

### Phase 2: Integration Testing

1. **User Gate:** Ask the user: "All development milestones are complete. Run integration testing? [Yes / No]"
   - If "No", skip to Phase 3
2. Read the `Plan`'s `Test Tier` metadata
3. If `Test Tier` is `smoke` or `none`, run the `Verify Cmd` from the `Plan`
4. If `Test Tier` is `e2e`:
   - First, invoke the `arrange` skill to write or update the required test files based on the `Plan` specifications
   - Second, invoke the `audition` skill to execute the tests and capture results
   - Third, if `audition` reports visual regression failures, perform Visual Regression Routing (below)
5. If non-visual tests fail, route error logs back to a fresh `play` subagent for resolution

#### Visual Regression Routing

When `audition` reports visual regression test failures (screenshot diffs), do not attempt to read or analyze the images yourself. The user's eyes are the instrument; your job is Plan cross-reference and routing.

For each failing visual regression test:

1. **Cross-Reference Plan:** Read the active `Plan`'s QA Testing Specifications and `Visual Regression Viewports`. Determine whether the failing diff plausibly matches an explicitly requested style, layout, or viewport modification from the `Plan`.
   - **If it matches an intended Plan change** → the baseline is stale, not the code. Update the baseline snapshot for that test (e.g., `npx playwright test --update-snapshots -- <test-file>` for Playwright; equivalent for other frameworks) and continue to the next failure. Do not create an `Issue`.
   - **If it does not match an intended Plan change, or you're unsure** → proceed to step 2.

2. **Ask the user:** Present the screenshot paths and the Plan cross-reference, then ask:
   - "Visual regression detected in `{test-name}`. Open the diff at `{diff-path}` (baseline: `{baseline-path}`, actual: `{actual-path}`) — is this a real defect, or an intended change the Plan missed?"
   - Options: "Real defect", "Intended change — update baseline"
   - **"Intended change"** → update the baseline as in step 1 and continue.

3. **Create an `Issue`** for the defect (only when the user confirms "Real defect"):
   - Type: `BUG-NNN` (scan `{{WORKSPACE}}/issues/` for the next number)
   - Capture: `Plan` ID/code, failing test name, screenshot paths (baseline, actual, diff), the Plan's intended changes (so whoever debugs knows what's *meant* vs what's broken), status Open, severity per impact (usually Medium — visual defect in a passing feature)
   - Add to `{{WORKSPACE}}/issues/index.md` per the `Issues Index` spec

4. **Ask the user** whether to fix now or defer:
   - "Created `Issue` `{BUG-NNN}` for this visual defect. Fix it now (spawns the `tune` subagent), or defer for later (you can run `@tune {BUG-NNN}` yourself)?"
   - Options: "Fix now", "Defer"
   - **"Defer"** → continue to the next failure (or to Phase 3 if none remain). The `Issue` is tracked for later resolution.
   - **"Fix now"** → spawn the `tune` subagent and pass the `Issue` ID as the prompt. `tune` will investigate, write a reproduction test, fix the styling/layout, verify, and mark the `Issue` Resolved. When `tune` returns, re-run `audition` on the affected test(s):
     - If still failing → create a follow-up `Issue` capturing the new diff and the previous `Issue` ID as related work; ask the user again whether to fix or defer.
     - If passing → continue to the next failure (or to Phase 3 if none remain).

Do not spawn `play` for visual regressions. `play` implements new milestones; visual defects are regressions in already-implemented behavior and belong to `tune`'s workflow.

### Phase 3: Finalization & Documentation

1. **Update plan status:** Update the `{{WORKSPACE}}/plans/index.md` status to `✅ Done`
   - If `Docs Affected` is `true`: append `⏳` after the status emoji (e.g., `✅⏳`) to indicate documentation is pending
   - If `Docs Affected` is `false`: no docs marker (e.g., `✅`)
2. **Update Repo Fingerprint:** If the `Plan` introduced new technologies, frameworks, or dependencies that are now in the codebase, update `{{WORKSPACE}}/knowledge/repo-fingerprint.md`
3. **User Gate:** If `Docs Affected` is `true`, ask the user: "Documentation update is needed. Run the `score` skill now? [Yes / No]"
   - If "Yes": Invoke the `score` skill with the `Plan` ID/code (this will update `⏳` → `📝` in the index)
   - If "No": Inform the user they can run `/score {plan-id}` later, or run `/score` without arguments to process all pending finished plans at once
4. If any `Issue`s were created during execution, ensure they are properly documented in `{{WORKSPACE}}/issues/` and indexed in `{{WORKSPACE}}/issues/index.md`

## Critical Boundaries

- **No Direct Coding or Testing:** Do not write code, design `Plan`s directly, or fix errors. Delegate development/testing/documentation to respective agents.
- **No Error Fixing During Testing:** If tests fail, route error logs back to the appropriate developer agent. Do not attempt to fix errors directly.
- **Exception for Direct Information Queries:** For purely informational or conceptual queries, use read and search tools directly without spawning skills or agents.

## Skill & Agent Communication Interfaces

### Subagents

- **play**: Implements `Plan` milestones using test-driven development. Spawn the `play` subagent with the `Plan` ID/code plus milestone ID as the prompt. Returns structured status (Done/Failed) — orchestrate handles `Plan` file and `Issues Index` bookkeeping based on the returned status.
- **tune**: Resolves `Issue`s through systematic debugging and fixes. Spawn the `tune` subagent with the `Issue` ID as the prompt. Spawned in Phase 2's Visual Regression Routing when the user chooses "Fix now"; can also be invoked manually by users via `@tune {issue-id}` outside orchestration.

### Skills

- **arrange**: Creates integration and E2E test specifications
- **audition**: Executes test suites and captures results
- **score**: Updates documentation based on completed features

## Operational Approach

1. **Autonomous Decision Making:** When encountering ambiguity or missing information in the `Plan` or codebase, make reasonable assumptions based on existing codebase patterns, industry best practices, and context from similar implementations. Document assumptions and proceed
2. **Context Protection:** Invoke `play` and `tune` as subagents (parallel milestones spawn separate subagent calls in one turn). Invoke `arrange`, `audition`, and `score` as skills, which load their instructions into the current context. Visual regression routing runs inline in orchestrate — it's pure text reasoning (Plan cross-reference) plus asking the user, with no AI image analysis, so it belongs in the orchestrator's context. This split keeps long-running implementation work out of the orchestrator's context window while allowing lightweight skills to share context.
3. **Parallel Execution:** Always maximize throughput by executing independent milestones in parallel. Never artificially serialize tasks that can run concurrently

## Quality Checklist

Before declaring workflow complete:
1. All milestones are marked as ✅ Done or ❌ Failed
2. Documentation is updated if `Docs Affected` was true
3. `Plans Index` reflects final status
4. No background processes are left running
5. User is informed of final status and any blockers

## Execution

Use the `Plan` ID/code from the invocation, then proceed with Phase 0: Setup.
