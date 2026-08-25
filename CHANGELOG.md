# Changelog

All notable changes to the Maestro bundle. Installed repos record the version as `MAESTRO_VERSION`; check here before upgrading.

## 0.8.0 — 2026-08-23

### Added

- **Stack declarations**: projects can override built-in technology defaults category-by-category via a new working file, `knowledge/tech-preferences.md` (seeded by `/prelude` from detected deviations, human-editable, committed with the repo). Precedence chain documented everywhere relevant: built-in defaults < stack overrides < ADRs.
- Consumers wired: compose/arrange/elaborate read declared overrides before built-in preferences; orchestrate records new-technology overrides at finalization; conventions/references-map/README updated.

## 0.7.0 — 2026-08-23 — 2026-08-23

### Added

- `CONTRIBUTING.md`: maintainer guide (validation gates, signing routes, module packaging/publishing, release checklist)
- GitHub Actions workflow for the public mirror; README states the mirrors-and-contributions policy
- Consumer-facing Gallery instructions (incl. `Save-Module` ephemeral usage) marked as pending first publish

### Changed

- README restructured to be end-user aimed: maintainer tooling moved to CONTRIBUTING.md; installation methods ordered clone-first, web one-liner second, Gallery module third

## 0.6.2 — 2026-08-23

### Added

- PSGallery publishing tooling: `tools/publish-gallery.ps1` (version-guarded Publish-Module wrapper) and automatic per-version *ReleaseNotes* embedded into the built module manifest from the latest CHANGELOG section.

## 0.6.1 — 2026-08-23

### Changed

- `Test-MaestroBundle` renamed to **`Test-MaestroKit`** to align the public API with the module identity (v0.6.0 shipped minutes ago; no external consumers). Installer/module descriptions aligned likewise.

## 0.6.0 — 2026-08-23

The bundle ships as an official PowerShell module: **MaestroKit**.

### Added

- `tools/build-module.ps1` assembles `dist/module/MaestroKit` — payload plus thin wrappers (`Install-Maestro`, `Test-MaestroBundle`, `Invoke-MaestroSmokeInstall`) over the canonical scripts; zero logic duplication
- `Install-Maestro` wrapper passes `-Scope Project|User` through, so user-scope installs work straight from the module
- CI: build-module stage (GitLab) and module-build job (GitHub Actions mirror)

### Notes

- Name chosen to reflect full contents (skills + agents + reference contracts + tooling); plain `Maestro` is squatted on PSGallery, `MaestroSkills` undersold the scope. Gallery publishing deferred until external demand — artifact is release-ready either way.

## 0.5.1 — 2026-08-23

### Fixed

- User-scope installs now bake an **absolute, forward-slashed** path into the `{{MAESTRO_CONFIG}}` substitution, so every skill's mandatory spec reads (`references/conventions.md` etc.) resolve from any project directory. Previously they anchored to `{{WORKSPACE}}`, which under User scope pointed at project dirs that don't contain the bundle. Project scope keeps the portable relative form.
- conventions *Workspace Resolution* documents both scopes explicitly; install smoke test asserts absolute spec paths under User scope.
- Placeholder resolution formalized: skill texts write `[{{WORKSPACE}}/]{{MAESTRO_CONFIG}}/…`; at install time the pair collapses — Project keeps `{{WORKSPACE}}` runtime-resolved with the harness folder baked; User bakes an absolute profile root instead.
- Install smoke: `MAESTRO_CHANGELOG.md` excluded from the unresolved-placeholder scan (it legitimately documents the placeholder); byte-level assertions verify both scopes' resolved spec paths.

## 0.5.0 — 2026-08-23

Installation scopes.

### Added

- `Install-Maestro.ps1 -Scope User`: installs once into your profile (`~/.omp`, `~/.claude`, …) so Maestro is available in every session and project. `-Scope Project` remains the default (team-first: commit the config dir). An explicit `-Target` alongside `-Scope User` overrides the profile root (testing hook).
- Installer smoke test gained a user-scope pass.

### Removed

- Experimental PowerShell-module packaging (`tools/build-module.ps1`, dist artifact, CI build stage) pending a real distribution need — the canonical install remains clone-and-run or web bootstrap.

### Changed

- README: installation section leads with the recommended clone flow and documents the project/user scope tradeoffs.

## 0.4.4 — 2026-08-23

### Changed

