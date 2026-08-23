---
name: compose
description: Compose technical solutions - map a feature request to a Plan with milestones as a DAG, test tiers, and development specs; invoked via "/compose <feature>" to design before orchestrate executes
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
9. **Create Plan:** Generate a new `Plan` in `{{WORKSPACE}}/plans/` following the `Plan` specification
10. **Update Index:** Update the `{{WORKSPACE}}/plans/index.md` with the new `Plan` and status ⏳ Pending
11. **Completion Note:** If domain language shifted while planning — new terms coined, existing ones sharpened — point the user at `/rehearse`; it captures glossary updates and ADR-worthy decisions in `knowledge/`. You suggest only: `knowledge/` stays read-only for you.

## Quality Checklist

Before completing the `Plan`:

1. **Input Validated:** Ensure feature request is provided and clear
2. **Rehearse Option Offered:** User was given the option to refine domain language before `Plan` creation
3. **Context Alignment:** Use terminology from `{{WORKSPACE}}/knowledge/contexts.md` if it exists
4. **Technical Compatibility:** Match existing codebase patterns and frameworks
5. **No Ambiguity:** Define specific implementations, not placeholders
6. **Specification Compliance:** Follow the exact structure from the `Plan` specification
7. **Index Updated:** Ensure `{{WORKSPACE}}/plans/index.md` includes the new `Plan` (following `Plans Index` specification)
8. **Issues Considered:** Relevant existing `Issue`s from `{{WORKSPACE}}/issues/index.md` are considered in `Plan` design

## Execution

Use the feature request from the invocation, then proceed with Step 0: Input Validation.
