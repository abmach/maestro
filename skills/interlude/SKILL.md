---
name: interlude
description: Status interlude - summarize workspace state (active, blocked, and failed plans; open issues by priority; docs pending) from the Plans Index and Issues Index and suggest the next action, modifying nothing; invoked via "/interlude [plans | issues | docs]"
argument-hint: "[optional focus: plans | issues | docs]"
---

# Interlude

Pause between acts: report where the performance stands. Strictly read-only — answers "what is going on, and what should I do next?" from the workspace's own registries.

## Pre-flight

- `{{WORKSPACE}}` = workspace root. Resolve once per session and reuse: `git rev-parse --show-toplevel`; fall back to cwd outside a git repo.
- Before your first write, read `{{WORKSPACE}}/{{MAESTRO_CONFIG}}/references/conventions.md` — statuses, retries, artifact paths, and file ownership are defined there and are binding. (You will not write; this read is still mandatory so status vocabulary is interpreted correctly.)
- Working folder: `{{WORKSPACE}}`
- Target folders: none — this skill modifies nothing, anywhere
- Required input: none (optional focus filter: `plans`, `issues`, or `docs`)

## References

Read reference specs on-demand when the workflow requires them — do NOT read all upfront.

### Always needed
- **`Conventions`:** Read `{{WORKSPACE}}/{{MAESTRO_CONFIG}}/references/conventions.md` — for the status vocabularies this report decodes

### On-demand (read only when needed)
- **`Plans Index` / `Issues Index` specs:** only if an index marker is ambiguous

## Core Workflow

### Phase 0: Gather

1. Read `{{WORKSPACE}}/plans/index.md` — every status section
2. Read `{{WORKSPACE}}/issues/index.md` — every status section
3. If a focus argument was given, limit the report to that area (still scan both files for the Next recommendation)

### Phase 1: Report

```
STATUS INTERLUDE — {YYYY-MM-DD}

Plans:
  🔄 In progress: <one line per entry: title → link>
  ⏳ Pending: <count> (oldest first)
  ⚠️ Blocked: <one line each + what it waits on>
  ❌ Failed: <one line each + linked Issue>

Issues:
  Open by priority: <P1→P4 lines with severity>
  🔄 In Progress: <count>

Docs: <plans marked ✅⏳ awaiting /score, or "none pending">

Next: <single suggested action + one-line why>
```

Next-action guidance, in priority order: a 🔄 In-progress plan exists (resume it — re-run `/orchestrate`; crash recovery reconciles — before starting anything else); open P1/P2 issues (`@tune` them); failed milestones flagged twice or more (plan-quality signal — revise the spec via compose/elaborate before re-running); plans ✅⏳ (`/score`); otherwise the oldest Pending plan (`/orchestrate`).

## Quality Checklist

- [ ] Every index section visited; nothing reported that isn't in the files
- [ ] The Next recommendation cites a specific entry as grounds
- [ ] Zero modifications made to any file

## Execution

Use the optional focus argument from the invocation, then proceed with Phase 0: Gather.