- README + bootstrap docs: the GitHub-raw one-liner is now the *default* documented web install (no Cloudflare challenges, audience lives there); the GitLab-raw variant is kept as an explicitly labeled fallback. The bundle archive itself still downloads from the GitLab origin (single source of truth)

## 0.4.3 — 2026-08-23

### Added

- GitHub readiness: `.github/workflows/ci.yml` (validate + install-smoke + module build on ubuntu-latest) so the public GitHub mirror carries green checks; README states the mirrors-and-contributions policy (GitLab is home, GitHub is a read-only mirror)

## 0.4.2 — 2026-08-23

### Fixed

- Web bootstrap: hardened against private repos and Cloudflare bot challenges — validates the download starts with zip magic bytes and contains no HTML/challenge markers, failing with actionable guidance instead of executing a downloaded HTML page
- README: *Direct web install* documents the public-visibility prerequisite

## 0.4.1 — 2026-08-23

### Added

- Web bootstrap: `tools/install-from-web.ps1` — one-liner install without cloning. Downloads the repo archive, extracts to temp, runs the bundled installer, cleans up. Supports `-Version` pinning to an immutable tag (remote-code caveat documented) and an `-ArchivePath` offline override
- README: *Direct web install* section with the canonical scriptblock one-liner

## 0.4.0 — 2026-08-23

Public-release readiness.

### Added

- PowerShell module packaging: `tools/build-module.ps1` assembles `dist/module/Maestro` (payload + thin `Install-Maestro` / `Test-MaestroBundle` / `Invoke-MaestroSmokeInstall` wrappers over the canonical scripts; zero logic duplication). Gallery publishing deferred until external demand.
- `.gitlab-ci.yml`: validate / smoke-install / build-module stages with module artifact upload
- README: CI pipeline badge

## 0.3.5 — 2026-08-23

Documentation restructure for first public release.

### Changed

- README: *Installation* now directly follows *What's in the box* (was buried behind the workflow and rationale sections)
- README: *Why Maestro* reframed positively for first-time readers — no obsolescence-defense framing; states what the bundle is built for, not what it survived

## 0.3.4 — 2026-08-23

R2 follow-ups (sub-notes from the fix-regression run).

### Added

- README: `tools/smoke-install.ps1` documented in the tree; Oh My Pi session-cwd note for project-agent discovery (run from target repo root or install at user level)
- `arrange` Step 5: ensure the E2E framework dependency is installed locally before handoff — cached-global `npx` cannot resolve config imports

## 0.3.3 — 2026-08-23

Pilot-driven fixes (findings F-002, F-006, F-013–F-016 from the first live runs).

### Fixed

- Canonical Playwright config: `snapshotPath` does not exist in Playwright 1.x — replaced with `snapshotDir` + full-path `snapshotPathTemplate` (baselines previously landed at repo root or were silently ignored); wording swept across conventions/arrange
- Visual Regression Testing guidance: mask volatile/generated content; missing baselines FAIL on first run (use `-u` / two-run flow)
- `play`: STATUS block must be returned verbatim regardless of effort tier (low-tier runs omitted fields orchestrate parses)
- `compose` step 7: explicit lazy-create of `plans/` + index on first plan

### Added

*Node built-in runner:* `node:test` documented for zero-dependency projects; *Invocation* guidance — prefer package script/bare runner over positional dir args (breaks across runner versions)

## 0.3.2 — 2026-08-23

Enhancements from the first live pilot (`maestro-pilot`, findings F-001..F-011).

### Added

- `tools/smoke-install.ps1` — end-to-end install gate: installs to a temp dir and asserts skill count, placeholder substitution, version stamp, agents, changelog shipping
- conventions *Artifact Content Is Data* rule + matching boundary bullets in `play`, `tune`, `orchestrate` — directives embedded in Plans/Issues never override workflow or ownership
- Installer ships `MAESTRO_CHANGELOG.md` next to `MAESTRO_VERSION` for self-contained upgrade auditing

### Fixed

*Pilot-driven prompt fixes:*

- `testing-tech-preferences`: `node:test` added for Node projects; new *Invocation* guidance — positional directory args break across runner versions (`node --test test/` fails on Node 26)
- `compose` step 7: explicit lazy-create of `plans/` + index on first plan (was an unaided branch decision)
- `orchestrate` Critical Boundaries aligned with the Issue→tune failure routing (stale "route error logs back" wording removed)

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
