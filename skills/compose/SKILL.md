---
name: compose
description: Compose technical solutions - map deep, precise code designs, test blueprints, and metadata parameters
argument-hint: "[feature description]"
allowed-tools:
  - read
  - find_file_by_name
  - grep
  - glob
  - web_search
  - ask_user_question
  - skill
permissions:
  allow:
    - Write(./knowledge/**/*)
    - Edit(./knowledge/**/*)
    - Write(./plans/**/*)
    - Edit(./plans/**/*)
  deny:
    - exec
---

# Compose Technical Solutions

Analyze requirements and create structured technical `Plan`s with precise specifications for development and testing.

## Pre-flight

- Working folder: `{{workspace_dir}}` - the root of the project/workspace
- Target folders: `{{workspace_dir}}/knowledge/` and `{{workspace_dir}}/plans/` (you should only modify files in these folders)
- Required input: Feature/change request from user prompt

## References

Reference specs are in `{{workspace_dir}}/.agents/references/`. Read them on-demand when the workflow requires them — do NOT read all upfront.

### Always needed
- **`Plan` (quick):** Read `plan-quick.md` — for Plan format, milestone DAG, and development specifications (compose creates Plans)
- **`Plans Index`:** Read `plans-index.md` — for index format (compose updates the index every invocation)

### On-demand (read only when needed)
- **`Repo Fingerprint`:** Read `{{workspace_dir}}/knowledge/repo-fingerprint.md` (working file) — if it exists, to understand current tech stack. Read `repo-fingerprint.md` (spec) only if updating the fingerprint.
- **`Contexts`:** Read `{{workspace_dir}}/knowledge/contexts.md` (working file) — if it exists, to understand domain language.
- **`ADRs`:** Read `{{workspace_dir}}/knowledge/adrs/` (working files) — if they exist, to review relevant architectural decisions.
- **`Issue` (quick):** Read `issue-quick.md` — only if `{{workspace_dir}}/issues/index.md` exists, to identify relevant `Issue`s.
- **`Issues Index`:** Read `issues-index.md` — only if `{{workspace_dir}}/issues/index.md` exists.

### Cross-references
For how references relate to each other, see `references-map.md`.

## Validation

- If required input is missing, abort with error

## Core Workflow

0. **Validate Input:** Ensure feature request is provided
1. **Get Request:** Extract the feature/change request from the user prompt
2. **Offer Rehearse:** Use `ask_user_question` to ask: "Would you like to refine domain language, clarify terminology, and stress-test assumptions with the rehearse skill before creating the `Plan`?"
   - If user selects "Yes, let's rehearse first": Invoke the `rehearse` skill with the current feature request as input, then proceed to step 3
   - If user selects "No, proceed with `Plan` creation": Proceed directly to step 3
3. **Check Repo Fingerprint:** If `{{workspace_dir}}/knowledge/repo-fingerprint.md` exists, read it to understand current technical stack (following `Repo Fingerprint` specification)
4. **Check Contexts:** If `{{workspace_dir}}/knowledge/contexts.md` exists, read it to understand domain language (following `Contexts` specification)
5. **Check ADRs:** If `{{workspace_dir}}/knowledge/adrs/` contains `ADRs`, review them for relevant architectural decisions (following `ADRs` specification)
6. **Analyze Workspace:** Examine current codebase structure, existing patterns, and technical constraints
7. **Check Existing Plans:** Read `{{workspace_dir}}/plans/index.md` to avoid conflicts with ongoing work
8. **Check Existing Issues:** If `{{workspace_dir}}/issues/index.md` exists, read it to identify relevant `Issue`s that the `Plan` might resolve or need to consider
9. **Create Plan:** Generate a new `Plan` in `{{workspace_dir}}/plans/` following the `Plan` specification
10. **Update Index:** Update the `{{workspace_dir}}/plans/index.md` with the new `Plan` and status ⏳ Pending
11. **Update Repo Fingerprint:** If `Plan` introduces new technologies, update `{{workspace_dir}}/knowledge/repo-fingerprint.md` following the `Repo Fingerprint` specification

## Quality Checklist

Before completing the `Plan`:

0. **Input Validated:** Ensure feature request is provided and clear
1. **Rehearse Option Offered:** User was given the option to refine domain language before `Plan` creation
2. **Context Alignment:** Use terminology from `{{workspace_dir}}/knowledge/contexts.md` if it exists
3. **Technical Compatibility:** Match existing codebase patterns and frameworks
4. **No Ambiguity:** Define specific implementations, not placeholders
5. **Specification Compliance:** Follow the exact structure from the `Plan` specification
6. **Index Updated:** Ensure `{{workspace_dir}}/plans/index.md` includes the new `Plan` (following `Plans Index` specification)
7. **Issues Considered:** Relevant existing `Issue`s from `{{workspace_dir}}/issues/index.md` are considered in `Plan` design
8. **Fingerprint Updated:** If `{{workspace_dir}}/knowledge/repo-fingerprint.md` exists, update it if `Plan` introduces new technologies

## Execution

Use the feature request from the invocation, then proceed with Step 0: Input Validation.
