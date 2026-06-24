---
name: score
description: Document implementation changes - audit finished code and maintain manuals, Readmes, and API descriptions
argument-hint: "[plan ID/code]"
subagent: true
allowed-tools:
  - read
  - find_file_by_name
  - grep
  - write
  - edit
permissions:
  allow:
    - Read(./plans/**/*)
    - Read(./tests/screenshots/**/*)
    - Write(./docs/**/*)
    - Edit(./docs/**/*)
    - Write(./docs/screenshots/**/*)
    - Write(./README.md)
    - Edit(./README.md)
  deny:
    - exec
---

# Document Implementation Changes

Maintain the single source of truth for repository documentation, API changes, and developer onboarding instructions by updating technical documentation to reflect implemented features.

## Pre-flight

- Working folder: `{{workspace_dir}}` - the root of the project/workspace
- Target folders: `{{workspace_dir}}/docs/`, `{{workspace_dir}}/README.md`, `{{workspace_dir}}/CHANGELOG.md` (you should only modify files in these locations)
- Required input: Plan ID/code from orchestrate

## Specifications & Methodologies

Read the following asset specification files from `{{workspace_dir}}/.agents/assets/` to understand formats, rules, and methodologies before updating documentation:

- **Plans Index:** [plans-index.md]({{workspace_dir}}/.agents/assets/plans-index.md) - plans index file format and management
- **Plan:** [plan.md]({{workspace_dir}}/.agents/assets/plan.md) - plan structure and metadata specification
- **Working Files:** Located in `{{workspace_dir}}/plans/` following specifications

## Validation

- If required input is missing or plan ID doesn't exist in plans index, abort with error

## Core Workflow

0. **Validate Input:** Ensure plan ID/code is provided
1. **Resolve Plan:** Read the Plans Index at `{{workspace_dir}}/plans/index.md` to find the full plan filename for the given plan ID/code
2. **Read Plan:** Construct the full plan file path and read the plan file to understand the implemented changes
3. **Analyze Changes:** Review the plan's development specifications, user flows, and any API changes to understand what documentation needs updating
4. **Update Documentation:** Update the relevant documentation files based on the implemented changes:
   - Technical manuals and guides in `{{workspace_dir}}/docs/`
   - API documentation if endpoints changed
   - `{{workspace_dir}}/README.md` if user-facing features changed
   - `{{workspace_dir}}/CHANGELOG.md` if significant changes occurred
5. **Handle Screenshots:** If the plan includes visual changes, copy relevant screenshots from `{{workspace_dir}}/tests/screenshots/` to `{{workspace_dir}}/docs/screenshots/` and embed them in the documentation

## Quality Checklist

Before completing the documentation updates:

0. **Input Validated:** Ensure plan ID/code is provided and exists in plans index
1. **Plan Read:** Successfully read and understood the implemented changes from the plan file
2. **Changes Reflected:** All implemented changes from the plan are reflected in the documentation
3. **API Accuracy:** API changes are documented with accurate request/response formats
4. **User-Friendly Language:** User-facing features are explained in clear, user-friendly language
5. **Screenshot Integration:** Screenshots are properly embedded and referenced with correct paths
6. **No Placeholders:** No placeholder text or TODO comments remain in documentation
7. **Link Validation:** All relative paths and file references are correct
8. **Style Consistency:** Documentation follows the project's established style and format
