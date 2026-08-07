# Maestro

A bundle of [Agent Skills](https://agentskills.io) for AI-assisted software development. Maestro gives AI coding agents (OpenCode, Claude Code, and other Agent-Skills-compatible systems) a structured workflow for planning, implementing, testing, and documenting features — without locking you to a single platform.

## What's in the box

```
maestro/
├── Install-Maestro.ps1      # Installer script
├── VERSION                  # Bundle version (read by installer)
├── skills/                  # Agent Skills (loaded on-demand when invoked)
│   ├── compose/             # Create technical Plans from feature requests
│   ├── rehearse/            # Stress-test plans against domain language
│   ├── elaborate/           # Distill detail from stronger models into plans
│   ├── orchestrate/         # Execute plans via parallel subagents
│   ├── arrange/             # Write integration & E2E test specs
│   ├── audition/            # Run test suites and capture results
│   └── score/               # Update docs after features ship
├── agents/                  # Subagent definitions (spawned by orchestrate or @mention)
│   ├── play.md              # Implements plan milestones via TDD
│   └── tune.md              # Resolves issues via systematic debugging
└── references/              # Specs for plan/issue/ADR/contexts formats
    ├── plan.md
    ├── plans-index.md
    ├── issue.md
    ├── issues-index.md
    ├── contexts.md
    ├── adrs.md
    ├── repo-fingerprint.md
    ├── design-principles.md
    ├── testing-principles.md
    ├── tech-preferences.md
    ├── testing-tech-preferences.md
    └── references-map.md
```

**7 skills** + **2 agents** + **12 reference specs**.

## The workflow

```
  User request
       │
       ▼
   compose ──▶ Creates a Plan (DAG of milestones)
       │
       ▼
   rehearse ──▶ (optional) Sharpens domain language, challenges assumptions
       │
       ▼
   elaborate ──▶ (optional) Adds detail distilled from stronger models
       │
       ▼
   orchestrate ──── spawns ──▶ play (parallel, one per ready milestone)
       │                         │
       │                         ▼
       │                    Returns structured status (Done/Failed)
       │
       ├──▶ arrange (writes E2E tests from Plan)
       ├──▶ audition (runs tests, captures results)
       │
       │  ┌── Visual regression failures?
       │  │    1. Cross-reference Plan: intended change? → update baseline
       │  │    2. Real defect? → create Issue, ask user: fix now or defer
       │  │    3. Fix now → spawn tune subagent
       │  └─
       │
       ▼
   score (updates README/docs/changelog if Plan's Docs Affected = true)
       │
       ▼
   Done
```

## Installation

### Prerequisites

- PowerShell 7+ (`pwsh`)
- A target repo (the maestro bundle gets copied into the repo's config directory)

### Install into a target repo

```powershell
.\Install-Maestro.ps1 -Target D:\Personal\my-app
```

Defaults to installing into `.agents/` (the Agent-Skills-compatible location, works on OpenCode).

### Choose where to install

```powershell
# Claude Code only
.\Install-Maestro.ps1 -Target D:\Personal\my-app -Locations .claude

# OpenCode native
.\Install-Maestro.ps1 -Target D:\Personal\my-app -Locations .opencode

# Both Claude Code and OpenCode
.\Install-Maestro.ps1 -Target D:\Personal\my-app -Locations .agents,.claude,.opencode
```

Supported locations and what they enable:

| Location    | Skills | Agents | Platform coverage                              |
| ----------- | ------ | ------ | ---------------------------------------------- |
| `.agents`   | yes    | yes    | OpenCode (Claude-compatible discovery path)    |
| `.claude`   | yes    | yes    | Claude Code; also discovered by OpenCode       |
| `.opencode` | yes    | yes    | OpenCode native (highest precedence on OpenCode) |

The installer copies `skills/`, `references/`, and `agents/` to each target location and substitutes `{{MAESTRO_CONFIG}}` placeholders in every `.md` file with the location string, so reference paths resolve correctly at runtime.

### Idempotent re-runs and upgrades

Re-running the installer overwrites in place. To wipe stale folders before copying (useful after a skill rename or removal upstream):

```powershell
.\Install-Maestro.ps1 -Target . -Clean -Force -Locations .agents,.claude
```

The installer records the bundle version in each target's `MAESTRO_VERSION` file so you can audit which Maestro version a repo is on.

## Usage

### With OpenCode

1. Install Maestro into your repo (see above).
2. Open your project in OpenCode.
3. Skills are discovered automatically. Invoke any skill by typing `/skill-name` or letting the agent load it when relevant:
   - `/compose Add user authentication with JWT`
   - `/rehearse the auth plan I just composed`
   - `/orchestrate AUTH-001`
4. `play` and `tune` are subagents — invoke them via the agent menu (`Tab` to cycle, or `@mention`), or let `orchestrate` spawn them automatically.

### With Claude Code

1. Install Maestro with `-Locations .claude`.
2. Open Claude Code in your project.
3. Skills are discovered from `.claude/skills/`. Invoke with `/skill-name`:
   - `/compose Add user authentication with JWT`
   - `/orchestrate AUTH-001`
4. `play` and `tune` are subagents — invoke with `@play` / `@tune`, or let `orchestrate` spawn them automatically.

### Typical flow

```
1. /compose <feature request>          → creates a Plan (DAG of milestones)
2. /rehearse <feature >                → (optional) refine domain language
3. /elaborate <plan-id>                → (optional) add detail for execution
4. /orchestrate <plan-id>              → executes the plan:
                                          spawns play subagents in parallel,
                                          then arrange + audition for tests,
                                          routes visual regressions to tune
5. /score <plan-id>                    → updates docs (if Docs Affected=true)
```

Items 2, 3, and 5 are optional. `orchestrate` is the main entry point for execution.

## What Maestro creates in your repo

When you compose a Plan, Maestro lazily creates these directories in your project root:

```
your-repo/
├── plans/                    # Plans (DAG of milestones) and index.md
├── issues/                   # Issues (bugs, build failures) and index.md
├── knowledge/                # Domain language, ADRs, repo fingerprint
│   ├── contexts.md           # Ubiquitous language glossary
│   ├── adrs/                 # Architectural Decision Records
│   └── repo-fingerprint.md   # Tech stack snapshot
├── tests/                    # E2E test specs (flat, no subdirectories)
├── test-results/             # Test output (gitignored)
└── docs/                     # Maintained by the score skill
```

All file formats are specified in the `references/` folder of the installed bundle.

## Multi-platform design

Maestro targets the [Agent Skills](https://agentskills.io) open standard. It works on:

- **OpenCode** — fully compatible. Install to `.agents/`, `.opencode/`, or both.
- **Claude Code** — fully compatible. Install to `.claude/`.
- **Other Agent-Skills-compatible systems** — install to whichever config directory the system scans.

Skills use only standard Agent-Skills frontmatter (`name`, `description`). Agents use Claude-Code/OpenCode-compatible frontmatter (`name`, `description`, `mode: subagent`). No platform-specific tooling assumptions are baked into the bundle — the workflow text is portable.

## License

MIT
