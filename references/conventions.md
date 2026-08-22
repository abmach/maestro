# Conventions

> The shared contract for every Maestro skill and agent: workspace resolution, status vocabularies, retry semantics, artifact locations, and file ownership. Skills restate the essentials in their Pre-flight; this file is authoritative. When any skill text and this file disagree, this file wins — fix the skill text.

## Workspace Resolution

- `{{WORKSPACE}}` = workspace root. Resolve once per session and reuse: `git rev-parse --show-toplevel`; fall back to cwd outside a git repo.
- **Spec files** live at `{{WORKSPACE}}/{{MAESTRO_CONFIG}}/references/` (installed bundle). They define *formats*.
- **Working files** live in the workspace (`knowledge/`, `plans/`, `issues/`). They hold *project truth*.
- Never confuse the two: to check domain language, read `knowledge/contexts.md`, not `references/contexts.md`. Read the spec only to learn the format before writing.

## Placeholders

- `{{WORKSPACE}}` — resolved at runtime per the rule above. Never substituted by the installer.
- `{{MAESTRO_CONFIG}}` — substituted by `Install-Maestro.ps1` with the install location (`.agents`, `.claude`, or `.opencode`). Must appear literally in bundle source files.

## Status Vocabularies

Plans (Plan file and Plans Index):

- ✅ Done · 🔄 In progress · ⏳ Pending · ⚠️ Blocked · ❌ Failed

Docs markers (Plans Index, appended after ✅):

- `⏳` docs pending · `📝` docs done · no marker = docs unaffected

Issues (Issue file and Issues Index):

- 🟢 Open · 🔄 In Progress · ✅ Resolved · ⚪ Wontfix

## Milestone Retries (binding on orchestrate)

`Retries` counts **spawns, not failures**:

1. Immediately **before** spawning `play` for a milestone, orchestrate increments that milestone's `Retries` in the Plan file. Crash-safe: an in-flight attempt is always counted.
2. If `Retries >= 3`, orchestrate refuses to spawn; it marks the milestone `❌ Failed` and creates an `Issue`.
3. Never reset `Retries` to `0` during crash recovery; resume preserves it.
4. On a `play` return, orchestrate writes **only the status** (Done/Failed). It does not touch `Retries`.

## Artifact and Directory Map

| Path | Committed | Written by |
| ---- | --------- | ---------- |
| `plans/` + `plans/index.md` | yes | compose (create), orchestrate/score/elaborate (status + content) |
| `issues/` + `issues/index.md` | yes | orchestrate (create on failure/regression), tune (status + investigation) |
| `knowledge/` (`contexts.md`, `adrs/`, `repo-fingerprint.md`) | yes | prelude (bootstrap), rehearse (inline updates) |
| `tests/` | yes | arrange — flat, no subdirectories |
| `tests/screenshots/baselines/` | yes | first audition run or `--update-snapshots` |
| `test-results/` | **no** (gitignore) | audition runtime artifacts: actual/diff screenshots, logs, `summary.json` |
| `knowledge/instruments.md` | yes | instruments (model assignments per workflow section) |

**Visual regression contract:** baselines live under `tests/screenshots/baselines/` (Playwright top-level `snapshotPath`; see `testing-tech-preferences.md`). Every other artifact — actuals, diffs, failure shots, logs — lands under `test-results/`. Consumers (orchestrate's routing, score's docs) use **only the paths reported in `audition`'s result summary**. Never assume an artifact location you were not told.

## File Ownership Matrix

| Actor | May write | Must NOT |
| ----- | --------- | -------- |
| compose | `plans/**` | code, tests, `knowledge/` |
| prelude, rehearse | `knowledge/**` | `plans/`, code |
| elaborate | the chosen Plan in `plans/**` | code, `knowledge/` |
| orchestrate | `plans/**`, `issues/**` (bookkeeping only) | any code/test/doc *content*; git state mutations beyond the surgical discard in its Phase 1 |
| play | project source + co-located unit tests | `plans/**`, `issues/**`, git commits |
| tune | `issues/**` + fix code | `plans/**` (recommend a plan instead) |
| arrange | `tests/**` + root framework configs (e.g. `playwright.config.ts`, `vitest.config.*`, `.gitignore` entries) | `src/**` |
| audition | `test-results/**` | anything else |
| instruments | `knowledge/instruments.md` only (installed agent/config files only after explicit per-file user approval) | everything else |
| score | `docs/**`, `README.md`, `CHANGELOG.md` + the Plan's `Docs Updated` field + Plans Index docs marker | source code |

Where a skill's own text states a narrower target, the skill's text governs its ambition; this matrix is the floor. Skills that must touch bookkeeping outside their primary target (score → Plan/Index markers, arrange → root configs) have that exception stated in their own Target Folders line.

## Index Write Protocol (parallel safety)

- **Per-milestone status:** written to the Plan *file* immediately on each `play` return. Safe because orchestrate is the single writer of Plan files.
- **Plans Index:** one batched read-modify-write per wave, after all plays in the wave settle.
- **Crash recovery** reconciles the Plans Index *from* the Plan file. The Plan file is per-milestone ground truth.

## Subagent Protocol

- Skills run inline and share the orchestrator's context. Agents (`play`, `tune`) run isolated as subagents.
- Spawn prompts are narrow: `{plan-id} {milestone-id}` for play; `{issue-id}` for tune.
- **Subagents cannot reach the user.** Anything requiring user judgment is returned in the structured status (format defined by the producer: `agents/play.md` Phase 4, `agents/tune.md` Phase 6); the caller asks the user.
- Agents invoked directly by a user (`@play`, `@tune`) MAY interact with that user interactively.
