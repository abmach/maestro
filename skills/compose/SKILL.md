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

## Specifications & Methodologies

Read the following reference specification files from `{{workspace_dir}}/.agents/references/` to understand formats, rules, and methodologies before creating the `Plan`:

- **Repo Fingerprint:** [repo-fingerprint.md]({{workspace_dir}}/.agents/references/repo-fingerprint.md) - technical stack documentation specification
- **Tech Preferences:** [tech-preferences.md]({{workspace_dir}}/.agents/references/tech-preferences.md) - preferred technologies specification
- **Testing Tech Preferences:** [testing-tech-preferences.md]({{workspace_dir}}/.agents/references/testing-tech-preferences.md) - preferred testing frameworks and tools
- **Contexts:** [contexts.md]({{workspace_dir}}/.agents/references/contexts.md) - domain language documentation specification
- **ADRs:** [adrs.md]({{workspace_dir}}/.agents/references/adrs.md) - architectural decision records specification
- **Issue:** [issue.md]({{workspace_dir}}/.agents/references/issue.md) - issue tracking and problem documentation specification
- **Issues Index:** [issues-index.md]({{workspace_dir}}/.agents/references/issues-index.md) - issues index specification
- **Plan:** [plan.md]({{workspace_dir}}/.agents/references/plan.md) - plan structure and metadata specification
- **Plans Index:** [plans-index.md]({{workspace_dir}}/.agents/references/plans-index.md) - plans index specification
- **Working Files:** Created in `{{workspace_dir}}/knowledge/`, `{{workspace_dir}}/plans/`, and `{{workspace_dir}}/issues/` following their respective specifications

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
