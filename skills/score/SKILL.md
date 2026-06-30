---
name: score
description: Document implementation changes - audit finished code and maintain manuals, Readmes, and API descriptions. Run with a plan ID for a single plan, or without arguments to process all pending finished plans.
argument-hint: "[plan ID/code] (optional — omit to process all pending finished plans)"
allowed-tools:
  - read
  - find_file_by_name
  - grep
  - write
  - edit
permissions:
  allow:
    - Read(./plans/**/*)
    - Edit(./plans/**/*)
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
- Required input: `Plan` ID/code from orchestrate, OR no argument (batch mode — processes all pending finished plans)

## References

Reference specs are in `{{workspace_dir}}/.agents/references/`. Read them on-demand when the workflow requires them — do NOT read all upfront.

### Always needed
- **`Plan` (quick):** Read `plan-quick.md` — for Plan format, milestone fields, and status management
- **`Plans Index`:** Read `plans-index.md` — for index lookup and status updates

### Cross-references
For how references relate to each other, see `references-map.md`.

## Validation

- If a `Plan` ID/code is provided: verify it exists in `Plans Index` and has the `✅⏳` marker (done, docs pending). If the entry has `✅📝` (already documented) or `✅` (no docs needed), inform the user and exit
- If no `Plan` ID/code is provided (batch mode): scan `Plans Index` for all entries with the `✅⏳` marker. If none found, inform the user and exit

## Core Workflow

### Mode Selection

0. **Determine Mode:** Check if a `Plan` ID/code was provided
   - **Single mode:** Process one specific plan
   - **Batch mode:** No argument provided — process all pending finished plans sequentially

### Single Plan Mode

1. **Resolve Plan:** Read the `Plans Index` at `{{workspace_dir}}/plans/index.md` to find the full `Plan` filename for the given `Plan` ID/code
2. **Read Plan:** Construct the full `Plan` file path and read the `Plan` file to understand the implemented changes
3. **Analyze Changes:** Review the `Plan`'s development specifications, user flows, and any API changes to understand what documentation needs updating
4. **Update Documentation:** Update the relevant documentation files based on the implemented changes:
   - Technical manuals and guides in `{{workspace_dir}}/docs/`
   - API documentation if endpoints changed
   - `{{workspace_dir}}/README.md` if user-facing features changed
   - `{{workspace_dir}}/CHANGELOG.md` if significant changes occurred
5. **Handle Screenshots:** If the `Plan` includes visual changes, copy relevant screenshots from `{{workspace_dir}}/tests/screenshots/` to `{{workspace_dir}}/docs/screenshots/` and embed them in the documentation
6. **Mark Documentation Updated:** Update the `Plan` file's `Docs Updated` field to `true`, and replace `⏳` with `📝` in the `Plans Index` (e.g., `✅⏳` → `✅📝`)

### Batch Mode

1. **Scan Plans Index:** Read `{{workspace_dir}}/plans/index.md` and identify all plans with the `✅⏳` marker (done, docs pending)
2. **Process Each Plan:** For each pending plan, execute the Single Plan Mode workflow (steps 1-5 above)
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
