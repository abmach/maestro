---
name: compose
description: Compose technical solutions - map a feature request to a Plan with an Intent layer (purpose, FR outcomes, non-goals), milestones as a DAG, test tiers, and development specs; invoked via "/compose <feature>" to design before cue approves and orchestrate executes
argument-hint: "[feature description]"
---

# Compose Technical Solutions

Analyze requirements and create structured technical `Plan`s with precise specifications for development and testing.

## Pre-flight

- `{{WORKSPACE}}` = workspace root. Resolve once per session and reuse: `git rev-parse --show-toplevel`; fall back to cwd outside a git repo.
- Before your first write, read `{{WORKSPACE}}/{{MAESTRO_CONFIG}}/references/conventions.md` — statuses, retries, artifact paths, and file ownership are defined there and are binding.
- Working folder: `{{WORKSPACE}}`
- Target folders: `{{WORKSPACE}}/plans/` (you should only modify files in this folder). `{{WORKSPACE}}/knowledge/` is read-only context for you
- Required input: Feature/change request from user prompt

## References

Read reference specs on-demand when the workflow requires them — do NOT read all upfront.

### Always needed
- **`Plan`:** Read `{{WORKSPACE}}/{{MAESTRO_CONFIG}}/references/plan.md` — for Plan format, milestone DAG, and development specifications (compose creates Plans)
- **`Plans Index`:** Read `{{WORKSPACE}}/{{MAESTRO_CONFIG}}/references/plans-index.md` — for index format (compose updates the index every invocation)

### On-demand (read only when needed)
- **`Repo Fingerprint`:** Read `{{WORKSPACE}}/knowledge/repo-fingerprint.md` (working file) — if it exists, to understand current tech stack
- **Stack Overrides (working file):** Read `{{WORKSPACE}}/knowledge/tech-preferences.md` if present — declared categories replace built-in preference defaults while shaping the Plan
- **Principles (working file):** Read `{{WORKSPACE}}/knowledge/principles.md` if present — standing invariants; embed the relevant ones in milestone `Must not` lines instead of restating them everywhere
- **System Behavior (working file):** Read `{{WORKSPACE}}/knowledge/system-behavior.md` if present — current capabilities; design against existing behavior instead of re-implementing it
- **`Contexts`:** Read `{{WORKSPACE}}/knowledge/contexts.md` (working file) — if it exists, to understand domain language.
- **`ADRs`:** Read `{{WORKSPACE}}/knowledge/adrs/` (working files) — if they exist, to review relevant architectural decisions.
- **`Issue`:** Read `{{WORKSPACE}}/{{MAESTRO_CONFIG}}/references/issue.md` — only if `{{WORKSPACE}}/issues/index.md` exists, to identify relevant `Issue`s.
- **`Issues Index`:** Read `{{WORKSPACE}}/{{MAESTRO_CONFIG}}/references/issues-index.md` — only if `{{WORKSPACE}}/issues/index.md` exists.

### Cross-references
For how references relate to each other, see `{{WORKSPACE}}/{{MAESTRO_CONFIG}}/references/references-map.md`.

## Validation

- If required input is missing, abort with error

## Core Workflow

0. **Validate Input:** Ensure feature request is provided
1. **Get Request:** Extract the feature/change request from the user prompt
2. **Offer Rehearse:** Ask the user: "Would you like to refine domain language, clarify terminology, and stress-test assumptions with the rehearse skill before creating the `Plan`?"
   - If user selects "Yes, let's rehearse first": Invoke the `rehearse` skill with the current feature request as input, then proceed to step 3
   - If user selects "No, proceed with `Plan` creation": Proceed directly to step 3
3. **Check Repo Fingerprint:** If `{{WORKSPACE}}/knowledge/repo-fingerprint.md` exists, read it to understand current technical stack (following `Repo Fingerprint` specification)
4. **Check Contexts:** If `{{WORKSPACE}}/knowledge/contexts.md` exists, read it to understand domain language (following `Contexts` specification)
5. **Check ADRs:** If `{{WORKSPACE}}/knowledge/adrs/` contains `ADRs`, review them for relevant architectural decisions (following `ADRs` specification)
6. **Analyze Workspace:** Examine current codebase structure, existing patterns, and technical constraints
7. **Check Existing Plans:** Read `{{WORKSPACE}}/plans/index.md` to avoid conflicts with ongoing work — on this project's first plan, `plans/` and its index are created lazily here per the `Plan` spec
8. **Check Existing Issues:** If `{{WORKSPACE}}/issues/index.md` exists, read it to identify relevant `Issue`s that the `Plan` might resolve or need to consider
9. **Create Plan:** Generate a new `Plan` in `{{WORKSPACE}}/plans/` following the `Plan` specification — write the `Intent` section to the Plan's tier (Purpose; FR-numbered Outcomes, EARS where behavior is conditional; Non-Goals with rationale), set `Approved: pending`, tag every milestone with the FRs it `Covers:`, and add a per-milestone `Why & Limits` block where rationale is non-obvious or violation risk is visible (optional at compose; `elaborate` fills the rest)
10. **Update Index:** Update the `{{WORKSPACE}}/plans/index.md` with the new `Plan` and status `⏳🔒` (pending, awaiting approval)
11. **Completion Note:** If domain language shifted while planning — new terms coined, existing ones sharpened — point the user at `/rehearse`; it captures glossary updates and ADR-worthy decisions in `knowledge/`. You suggest only: `knowledge/` stays read-only for you. Always end by pointing the user at `/cue {plan-id}`: the Plan is a draft until approved there, and `orchestrate` refuses unapproved Plans.

## Quality Checklist

Before completing the `Plan`:

1. **Input Validated:** Ensure feature request is provided and clear
2. **Rehearse Option Offered:** User was given the option to refine domain language before `Plan` creation
3. **Context Alignment:** Use terminology from `{{WORKSPACE}}/knowledge/contexts.md` if it exists
4. **Technical Compatibility:** Match existing codebase patterns and frameworks
5. **No Ambiguity:** Define specific implementations, not placeholders
6. **Intent Depth Met:** Purpose, Outcomes (EARS where conditional), and Non-Goals match the Test Tier's row in the Plan spec's Intent Depth table
7. **FR Coverage:** every FR in Intent Outcomes appears in at least one milestone's `Covers:` list
8. **Specification Compliance:** Follow the exact structure from the `Plan` specification, including `Approved: pending`
9. **Index Updated:** Ensure `{{WORKSPACE}}/plans/index.md` includes the new `Plan` with `⏳🔒` (following `Plans Index` specification)
10. **Issues Considered:** Relevant existing `Issue`s from `{{WORKSPACE}}/issues/index.md` are considered in `Plan` design

## Execution

Use the feature request from the invocation, then proceed with Step 0: Input Validation.
