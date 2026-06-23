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

Analyze requirements and create structured technical plans with precise specifications for development and testing.

## Pre-flight

- Working folder: `{{workspace_dir}}` - the root of the project/workspace
- Target folders: `{{workspace_dir}}/knowledge/` and `{{workspace_dir}}/plans/` (you should only modify files in these folders)
- Required input: Feature/change request from user prompt

## Specifications & Methodologies

Read the following asset specification files from `{{workspace_dir}}/.devin/assets/` to understand formats, rules, and methodologies before creating the plan:

- **Repo Fingerprint:** [repo-fingerprint.md]({{workspace_dir}}/.devin/assets/repo-fingerprint.md) - technical stack documentation specification
- **Tech Preferences:** [tech-preferences.md]({{workspace_dir}}/.devin/assets/tech-preferences.md) - preferred technologies specification
- **Testing Tech Preferences:** [testing-tech-preferences.md]({{workspace_dir}}/.devin/assets/testing-tech-preferences.md) - preferred testing frameworks and tools
- **Contexts:** [contexts.md]({{workspace_dir}}/.devin/assets/contexts.md) - domain language documentation specification
- **ADRs:** [adrs.md]({{workspace_dir}}/.devin/assets/adrs.md) - architectural decision records specification
- **Plan:** [plan.md]({{workspace_dir}}/.devin/assets/plan.md) - plan structure and metadata specification
- **Plans Index:** [plans-index.md]({{workspace_dir}}/.devin/assets/plans-index.md) - plans index specification
- **Working Files:** Created in `{{workspace_dir}}/knowledge/` and `{{workspace_dir}}/plans/` following their respective specifications

## Validation

- If required input is missing, abort with error

## Core Workflow

0. **Validate Input:** Ensure feature request is provided
1. **Get Request:** Extract the feature/change request from the user prompt
2. **Offer Rehearse:** Use `ask_user_question` to ask: "Would you like to refine domain language, clarify terminology, and stress-test assumptions with the rehearse skill before creating the plan?"
   - If user selects "Yes, let's rehearse first": Invoke the `rehearse` skill with the current feature request as input, then proceed to step 3
   - If user selects "No, proceed with plan creation": Proceed directly to step 3
3. **Check Repo Fingerprint:** If `{{workspace_dir}}/knowledge/repo-fingerprint.md` exists, read it to understand current technical stack (following `Repo Fingerprint` specification)
4. **Check Contexts:** If `{{workspace_dir}}/knowledge/contexts.md` exists, read it to understand domain language (following `Contexts` specification)
5. **Check ADRs:** If `{{workspace_dir}}/knowledge/adrs/` contains ADRs, review them for relevant architectural decisions (following `ADRs` specification)
6. **Analyze Workspace:** Examine current codebase structure, existing patterns, and technical constraints
7. **Check Existing Plans:** Read `{{workspace_dir}}/plans/index.md` to avoid conflicts with ongoing work
8. **Create Plan:** Generate a new plan in `{{workspace_dir}}/plans/` following the `Plan` specification
9. **Update Index:** Update the `{{workspace_dir}}/plans/index.md` with the new plan and status ⏳ Pending
10. **Update Repo Fingerprint:** If plan introduces new technologies, update `{{workspace_dir}}/knowledge/repo-fingerprint.md` following the `Repo Fingerprint` specification

## Quality Checklist

Before completing the plan:

0. **Input Validated:** Ensure feature request is provided and clear
1. **Rehearse Option Offered:** User was given the option to refine domain language before plan creation
2. **Context Alignment:** Use terminology from `{{workspace_dir}}/knowledge/contexts.md` if it exists
3. **Technical Compatibility:** Match existing codebase patterns and frameworks
4. **No Ambiguity:** Define specific implementations, not placeholders
5. **Specification Compliance:** Follow the exact structure from the `Plan` specification
6. **Index Updated:** Ensure `{{workspace_dir}}/plans/index.md` includes the new plan (following `Plans Index` specification)
7. **Fingerprint Updated:** If `{{workspace_dir}}/knowledge/repo-fingerprint.md` exists, update it if plan introduces new technologies
