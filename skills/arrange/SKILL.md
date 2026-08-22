---
name: arrange
description: Arrange tests - design and create integration and E2E test specs from a Plan for features about to enter integration testing; invoked by orchestrate or via "/arrange PLAN-001"
argument-hint: "[plan ID/code]"
---

# Arrange Tests

Create and update clean, reliable, and maintainable integration and E2E test suites based on `Plan` specifications.

## Pre-flight

- `{{WORKSPACE}}` = workspace root. Resolve once per session and reuse: `git rev-parse --show-toplevel`; fall back to cwd outside a git repo.
- Before your first write, read `{{WORKSPACE}}/{{MAESTRO_CONFIG}}/references/conventions.md` — statuses, retries, artifact paths, and file ownership are defined there and are binding.
- Working folder: `{{WORKSPACE}}`
- Target folders: `{{WORKSPACE}}/tests/` plus root-level framework configuration files when test setup requires them (e.g. `playwright.config.ts`, `vitest.config.*`, `.gitignore` entries for test artifacts). You do not touch application source code.
- Required input: `Plan` ID/code from orchestrate

## References

Read reference specs on-demand when the workflow requires them — do NOT read all upfront.

### Always needed
- **`Plan`:** Read `{{WORKSPACE}}/{{MAESTRO_CONFIG}}/references/plan.md` — for Plan format and test tier requirements
- **`Testing Tech Preferences`:** Read `{{WORKSPACE}}/{{MAESTRO_CONFIG}}/references/testing-tech-preferences.md` — for framework selection and the canonical framework configuration templates

### On-demand (read only when needed)
- **Repo Fingerprint (working file):** Read `{{WORKSPACE}}/knowledge/repo-fingerprint.md` — only if the test framework isn't obvious from the fingerprint
- **`Testing Principles`:** Read `{{WORKSPACE}}/{{MAESTRO_CONFIG}}/references/testing-principles.md` — only if test design questions arise that the Plan doesn't answer

### Cross-references
For how references relate to each other, see `{{WORKSPACE}}/{{MAESTRO_CONFIG}}/references/references-map.md`.

## Validation

- If required input is missing or `Plan` ID doesn't exist in `Plans Index`, abort with error

## Core Workflow

### Phase 0: Setup

1. Read the `Plans Index` at `{{WORKSPACE}}/plans/index.md` to find the full `Plan` filename for the given `Plan` ID/code
2. Construct the full `Plan` file path: `{{WORKSPACE}}/plans/{full_filename}.md`
3. Read the `Plan` file to understand the testing requirements

### Phase 1: Test Design & Creation

1. **Check Existing Tests:** Before creating new test files, check if test files already exist in `{{WORKSPACE}}/tests/` for this `Plan`. If they do, update them to match the current `Plan` specifications rather than creating new files
2. **Test Type Determination:** Based on the `Plan` specifications, determine the types of integration and E2E tests needed
3. **Framework Selection:** Consult `Testing Tech Preferences` to select appropriate testing frameworks for integration and E2E testing
4. **Test Design:** Apply the test design cycle based on `Plan` specifications and selected frameworks:
   - **Test Structure:** Create E2E test files flat in the root `tests/` directory (e.g., `tests/auth.spec.ts`) — do NOT nest in subdirectories. Unit tests are co-located with source code by the `play` skill
   - **Visual Regression:** Include `expect(page).toHaveScreenshot('{name}.png')` calls in E2E tests for each user flow and viewport specified in the `Plan`. Baselines capture to `tests/screenshots/baselines/` via the framework's snapshot-path configuration; runtime artifacts (actuals, diffs) go to `test-results/`
   - **Test Isolation:** Ensure tests are independent and can run in any order
   - **Mocking Strategy:** For integration and E2E tests, determine appropriate mocking strategies for external dependencies
   - **Data Management:** Set up test fixtures and data factories for consistent test data
   - **Framework-Specific Best Practices:** Apply framework-specific best practices (e.g., semantic selectors for UI tests)
5. **Configuration:** Set up testing framework configuration as needed, applying the canonical templates from `Testing Tech Preferences`:
   - Configure test runners, reporters, and output directories (`test-results/`)
   - Set the visual-regression baseline path (`snapshotPath` → `tests/screenshots/baselines/`)
   - Set up code coverage collection if required
   - Configure test databases or test environments if needed
   - Ensure `.gitignore` covers `test-results/` (baselines stay committed)
6. **Test Creation:** Create or update E2E test files flat in the `{{WORKSPACE}}/tests/` directory (e.g., `tests/auth.spec.ts`, `tests/login.spec.ts`) following the `Plan` specifications and test design principles. Do NOT create subdirectories inside `tests/`

## Input & Output Interface

- **Inputs (from orchestrate):**
  - Plan ID/code: e.g., "AUTH-001" or "AUTH-001-user-authentication"
- **Outputs (returned to orchestrate):**
  - Created or updated integration and E2E test files inside `{{WORKSPACE}}/tests/`
  - The framework configuration files written (so `audition` knows how tests will run)

## Quality Checklist

Before completing the test writing:

- [ ] `Plan` file successfully read and understood
- [ ] Integration and E2E test types determined correctly
- [ ] Appropriate testing frameworks selected per `Testing Tech Preferences`
- [ ] Framework configuration follows the canonical templates (runner options under `use:`, top-level `snapshotPath`)
- [ ] Baseline path configured to `tests/screenshots/baselines/`; runtime output to `test-results/`
- [ ] Test files created/updated according to `Plan` specifications, flat in `tests/`
- [ ] Test isolation ensured (tests can run independently)
- [ ] Mocking strategies appropriately implemented for integration/E2E tests
- [ ] Test data management properly set up (fixtures, factories)
- [ ] Framework-specific best practices followed
- [ ] All test files are syntactically valid for their respective frameworks
- [ ] `.gitignore` entries added for runtime test artifacts

## Pre-Handoff Verification

Before completing the test writing task, execute and verify these steps:

1. **Syntax & Lint Verification:** Verify that all written test files are syntactically valid and free of compiler errors for their respective languages/frameworks
2. **Relative Reference Validation:** Ensure all relative path references, imports, and helper files inside `{{WORKSPACE}}/tests/` are correct
3. **Framework-Specific Validation:** Verify that framework-specific configurations are applied and would take effect (option names exist in the framework version in use)
4. **Common Checklist Compliance:** Run the common pre-handoff checks from your general instructions

## Execution

Use the `Plan` ID/code from the invocation, then proceed with Phase 0: Setup.
