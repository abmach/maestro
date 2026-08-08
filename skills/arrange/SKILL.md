---
name: arrange
description: Arrange tests - design and create integration and E2E test specs from a Plan for features about to enter integration testing; invoked by orchestrate or via "/arrange PLAN-001"
argument-hint: "[plan ID/code]"
---

# Arrange Tests

Create and update clean, reliable, and maintainable integration and E2E test suites based on `Plan` specifications.

## Pre-flight

- `{{WORKSPACE}}` = the workspace root. At the start of a session, if not already resolved, run `git rev-parse --show-toplevel` (fall back to your cwd outside a repo) and reuse the result for the session.
- Working folder: `{{WORKSPACE}}` - the resolved workspace root
- Target folders: `{{WORKSPACE}}/tests/` (you should only modify files in this folder - focuses on integration and E2E tests)
- Required input: `Plan` ID/code from orchestrate

## References

Read reference specs on-demand when the workflow requires them — do NOT read all upfront.

### Always needed
- **`Plan`:** Read `{{WORKSPACE}}/{{MAESTRO_CONFIG}}/references/plan.md` — for Plan format and test tier requirements
- **`Testing Tech Preferences`:** Read `{{WORKSPACE}}/{{MAESTRO_CONFIG}}/references/testing-tech-preferences.md` — for framework selection and config

### On-demand (read only when needed)
- **`Repo Fingerprint`:** Read `{{WORKSPACE}}/knowledge/repo-fingerprint.md` (the working file, not the spec) — only if test framework isn't obvious from the fingerprint
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
   - **Visual Regression:** Include `expect(page).toHaveScreenshot('{name}.png')` calls in E2E tests for each user flow and viewport specified in the `Plan`. These capture baseline screenshots on first run and compare against them on subsequent runs
   - **Test Isolation:** Ensure tests are independent and can run in any order
   - **Mocking Strategy:** For integration and E2E tests, determine appropriate mocking strategies for external dependencies
   - **Data Management:** Set up test fixtures and data factories for consistent test data
   - **Framework-Specific Best Practices:** Apply framework-specific best practices (e.g., semantic selectors for UI tests, clean assertions for unit tests)
5. **Configuration:** Set up testing framework configuration as needed:
   - Configure test runners, reporters, and output directories
   - Set up code coverage collection if required
   - Configure test databases or test environments if needed
   - Ensure proper `.gitignore` entries for test artifacts
   - Apply the configuration settings from `Testing Tech Preferences`, if available
6. **Test Creation:** Create or update E2E test files flat in the `{{WORKSPACE}}/tests/` directory (e.g., `tests/auth.spec.ts`, `tests/login.spec.ts`) following the `Plan` specifications and test design principles. Do NOT create subdirectories inside `tests/`

## Input & Output Interface

- **Inputs (from orchestrate):**
  - Plan ID/code: e.g., "AUTH-001" or "AUTH-001-user-authentication"
- **Outputs (returned to orchestrate):**
  - Created or updated integration and E2E test files inside the `{{WORKSPACE}}/tests/` directory

## Quality Checklist

Before completing the test writing:

- [ ] `Plan` file successfully read and understood
- [ ] Integration and E2E test types determined correctly
- [ ] Appropriate testing frameworks selected per [Testing Tech Preferences]({{WORKSPACE}}/{{MAESTRO_CONFIG}}/references/testing-tech-preferences.md})
- [ ] Test files created/updated according to `Plan` specifications
- [ ] Tests are properly organized by type (integration, E2E) in appropriate directories
- [ ] Test isolation ensured (tests can run independently)
- [ ] Mocking strategies appropriately implemented for integration/E2E tests
- [ ] Test data management properly set up (fixtures, factories)
- [ ] Framework-specific best practices followed
- [ ] Test configuration properly set up (runners, reporters, coverage)
- [ ] All test files are syntactically valid for their respective frameworks
- [ ] All relative path references are correct

## Pre-Handoff Verification

Before completing the test writing task, execute and verify these steps:

1. **Syntax & Lint Verification:** Verify that all written test files are syntactically valid and free of compiler errors for their respective languages/frameworks
2. **Relative Reference Validation:** Ensure all relative path references, imports, and helper files inside `{{WORKSPACE}}/tests/` are correct
3. **Framework-Specific Validation:** Verify that framework-specific configurations and best practices are properly applied
4. **Common Checklist Compliance:** Run the common pre-handoff checks from your general instructions

## Execution

Use the `Plan` ID/code from the invocation, then proceed with Phase 0: Setup.
