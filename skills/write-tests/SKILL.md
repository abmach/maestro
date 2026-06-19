---
name: write-tests
description: Write E2E tests - design, create, and maintain robust Playwright integration tests
model: swe-1-6
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
    - Write(./tests/**/*)
    - Edit(./tests/**/*)
    - Write(./plans/status/**/*)
  deny:
    - exec
triggers:
  - user
  - model
---

# Write E2E Tests

Create and update clean, reliable, and maintainable Playwright integration test scripts based on plan specifications.

## 🔌 Input & Output Interface

- **Inputs (from orchestrate):**
  - Path to the plan file: `{{workspace_dir}}/plans/{feature-slug}.md`
- **Outputs (returned to orchestrate):**
  - Created or updated Playwright test files (.spec.ts) inside the `{{workspace_dir}}/tests/` directory.
  - Standardized status summary report at `{{workspace_dir}}/plans/status/{timestamp}-{milestone_id}-write-tests-summary.md` detailing files created/modified and any assumptions made.

## Core Operational Approach (Test Design Cycle)

1. **Semantic Selector Targeting:** Write tests that query components using robust, native accessibility roles, text elements, or data attributes (e.g., `page.getByRole('button', { name: 'Submit' })` or `page.locator('[data-testid="..."]')`). Avoid fragile, brittle CSS or XPath selectors
2. **Layout Snapshot Integration:** Every new end-to-end flow test must capture visual snapshots of key layouts using explicit, stable path-based `page.screenshot()` calls (e.g. `page.screenshot({ path: 'tests/screenshots/actuals/home-layout.png' })`), saving them to the persistent, version-controlled `{{workspace_dir}}/tests/screenshots/` directory. This is strictly required for stable visual regression diffing by the `see` skill, as opposed to temporary debug screenshots generated automatically by Playwright in the output directory
3. **Mocking External Services:** If tests require integration with external third-party APIs not available locally, write clean mock endpoints within the Playwright context
4. **Playwright Setup Rules:** When initializing or configuring the Playwright config (`playwright.config.ts`), apply these exact settings:
   - Set `outputDir` to `'./agent-test-artifacts'`
   - Set the `reporter` to `['json', { outputFile: './agent-test-artifacts/summary.json' }]`
   - Set `screenshot` to `'on'` (this config-level setting automatically captures temporary, git-ignored snapshots in the output directory for immediate runner/developer debugging on completion/failure)
   - Set `video` to `'off'`
   - Set `trace` to `'off'`
   - Ensure that the `{{workspace_dir}}/agent-test-artifacts/` directory is explicitly added to the workspace's `.gitignore` file to avoid committing runtime test outputs

## 🛑 Mandatory Pre-Handoff Self-Correction Checklist

Before completing the test writing task, execute and verify these steps:

1. **Syntax & Lint Verification:** Verify that all written TypeScript/JavaScript test files are syntactically valid and free of compiler errors
2. **Relative Reference Validation:** Ensure all relative path references, page objects, or helper imports inside `{{workspace_dir}}/tests/` are correct
3. **Common Checklist Compliance:** Run the common pre-handoff checks from your general instructions

## Status Resumption File

Upon completing work, write a brief status summary starting with an **Execution Timestamp** to `{{workspace_dir}}/plans/status/{timestamp}-{milestone_id}-write-tests-summary.md` containing:
- Test files created or modified
- Key selectors and snapshot paths mapped
- Any assumptions made

Read the specified plan file to understand the E2E testing requirements, then create or update Playwright test files following the specifications and best practices outlined above.
