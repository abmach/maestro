---
name: prelude
description: Initialize a non-Maestro workspace by scanning the codebase to create Repo Fingerprint, Contexts, and ADRs so the bundle is ready to use; invoke via "/prelude" once when adopting Maestro into an existing project
---

# Prelude: Initialize Workspace for Maestro

Analyze an existing non-Maestro workspace and create the knowledge artifacts the bundle relies on (Repo Fingerprint, Contexts, ADRs) so that compose, rehearse, orchestrate, and the rest of the workflow have ground truth to operate against. One-shot setup skill — invoke once per project (re-run only to refresh).

## Pre-flight

- `{{WORKSPACE}}` = workspace root. Resolve once per session and reuse: `git rev-parse --show-toplevel`; fall back to cwd outside a git repo.
- Before your first write, read `{{WORKSPACE}}/{{MAESTRO_CONFIG}}/references/conventions.md` — statuses, retries, artifact paths, and file ownership are defined there and are binding.
- Working folder: `{{WORKSPACE}}`
- Target folders: `{{WORKSPACE}}/knowledge/` (Repo Fingerprint, Contexts, ADRs) — you should only create/modify files in this folder
- Required input: none — analyzes the current workspace

## References

Read reference specs on-demand when the workflow requires them — do NOT read all upfront.

### Always needed
- **`Repo Fingerprint`:** Read `{{WORKSPACE}}/{{MAESTRO_CONFIG}}/references/repo-fingerprint.md` — for the fingerprint format, structure, and the list of config files to scan
- **`Contexts`:** Read `{{WORKSPACE}}/{{MAESTRO_CONFIG}}/references/contexts.md` — for the glossary format, area headers, Language section, Term/Avoid convention
- **`ADRs`:** Read `{{WORKSPACE}}/{{MAESTRO_CONFIG}}/references/adrs.md` — for the ADR format, template, numbering, and the 3-criteria gate (hard to reverse, surprising without context, result of a real trade-off)

### On-demand (read only when needed)
- **`Tech Preferences`:** Read `{{WORKSPACE}}/{{MAESTRO_CONFIG}}/references/tech-preferences.md` — only if a detected stack component is unfamiliar and you want to confirm whether it counts as a deviation worth noting

### Cross-references
For how references relate to each other, see `{{WORKSPACE}}/{{MAESTRO_CONFIG}}/references/references-map.md`.

## Validation

- If `{{WORKSPACE}}/knowledge/repo-fingerprint.md` already exists: warn the user — "Prelude has already run here. Re-run to refresh the fingerprint and re-scan for contexts/ADRs? [Yes / No]". If "No", exit without changes.

## Core Workflow

### Phase 0: Setup

1. **Resolve Workspace Root** per the Pre-flight convention
2. **Check Existing State:** scan for existing `{{WORKSPACE}}/knowledge/repo-fingerprint.md`, `contexts.md`, and any `{{WORKSPACE}}/knowledge/adrs/` entries — informs the user which artifacts already exist
3. **Inform User:** state the plan — "Prelude will: (1) build Repo Fingerprint by scanning config files, (2) propose domain-language terms for Contexts, (3) archaeologize git history for ADR candidates. Confirm to proceed? [Yes / No]". Abort on "No".

### Phase 1: Repo Fingerprint

1. **Scan Config Files** per the Repo Fingerprint spec's "Scan Key Configuration Files" list (`package.json`, `pyproject.toml`, `.csproj`, `Cargo.toml`, `go.mod`, `.github/workflows/`, `docker-compose.yml`, etc.)
2. **Detect Stack** with specific versions for each section of the fingerprint:
   - Package manager, runtime, backend framework, frontend framework, UI library
   - Testing: unit framework, E2E framework, mocking libraries, coverage tools, additional testing tools
   - Database, ORM/database tools, build tools, CI/CD
3. **Cross-check Tech Preferences:** if a detected technology isn't in `Tech Preferences`, note it as a project deviation in the fingerprint's "Additional Context" section — the project's existing stack is authoritative; do NOT change the spec
4. **Write Fingerprint** at `{{WORKSPACE}}/knowledge/repo-fingerprint.md` following the Repo Fingerprint spec exactly (structure, section headers, version specificity)
5. **Report** to the user: a one-line stack summary of what was detected

### Phase 2: Domain Language Discovery (Contexts)

1. **Scan** the codebase for candidate domain terms:
   - Route names, model/type names, namespace folders, public classes/functions in domain layers
   - README, existing docs, comment blocks near domain logic
2. **Filter** out generic programming terms ("user", "config", "error", "logger", "request", "response") unless they carry project-specific meaning beyond their generic sense
3. **Group** candidates by inferred bounded context (filesystem areas, module boundaries). If a project has only one obvious context, use single-area structure; if multiple, use area headers with folder references per the Contexts spec
4. **Present candidates in batches** to the user for confirmation, with the user as the source of truth over the bundle's inference: "Candidate term: '{term}' (appears in: {files}). Inferred meaning: {short phrase}. Include in Contexts? [Yes as-is / Edit meaning / No / Skip rest]"
   - **Yes as-is:** accept the inferred meaning verbatim
   - **Edit meaning:** ask the user to provide the actual definition — "What does '{term}' mean in this project? Also, what alternative terms should be avoided (the `_Avoid_` list)?" — and use the user's wording, not the inferred one
   - **No:** drop the candidate
   - **Skip rest:** stop presenting candidates and write only the confirmed ones (whether accepted as-is or user-edited)
