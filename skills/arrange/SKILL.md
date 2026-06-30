---
name: arrange
description: Arrange tests - design, create, and maintain robust integration and E2E test suites
argument-hint: "[plan ID/code]"
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
  deny:
    - exec
---

# Arrange Tests

Create and update clean, reliable, and maintainable integration and E2E test suites based on `Plan` specifications.

## Pre-flight

- Working folder: `{{workspace_dir}}` - the root of the project/workspace
- Target folders: `{{workspace_dir}}/tests/` (you should only modify files in this folder - focuses on integration and E2E tests)
- Required input: `Plan` ID/code from orchestrate

## References

Reference specs are in `{{workspace_dir}}/.agents/references/`. Read them on-demand when the workflow requires them — do NOT read all upfront.

### Always needed
- **`Plan` (quick):** Read `plan-quick.md` — for Plan format and test tier requirements
- **`Testing Tech Preferences` (quick):** Read `testing-tech-preferences-quick.md` — for framework selection and config

### Cross-references
For how references relate to each other, see `references-map.md`.

## Validation

- If required input is missing or `Plan` ID doesn't exist in `Plans Index`, abort with error

## Core Workflow

### Phase 0: Setup

1. Read the `Plans Index` at `{{workspace_dir}}/plans/index.md` to find the full `Plan` filename for the given `Plan` ID/code
2. Construct the full `Plan` file path: `{{workspace_dir}}/plans/{full_filename}.md`
3. Read the `Plan` file to understand the testing requirements

### Phase 1: Test Design & Creation

1. **Test Type Determination:** Based on the `Plan` specifications, determine the types of integration and E2E tests needed
2. **Framework Selection:** Consult `Testing Tech Preferences` to select appropriate testing frameworks for integration and E2E testing
3. **Test Design:** Apply the test design cycle based on `Plan` specifications and selected frameworks:
   - **Test Structure:** Organize integration and E2E tests in appropriate directories
   - **Test Isolation:** Ensure tests are independent and can run in any order
   - **Mocking Strategy:** For integration and E2E tests, determine appropriate mocking strategies for external dependencies
   - **Data Management:** Set up test fixtures and data factories for consistent test data
   - **Framework-Specific Best Practices:** Apply framework-specific best practices (e.g., semantic selectors for UI tests, clean assertions for unit tests)
4. **Configuration:** Set up testing framework configuration as needed:
   - Configure test runners, reporters, and output directories
   - Set up code coverage collection if required
   - Configure test databases or test environments if needed
   - Ensure proper `.gitignore` entries for test artifacts
   - Apply the configuration settings from `Testing Tech Preferences`, if available
5. **Test Creation:** Create or update test files inside the `{{workspace_dir}}/tests/` directory following the `Plan` specifications and test design principles

## 🔌 Input & Output Interface

- **Inputs (from orchestrate):**
  - Plan ID/code: e.g., "AUTH-001" or "AUTH-001-user-authentication"
- **Outputs (returned to orchestrate):**
  - Created or updated integration and E2E test files inside the `{{workspace_dir}}/tests/` directory

## Quality Checklist

Before completing the test writing:

- [ ] `Plan` file successfully read and understood
- [ ] Integration and E2E test types determined correctly
- [ ] Appropriate testing frameworks selected per [Testing Tech Preferences]({{workspace_dir}}/.agents/references/testing-tech-preferences.md})
- [ ] Test files created/updated according to `Plan` specifications
- [ ] Tests are properly organized by type (integration, E2E) in appropriate directories
- [ ] Test isolation ensured (tests can run independently)
- [ ] Mocking strategies appropriately implemented for integration/E2E tests
- [ ] Test data management properly set up (fixtures, factories)
- [ ] Framework-specific best practices followed
- [ ] Test configuration properly set up (runners, reporters, coverage)
- [ ] All test files are syntactically valid for their respective frameworks
- [ ] All relative path references are correct

## 🛑 Mandatory Pre-Handoff Self-Correction Checklist

Before completing the test writing task, execute and verify these steps:

1. **Syntax & Lint Verification:** Verify that all written test files are syntactically valid and free of compiler errors for their respective languages/frameworks
2. **Relative Reference Validation:** Ensure all relative path references, imports, and helper files inside `{{workspace_dir}}/tests/` are correct
3. **Framework-Specific Validation:** Verify that framework-specific configurations and best practices are properly applied
4. **Common Checklist Compliance:** Run the common pre-handoff checks from your general instructions

## Execution

Use the `Plan` ID/code from the invocation, then proceed with Phase 0: Setup.
