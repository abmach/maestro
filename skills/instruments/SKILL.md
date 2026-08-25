---
name: instruments
description: Configure the instruments - assign AI models to each section of the Maestro workflow (cheap implementation, reasoning-heavy composition, etc.), stored in knowledge/instruments.md with per-harness application guidance; invoked via "/instruments [section]"
argument-hint: "[section name, or omit to review all sections]"
---

# Instruments

Assign the instruments — decide which AI model plays each section of the Maestro workflow. A Plan can be composed by a reasoning-heavy model and executed by a cheap, fast one; this skill records those assignments in one place and explains how your harness applies them.

## Pre-flight

- `{{WORKSPACE}}` = workspace root. Resolve once per session and reuse: `git rev-parse --show-toplevel`; fall back to cwd outside a git repo.
- Before your first write, read `{{WORKSPACE}}/{{MAESTRO_CONFIG}}/references/conventions.md` — statuses, retries, artifact paths, and file ownership are defined there and are binding.
- Working folder: `{{WORKSPACE}}`
- Target folders: `{{WORKSPACE}}/knowledge/` (you should only modify `instruments.md` in this folder)
- Required input: none — reviews all sections; or a single section name to configure

## References

Read reference specs on-demand when the workflow requires them — do NOT read all upfront.

### Always needed
- **`Conventions`:** Read `{{WORKSPACE}}/{{MAESTRO_CONFIG}}/references/conventions.md` — for artifact locations and ownership

### On-demand (read only when needed)
- **Repo Fingerprint (working file):** Read `{{WORKSPACE}}/knowledge/repo-fingerprint.md` — stack hints may inform model choice (e.g., a Rust-heavy repo favors models strong at Rust)

## The Sections

| Section | Plays in | Character |
| ------- | -------- | --------- |
| `coordination` | orchestrate | bookkeeping, routing, user gates — capable but economical |
| `composition` | compose, rehearse, elaborate | reasoning-heavy design work; the "higher-quality model" elaborate distills from |
| `implementation` | play subagents | cheap and fast code production against precise Plan specs |
| `debugging` | tune subagents | systematic investigation — mid-to-strong reasoning |
| `testing` | arrange, audition | test design and execution — economical |
| `documentation` | score | clear prose — economical |

Sections are fixed; do not invent new ones. If a workflow stage seems unrepresented, it shares its section's assignment.

## Validation

- If a section argument was provided and doesn't match a section name, inform the user of the valid sections and exit
- If `{{WORKSPACE}}/knowledge/instruments.md` cannot be written, abort with error

## Core Workflow

### Phase 0: Setup

1. Read `{{WORKSPACE}}/knowledge/instruments.md` if it exists — current assignments
2. **Detect Harness:** Check which config directories exist under `{{WORKSPACE}}`: `.omp`, `.claude`, `.opencode`, `.agents`. All detected harnesses get application guidance in Phase 3.

### Phase 1: Assignment Interview

For each requested section (all sections if no argument):

1. Present the section, what plays in it, and its current assignment (`session default` if unset)
2. Ask: "Which model should play [section]? Give a model selector your harness understands (e.g., `anthropic/claude-opus-4-6`, `openai/gpt-5.4:high`), a model selector your harness understands, or 'skip' to leave as session default."
3. Record exactly what the user supplies. Never guess, complete, or "fix" a model name — an invalid selector fails at spawn time and that is the user's call to make.

### Phase 2: Write Assignments

Write or update `{{WORKSPACE}}/knowledge/instruments.md` following the format below. Preserve sections the user did not edit.

```markdown
# Instruments

> Model assignments for Maestro workflow sections. Managed by /instruments.
> Consumers: orchestrate (spawn hints), agents' frontmatter, human operators.

Last updated: {YYYY-MM-DD}

| Section    | Model                    | Notes                          |
| ---------- | ------------------------ | ------------------------------ |
| coordination   | session default         |                                |
| composition    | {user selector}         | reasoning-heavy                |
| implementation | {user selector}         | cheap, fast                    |
| debugging      | {user selector}         |                                |
| testing        | session default         |                                |
| documentation  | session default         |                                |

## Application Notes

{Per-harness application notes from Phase 3, recorded so future sessions
don't re-derive them.}
```

### Phase 3: Application Guidance

Report how each detected harness applies the assignments:

- **Oh My Pi (`.omp/` present):** Subagent models route through settings — set `task.agentModelOverrides` (e.g., `play: <implementation model>`, `tune: <debugging model>`) in project `.omp/config.yml`, or define named roles in `modelRoles` and reference them as `model: "@role"` in agent frontmatter. Skills themselves run on the session model. Skills themselves run on the session model: switch the session model to match the section before invoking it, or rely on orchestrate's spawn hints.
- **Claude Code (`.claude/` present):** Add a `model:` field to the frontmatter of installed `.claude/agents/play.md` (implementation) and `tune.md` (debugging). Skills run on the session model.
- **OpenCode (`.opencode/` or `.agents/` present):** Set the `model:` field in the agent markdown frontmatter. Skills run on the session model.

Then ask: "Apply now where supported? [Yes / No]" — only on "Yes", edit installed agent frontmatter or config files, showing each exact edit before making it. These files live outside `knowledge/`; that exception is authorized by this step's explicit user approval, nothing else.

## Quality Checklist

Before completing:

- [ ] Every requested section presented with current assignment and confirmed with the user
- [ ] Model selectors recorded verbatim from the user — zero invented models
- [ ] `instruments.md` written/updated; unedited sections preserved
- [ ] Application notes matched to actually-detected harness directories
- [ ] Any file outside `knowledge/` was edited only after explicit per-file approval

## Critical Boundaries

- **Knowledge folder only,** except the explicitly approved application edits in Phase 3
- **No invented selectors:** record user input verbatim or `session default`
- **No behavior change without approval:** writing `instruments.md` records intent; applying it to agent configs requires the Phase 3 gate

## Execution

Use the optional section argument from the invocation, then proceed with Phase 0: Setup.
