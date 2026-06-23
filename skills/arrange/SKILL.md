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

Create and update clean, reliable, and maintainable integration and E2E test suites based on plan specifications.

## Pre-flight

- Working folder: `{{workspace_dir}}` - the root of the project/workspace
- Target folders: `{{workspace_dir}}/tests/` (you should only modify files in this folder - focuses on integration and E2E tests)
- Required input: Plan ID/code from orchestrate

## Specifications & Methodologies

Read the following asset specification files from `{{workspace_dir}}/.devin/assets/` to understand formats, rules, and methodologies before creating tests:

- **Plan:** [plan.md]({{workspace_dir}}/.devin/assets/plan.md) - plan structure and metadata specification
- **Testing Tech Preferences:** [testing-tech-preferences.md]({{workspace_dir}}/.devin/assets/testing-tech-preferences.md) - preferred testing frameworks and tools for different test types
- **Testing Principles:** [testing-principles.md]({{workspace_dir}}/.devin/assets/testing-principles.md) - testing philosophy and TDD methodology
- **Working Files:** Located in `{{workspace_dir}}/plans/` following specifications

## Validation

- If required input is missing or plan ID doesn't exist in plans index, abort with error

## Core Workflow

### Phase 0: Setup

1. Read the Plans Index at `{{workspace_dir}}/plans/index.md` to find the full plan filename for the given plan ID/code
2. Construct the full plan file path: `{{workspace_dir}}/plans/{full_filename}.md`
3. Read the plan file to understand the testing requirements

### Phase 1: Test Design & Creation

1. **Test Type Determination:** Based on the plan specifications, determine the types of integration and E2E tests needed
2. **Framework Selection:** Consult [Testing Tech Preferences]({{workspace_dir}}/.devin/assets/testing-tech-preferences.md}) to select appropriate testing frameworks for integration and E2E testing
3. **Test Design:** Apply the test design cycle based on plan specifications and selected frameworks:
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
   - For Playwright specifically, apply the configuration settings from [Testing Tech Preferences]({{workspace_dir}}/.devin/assets/testing-tech-preferences.md})
5. **Test Creation:** Create or update test files inside the `{{workspace_dir}}/tests/` directory following the plan specifications and test design principles

## 🔌 Input & Output Interface

- **Inputs (from orchestrate):**
  - Plan ID/code: e.g., "AUTH-001" or "AUTH-001-user-authentication"
- **Outputs (returned to orchestrate):**
  - Created or updated integration and E2E test files inside the `{{workspace_dir}}/tests/` directory

## Quality Checklist

Before completing the test writing:

- [ ] Plan file successfully read and understood
- [ ] Integration and E2E test types determined correctly
- [ ] Appropriate testing frameworks selected per [Testing Tech Preferences]({{workspace_dir}}/.devin/assets/testing-tech-preferences.md})
- [ ] Test files created/updated according to plan specifications
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

Read the specified plan file to understand the testing requirements, then create or update test files following the specifications and best practices outlined above.
