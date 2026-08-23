# Changelog

All notable changes to the Maestro bundle. Installed repos record the version as `MAESTRO_VERSION`; check here before upgrading.

## 0.3.1 — 2026-08-23

### Fixed

- Installer accepts comma-joined `-Locations` under `pwsh -File` (CLI mode binds a single string; multi-location installs were previously rejected as invalid) — caught by the first end-to-end install smoke test

### Changed

- `tune` claims an Issue (🔄 In Progress) at Phase 0 instead of Implementation — a crash mid-investigation now leaves accurate recovery state
- `tune` gains the No Git Commits boundary (parity with `play`)
- `play`/`tune` status blocks specify the `Files modified:` format (workspace-relative, comma-separated, single line) — orchestrate parses it for surgical git restore
- orchestrate granted the narrow `knowledge/repo-fingerprint.md` refresh right; conventions matrix aligned with its own Phase 3
- prelude readiness report mentions `/instruments` and `/interlude`; README workflow footnote covers around-the-pipeline skills

## 0.3.0 — 2026-08-23

Behavioral changes. **Upgrade with `-Clean`** if any skill was renamed since your installed version.

### Added

- `instruments` skill — per-section model assignments (`knowledge/instruments.md`) with per-harness application guidance
- `interlude` skill — read-only status overview with next-action recommendation
- `references/conventions.md` — binding shared contract: workspace rule, status vocabularies, retry semantics, artifact paths, file ownership, index-write protocol
- `integration` test tier between `smoke` and `e2e` — arrange + audition without browser flows or visual regression
- File-conflict scan before each spawn wave — overlapping *Files to modify* across ready milestones prompts serialize-or-proceed
- Fix-forward convention for spec-level failures — successor plan referencing the Issue; executed Plans stay untouched
- Optional *Assumptions & Open Questions* section in the Plan template
- `tools/validate-bundle.ps1` — dev-time checks: frontmatter, placeholders, links, canonical preflights, retry-rule consistency, references-map completeness, README counts, vocabulary drift

### Changed

- Non-visual test failures now route Issue → `tune` → re-audition (previously "back to a fresh `play`", which its narrow `{plan-id} {milestone-id}` contract could not accept)
- `Retries` counts spawns and increments immediately BEFORE each spawn (previously ambiguous between spawn- and completion-counting)
- One Issue per milestone-failure episode; subsequent attempts append to its Resolution Attempts instead of creating duplicates
- compose appends a completion note pointing at `/rehearse` when domain language may have shifted (suggest-only; compose never writes `knowledge/`)

### Migration

- Re-install with `-Locations .omp,.agents,.claude,.opencode -Clean -Force` to drop stale skill folders from older versions.
- Plans mid-execution need no action: crash recovery reconciles milestone statuses and preserves `Retries`.

## 0.2.1 — 2026-08-23

Positioning documentation: README gained *Why Maestro* (cost-tiering rationale) and *When not to use it*; orchestrate's Retry-Halt now reports repeated failures as a plan-quality signal; `elaborate` reads instrument assignments to target elaboration at the executor model.

## 0.2.0 — 2026-08-23

Full rewrite. `conventions.md` contract layer replaces drifted per-file restatements; canonical Playwright configuration corrected (`use:` options, top-level `snapshotPath`); single artifact-path contract (`tests/screenshots/baselines/` committed, `test-results/` gitignored); autonomous/interactive execution modes for `play`/`tune`; installer fails closed on non-interactive hosts; Oh My Pi support (`.omp`); validator introduced.

## 0.1.0

Initial release: eight skills, two agents, twelve reference specs, PowerShell installer targeting `.agents`, `.claude`, `.opencode`.
