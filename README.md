# Maestro

A bundle of [Agent Skills](https://agentskills.io) for AI-assisted software development. Maestro gives AI coding agents (Oh My Pi, OpenCode, Claude Code, and other Agent-Skills-compatible harnesses) a structured workflow for planning, implementing, testing, and documenting features — built to spend premium models on design reasoning and cheap ones on volume work — without locking you to a single platform.

[![pipeline status](https://gitlab.com/arthur_b_machado/maestro/badges/main/pipeline.svg)](https://gitlab.com/arthur_b_machado/maestro/-/commits/main)

## What's in the box

```
maestro/
├── Install-Maestro.ps1      # Installer script
├── VERSION                  # Bundle version (read by installer)
├── CHANGELOG.md             # Version history + upgrade/migration notes
├── skills/                  # Agent Skills (loaded on-demand when invoked)
│   ├── prelude/             # Bootstrap a non-Maestro workspace (Repo Fingerprint, Contexts, ADRs)
│   ├── compose/             # Create technical Plans from feature requests
│   ├── rehearse/            # Stress-test plans against domain language
│   ├── elaborate/           # Distill detail from stronger models into plans
│   ├── orchestrate/         # Execute plans via parallel subagents
│   ├── arrange/             # Write integration & E2E test specs
│   ├── audition/            # Run test suites and capture results
│   ├── score/               # Update docs after features ship
│   ├── instruments/         # Assign AI models to workflow sections (per-harness guidance)
│   └── interlude/           # Read-only status report: plans, issues, docs, next action
├── agents/                  # Subagent definitions (spawned by orchestrate or @mention)
│   ├── play.md              # Implements plan milestones via TDD
│   └── tune.md              # Resolves issues via systematic debugging
├── references/              # Specs for plan/issue/ADR/contexts formats
│   ├── conventions.md       # Shared contract: statuses, retries, artifact paths, ownership
│   ├── plan.md
│   ├── plans-index.md
│   ├── issue.md
│   ├── issues-index.md
│   ├── contexts.md
│   ├── adrs.md
│   ├── repo-fingerprint.md
│   ├── design-principles.md
│   ├── testing-principles.md
│   ├── tech-preferences.md
│   ├── testing-tech-preferences.md
│   └── references-map.md
└── tools/
    ├── validate-bundle.ps1  # Dev-time validator: frontmatter, links, contract consistency
│   ├── smoke-install.ps1    # End-to-end installer gate (temp dir, substitution, version stamp)
│   └── build-module.ps1     # Assembles the distributable MaestroKit module
```

**10 skills** + **2 agents** + **13 reference specs** + dev-time tooling (bundle validator, install smoke test, MaestroKit module builder).

## Installation

### Prerequisites

- PowerShell 7+ (`pwsh`)
- A target repo (the maestro bundle gets copied into the repo's config directory)

### Recommended: clone and run

```bash
git clone https://gitlab.com/arthur_b_machado/maestro.git
cd maestro
.\Install-Maestro.ps1 -Target D:\repos\my-app -Locations .omp,.claude -Force
```

Cloned files are plain local files you can read before running — nothing is downloaded and executed in one step.


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

| Location    | Skills | Agents | Platform coverage                                                        |
| ----------- | ------ | ------ | ------------------------------------------------------------------------ |
| `.agents`   | yes    | yes    | OpenCode (full). Oh My Pi discovers the skills natively, ignores agents/ |
| `.omp`      | yes    | yes    | Oh My Pi native — `.omp/skills/` + `.omp/agents/` (its only agent root)  |
| `.claude`   | yes    | yes    | Claude Code; skills also discovered by OpenCode and Oh My Pi             |
| `.opencode` | yes    | yes    | OpenCode native (highest precedence on OpenCode)                         |

Maestro is **all-or-nothing**: every supported location delivers the full bundle, including the markdown-defined `play`/`tune` subagents. Harnesses that cannot discover subagent definitions (Codex CLI, Gemini CLI, GitHub Copilot, Cursor, …) are not supported — a skills-only install would silently break `orchestrate`'s delegation model. On Oh My Pi, prefer `.omp`; `.agents` delivers skills natively there but its `agents/` folder is ignored.

### Scope: project or user

| | Project (default) | User |
| --- | --- | --- |
| Install target | repo root | your home (`~`) — e.g. `~/.omp`, `~/.claude` |
| Shared via git | yes — commit the config dir; teammates inherit everything | no — personal install |
| Upgrades | per-repo, explicit re-run | one command updates **every** project at once |
| Precedence | project config overrides user config where both exist (harness-native) | |

Project is the default because Maestro's core value is shared, committed Plans and conventions. Use `-Scope User` on personal machines when you want Maestro available in every session — including projects without any install:

```powershell
./Install-Maestro.ps1 -Locations .omp,.claude -Force -Scope User
```

(With `-Scope User`, omit `-Target` to install into your profile root.)

The installer copies `skills/`, `references/`, and `agents/` to each target location and substitutes `{{MAESTRO_CONFIG}}` placeholders in every `.md` file with the location string, so reference paths resolve correctly at runtime.

### Direct web install (no clone)

```powershell
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/abmach/maestro/main/tools/install-from-web.ps1))) `
    -Target D:\repos\my-app -Locations .omp,.claude -Force
```

Fallback (same bootstrap, served from the GitLab origin):

```powershell
& ([scriptblock]::Create((irm https://gitlab.com/arthur_b_machado/maestro/-/raw/main/tools/install-from-web.ps1))) `
    -Target D:\repos\my-app -Locations .omp,.claude -Force
```

Downloads the repo archive to a temp dir, runs the bundled installer, cleans up after itself. `-Version v0.4.0-public` pins **what gets installed** to an immutable tag (the downloader itself always comes from `main`) — this executes remote code, so review or pin. The repo must be publicly readable; private/bot-challenged downloads fail with guidance instead of executing anything.

### PowerShell module — MaestroKit

Build a distributable module from current sources:

```powershell
pwsh ./tools/build-module.ps1     # -> dist/module/MaestroKit
Import-Module ./dist/module/MaestroKit
Install-Maestro -Target D:\repos\my-app -Locations .omp,.claude -Force
Install-Maestro -Scope User       # or install once into your profile
Test-MaestroBundle                # validator passthrough
```

Same canonical scripts inside — zero logic duplication. Ideal for `-Scope User` installs on personal machines and for PSGallery publishing later.

### Idempotent re-runs and upgrades

Re-running the installer overwrites in place. To wipe stale folders before copying (useful after a skill rename or removal upstream — check `CHANGELOG.md` for renames and behavioral migrations):
```powershell
.\Install-Maestro.ps1 -Target . -Clean -Force -Locations .agents,.claude
```

The installer records the bundle version in each target's `MAESTRO_VERSION` file and ships `MAESTRO_CHANGELOG.md` alongside it, so upgrade auditing is self-contained in the consuming repo.

Non-interactive hosts (CI) must pass `-Force`; without it the installer fails closed rather than hanging on the overwrite prompt.

### Validate the bundle before installing

```powershell
pwsh ./tools/validate-bundle.ps1
```

Checks frontmatter integrity, placeholder correctness, markdown link resolution, canonical Pre-flight blocks in every skill/agent, and cross-file consistency of the retry rule. Run it after any bundle edit.

## The workflow

Once when adopting Maestro into an existing project, run `/prelude` first to create the knowledge artifacts (Repo Fingerprint, Contexts, ADRs). The workflow below then takes over. Every skill and agent shares one contract — `references/conventions.md` — covering workspace resolution, status vocabularies, milestone retry semantics, artifact locations, and file ownership.

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

Around the pipeline: `/instruments` (once — model assignments), `/interlude` (anytime — status snapshot), `@play PLAN-001 M2` / `@tune BUG-004` (direct invocation when you don't need orchestration).

## Why Maestro

Maestro is built for the current generation of strong models and capable harnesses, and it earns its keep through four value pillars, in order of durability:

1. **Cost arbitrage.** Cost is tokens × price, and implementation dominates token volume while design reasoning is small-batch. Maestro's Plans mandate exact file paths, API shapes, and test cases — and a precise spec needs a competent executor, not a premium one. Run `compose`/`rehearse`/`elaborate` on a reasoning-heavy model, `play` on a cheap fast one, and the dominant cost term drops by roughly an order of magnitude at unchanged ceiling quality. `/instruments` records the assignments; Oh My Pi applies them to spawns natively (`task.agentModelOverrides`), Claude Code and OpenCode via agent frontmatter.
2. **Parallel throughput.** Milestones form a DAG; every ready wave spawns one worker per milestone regardless of model strength. Wall-clock savings are orthogonal to how smart your models are.
3. **Review checkpoints before code exists.** Auditing a 200-line plan costs minutes; reviewing a 2,000-line diff costs hours. compose front-loads expensive-to-reverse decisions into the cheapest artifact to inspect.
4. **Durable, portable process state.** Plans, issues, retries, glossary, ADRs live in your repo — they survive compaction, crashes, harness switches, and teammates. Harness features are session-scoped; this layer is repo-scoped, which is why they compose rather than compete.

One rule of thumb governs the economics: **when milestones fail repeatedly, escalate the plan, not just the worker.** Three failed attempts usually mean an under-specified spec, and re-spawning stronger workers on it burns the savings the tiering created.

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

### First run on an existing project

```
0. /prelude                            → scans the workspace and creates
                                          Repo Fingerprint, Contexts, ADRs
                                          (one-time setup; re-run only to refresh)
```

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
6. /instruments                        → (optional) assign models per section
                                          (cheap implementation, reasoning-heavy
                                          composition) with per-harness guidance
```

Step 0 is once-per-project. Items 2, 3, and 5 are optional. `orchestrate` is the main entry point for execution.

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
├── tests/screenshots/baselines/  # Visual regression baselines (committed)
├── test-results/             # Test output: actuals, diffs, logs (gitignored)
└── docs/                     # Maintained by the score skill
```

All file formats are specified in the `references/` folder of the installed bundle; shared behavioral rules live in `references/conventions.md`.

## Multi-platform design

Maestro targets the [Agent Skills](https://agentskills.io) open standard. The bundle is skills **plus** markdown-defined subagents (`play`, `tune`) **plus** an orchestrator that spawns them in parallel — so a harness either supports all of that, or it is not supported:

| Harness | Install to | Parallel orchestration (`orchestrate` → `play`/`tune`) | Model routing (`/instruments`) |
| ------- | ---------- | ------------------------------------------------------ | ------------------------------ |
| Oh My Pi | `.omp` (full) or `.agents` (OpenCode only) | yes — `.omp/agents/` is its native subagent root | yes — `task.agentModelOverrides` / `modelRoles` |
| Claude Code | `.claude` | yes — `.claude/agents/` | yes — `model:` frontmatter on agents |
| OpenCode | `.opencode` or `.agents` | yes — native markdown agents | yes — `model:` frontmatter on agents |

On Oh My Pi, run sessions from the target repo root (or install agent definitions at user level, `~/.omp/agent/agents/`) — project-agent discovery is session-cwd-bound, so `play`/`tune` resolve only when the session lives in the workspace that has them installed.

Skills use only standard Agent-Skills frontmatter (`name`, `description`). Agents use Claude-Code/OpenCode-compatible frontmatter (`name`, `description`, `mode: subagent`) — Oh My Pi reads the same files and ignores the extra fields. No platform-specific tooling assumptions are baked into the workflow text; only the installer is PowerShell.

**Mirrors & contributions:** development happens on GitLab; the GitHub repository (if present) is an automated read-only mirror — please open issues and pull requests on GitLab.

## When not to use it

- **Solo, top-tier model, small features** — `compose` plus direct execution hits the 80% point; the full ceremony costs more than it saves.
- **One-shot throwaway scripts** — nothing here outlives the session enough to pay for itself.
- **Teams that won't read plans** — unreviewed Plans are pure overhead; the value collapses without the human checkpoint.

It earns its keep with batch feature work (parallel waves), cost-sensitive volume (model tiering), team settings (plans as async collaboration currency), mixed fleets including local/cheap models, and long-lived repos where the glossary/ADR layer compounds.

## License

MIT
