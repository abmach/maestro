---
name: score
description: Document implementation changes - audit finished code and update docs, README, and CHANGELOG for shipped features; invoked by orchestrate when Docs Affected = true, via "/score PLAN-001" for one plan, or "/score" alone for batch mode
argument-hint: "[plan ID/code] (optional — omit to process all pending finished plans)"
---

# Document Implementation Changes

Maintain the single source of truth for repository documentation, API changes, and developer onboarding instructions by updating technical documentation to reflect implemented features.

## Pre-flight

- `{{WORKSPACE}}` = workspace root. Resolve once per session and reuse: `git rev-parse --show-toplevel`; fall back to cwd outside a git repo.
- Before your first write, read `{{WORKSPACE}}/{{MAESTRO_CONFIG}}/references/conventions.md` — statuses, retries, artifact paths, and file ownership are defined there and are binding.
- Working folder: `{{WORKSPACE}}`
- Target folders: `{{WORKSPACE}}/docs/`, `{{WORKSPACE}}/README.md`, `{{WORKSPACE}}/CHANGELOG.md`, plus bookkeeping writes defined in `conventions.md` (the Plan's `Docs Updated` field and the Plans Index docs marker)
- Required input: `Plan` ID/code from orchestrate, OR no argument (batch mode — processes all pending finished plans)

## References

Read reference specs on-demand when the workflow requires them — do NOT read all upfront.

### Always needed
- **`Plan`:** Read `{{WORKSPACE}}/{{MAESTRO_CONFIG}}/references/plan.md` — for Plan format, milestone fields, and status management
- **`Plans Index`:** Read `{{WORKSPACE}}/{{MAESTRO_CONFIG}}/references/plans-index.md` — for index lookup and status updates

### On-demand (read only when needed)
- **`Repo Fingerprint`:** Read `{{WORKSPACE}}/knowledge/repo-fingerprint.md` (the working file) — only if the Plan introduced new tech that should be reflected in the fingerprint
- **`Tech Preferences`:** Read `{{WORKSPACE}}/{{MAESTRO_CONFIG}}/references/tech-preferences.md` — only if documentation standards or formatting are ambiguous

### Cross-references
For how references relate to each other, see `{{WORKSPACE}}/{{MAESTRO_CONFIG}}/references/references-map.md`.

## Validation

- If a `Plan` ID/code is provided: verify it exists in `Plans Index` and has the `✅⏳` marker (done, docs pending). If the entry has `✅📝` (already documented) or `✅` (no docs needed), inform the user and exit
- If no `Plan` ID/code is provided (batch mode): scan `Plans Index` for all entries with the `✅⏳` marker. If none found, inform the user and exit

## Core Workflow

### Mode Selection

0. **Determine Mode:** Check if a `Plan` ID/code was provided
   - **Single mode:** Process one specific plan
   - **Batch mode:** No argument provided — process all pending finished plans sequentially

### Single Plan Mode

1. **Resolve Plan:** Read the `Plans Index` at `{{WORKSPACE}}/plans/index.md` to find the full `Plan` filename for the given `Plan` ID/code
2. **Read Plan:** Construct the full `Plan` file path and read the `Plan` file to understand the implemented changes
3. **Analyze Changes:** Review the `Plan`'s development specifications, user flows, and any API changes to understand what documentation needs updating
4. **Update Documentation:** Update the relevant documentation files based on the implemented changes:
   - Technical manuals and guides in `{{WORKSPACE}}/docs/`
   - API documentation if endpoints changed
   - `{{WORKSPACE}}/README.md` if user-facing features changed
   - `{{WORKSPACE}}/CHANGELOG.md` if significant changes occurred
5. **Handle Screenshots:** If the `Plan` includes visual changes, copy relevant screenshots into `{{WORKSPACE}}/docs/screenshots/` and embed them in the documentation. Source only paths reported by `audition`'s result summary (baselines under `tests/screenshots/baselines/`, runtime shots under `test-results/`) — never assume a location
6. **Mark Documentation Updated:** Update the `Plan` file's `Docs Updated` field to `true`, and replace `⏳` with `📝` in the `Plans Index` (e.g., `✅⏳` → `✅📝`)

### Batch Mode

1. **Scan Plans Index:** Read `{{WORKSPACE}}/plans/index.md` and identify all plans with the `✅⏳` marker (done, docs pending)
2. **Process Each Plan:** For each pending plan, execute the Single Plan Mode workflow (steps 1-6 above)
3. **Summary:** After processing all plans, output a summary of which plans were documented and what files were updated

## Quality Checklist

Before completing the documentation updates:

0. **Input Validated:** `Plan` ID verified (single mode) or pending plans identified (batch mode)
1. **Plan Read:** Successfully read and understood the implemented changes from the `Plan` file
2. **Changes Reflected:** All implemented changes from the `Plan` are reflected in the documentation
3. **API Accuracy:** API changes are documented with accurate request/response formats
4. **User-Friendly Language:** User-facing features are explained in clear, user-friendly language
5. **Screenshot Integration:** Screenshots are properly embedded and referenced with correct paths
6. **No Placeholders:** No placeholder text or TODO comments remain in documentation
7. **Link Validation:** All relative paths and file references are correct
8. **Style Consistency:** Documentation follows the project's established style and format

## Execution

Use the `Plan` ID/code if provided (single mode), or scan the `Plans Index` for pending plans (batch mode), then proceed with the workflow.