5. **Write Contexts** at `{{WORKSPACE}}/knowledge/contexts.md` following the Contexts spec (project header, area headers with folder refs `{folder/path/}`, Language section with `**Term**: def\n_Avoid_: ...` format, Relationships section if multi-context)
   - If zero terms confirmed: write the file with project header + empty Language section + note "_Ubiquitous language not yet identified. The rehearse and compose skills will add terms as they emerge during feature work._"

### Phase 3: ADR Archaeology

1. **Scan git history** for decisions that look architectural:
   - Commit messages mentioning "adopt", "replace", "migrate", "refactor", "switch from", "remove", "deprecate"
   - Major dependency additions/removals across the lockfile history (e.g., `git log --follow -- package.json yarn.lock Cargo.lock pyproject.toml`)
   - Significant directory restructurings or framework introductions
2. **Filter against the 3 ADR criteria** from the ADRs spec (all three must be true):
   - **Hard to Reverse** — undoing would cost real work
   - **Surprising Without Context** — a future reader would ask "why this way?"
   - **Result of a Real Trade-off** — genuine alternatives existed; the commit chose one for specific reasons
3. **Present candidates** to the user in batches, with the user as the source of truth over the bundle's inference: "Candidate ADR: '{commit summary}' (commit {short-hash}). Reversal cost: {low/medium/high}. Surprising because: {inference}. Likely alternatives that existed: {inference}. Create ADR? [Yes as-is / Edit rationale / No / Skip rest]"
   - **Yes as-is:** accept the inferred rationale verbatim, but still mark it as inferred in the body so the user can correct later if needed
   - **Edit rationale:** ask the user to provide the actual context and rationale — "Why was this decision taken? What alternatives were actually considered (not just inferred)? What was the trade-off?" — and use the user's wording. Mark it as user-confirmed (no inferred-rationale caveat). Also ask the user whether `status: accepted` or `status: proposed` is appropriate
   - **No:** drop the candidate (the decision doesn't meet the 3 criteria, or isn't ADR-worthy in the user's judgment)
   - **Skip rest:** stop presenting candidates and write only the confirmed ones
4. **For each confirmed ADR:**
   - Number sequentially — scan `{{WORKSPACE}}/knowledge/adrs/` for the highest existing number; if none, start at 0001. Zero-pad to four digits.
   - Write at `{{WORKSPACE}}/knowledge/adrs/{NNNN}-{slug}.md` following the ADR spec exactly:
     - Frontmatter: `status: accepted` (or `proposed` if the decision is contested)
     - Title (short, descriptive)
     - 1-3 sentence summary covering context, what was decided, and rationale
     - If rationale is inferred (commit message didn't explain), mark it as inferred in the body so the user can correct: "_Rationale inferred from commit context; verify against project history._"
5. **Lazily create `{{WORKSPACE}}/knowledge/adrs/`** when the first ADR is confirmed (per the ADRs spec's directory-creation rule)
6. **Report** to the user: "ADRs created: [N — list of titles]. Skipped: [count]."

### Phase 4: Readiness Report

Summarize what Maestro now knows about the workspace:

- **Repo Fingerprint:** one-line stack summary
- **Contexts:** N terms captured across M areas (or "no terms captured — will emerge during feature work")
- **ADRs:** N ADRs written (list titles, or "no ADR-worthy decisions found in git history")
- **Next steps:** inform the user:
  - "Maestro is ready. To start a new feature: `/compose <feature description>` to design a Plan, then `/orchestrate <plan-id>` to execute it."
  - "To refine domain language further as terms emerge: `/rehearse <plan or feature>` — it will extend `contexts.md` inline."

## Quality Checklist

Before reporting readiness:

- [ ] Repo Fingerprint written at `{{WORKSPACE}}/knowledge/repo-fingerprint.md` with all applicable stack components and specific versions
- [ ] All detected technologies noted; deviations from `Tech Preferences` recorded in "Additional Context" if any
- [ ] `{{WORKSPACE}}/knowledge/contexts.md` exists with project header and Language section (even if empty, with the note guiding to rehearse/compose)
- [ ] If multiple bounded contexts detected, area headers with folder references are in place per the Contexts spec
- [ ] Every ADR written meets all 3 criteria from the ADRs spec — no ADRs created for non-ADR-worthy decisions
- [ ] ADR numbering is sequential, zero-padded, slugged
- [ ] User was consulted for every domain-term and ADR confirmation — nothing auto-committed without sign-off
- [ ] All file paths followed `{{WORKSPACE}}/...` anchoring; no relative paths rooted at the skill folder
- [ ] Existing artifacts (if re-running) were overwritten only after explicit user confirmation

## Execution

No input is required. Proceed with Phase 0: Setup, then walk Phases 1-4 in order.
