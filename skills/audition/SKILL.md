---
name: audition
description: Audition tests - execute test suites and capture pass/fail results, screenshots, and artifacts for visual regression routing; invoked by orchestrate after arrange or via "/audition <scope>"
argument-hint: "[test type and scope]"
---

# Audition Tests

Execute test suites to validate implementation, capture results, and generate artifacts for analysis. This skill runs tests created by the `arrange` skill and provides outputs for the `orchestrate` skill's visual regression routing.

## Pre-flight

- `{{WORKSPACE}}` = the workspace root. At the start of a session, if not already resolved, run `git rev-parse --show-toplevel` (fall back to your cwd outside a repo) and reuse the result for the session.
- Working folder: `{{WORKSPACE}}` - the resolved workspace root
- Target folders: `{{WORKSPACE}}/tests/` and `{{WORKSPACE}}/test-results/`
- Required input: Test type and scope from orchestrate

## References

Reference specs are in `{{WORKSPACE}}/{{MAESTRO_CONFIG}}/references/`. Read them on-demand when the workflow requires them — do NOT read all upfront.

### Always needed
- **`Repo Fingerprint`:** Read `{{WORKSPACE}}/knowledge/repo-fingerprint.md` (the working file, not the spec) — to identify the current testing stack and invocation command

### On-demand (read only when needed)
- **`Testing Tech Preferences`:** Read `testing-tech-preferences.md` — only if an unusual/non-standard test framework is in use
- **`Testing Principles`:** Read `testing-principles.md` — only if interpreting failures requires methodology context

### Cross-references
For how references relate to each other, see `references-map.md`.

## Validation

- If required input is missing, abort with error
- If test files don't exist for the specified scope, abort with error

## Core Workflow

### Phase 0: Test Discovery

1. **Read Asset Specifications:** Load `Testing Tech Preferences` and `Repo Fingerprint` to understand the testing stack
2. **Locate Test Files:** Find test files matching the specified scope
3. **Identify Test Framework:** Determine which testing framework is in use (Vitest, Jest, pytest, xUnit, etc.)

### Phase 1: Test Execution

1. **Select Execution Command:** Choose appropriate command based on testing framework:
   - **Vitest:** `yarn test` or `npm run test`
   - **Jest:** `yarn test` or `npm run test`
   - **pytest:** `python -m pytest`
   - **xUnit:** `dotnet test`
2. **Execute Tests:** Run the test suite using the appropriate command
3. **Capture Results:** Collect test output, exit codes, and any generated artifacts
4. **Generate Screenshots:** For E2E tests, ensure screenshots are captured to `test-results/` or framework-specific location

### Phase 2: Result Processing

1. **Analyze Test Output:** Parse test results to identify:
   - Pass/fail status
   - Failed test cases
   - Error messages and stack traces
   - Coverage information (if available)
2. **Generate Summary:** Create structured summary of test results
3. **Capture Artifacts:** Ensure screenshots, logs, and other artifacts are properly saved

## Output Format

### Success Case

- **Status:** All tests passed
- **Test Count:** Number of tests executed
- **Duration:** Test execution time
- **Coverage:** Code coverage percentage (if available)
- **Artifacts:** Paths to generated screenshots and logs

### Failure Case

- **Status:** Tests failed
- **Failed Tests:** List of failed test cases with error messages
- **Error Details:** Stack traces and specific error information
- **Artifacts:** Paths to failure screenshots, logs, and debug artifacts
- **Recommendations:** Suggested next steps for debugging

## Quality Checklist

Before completing the test execution:

- [ ] Correct test framework identified
- [ ] Appropriate execution command selected
- [ ] Tests executed successfully (or failures properly captured)
- [ ] Test results properly parsed and summarized
- [ ] Screenshots and artifacts captured for visual analysis
- [ ] Structured output generated for downstream skills
- [ ] No background test processes left running

## Error Handling

If test execution fails:
- Capture the error message and exit code
- Identify if it's a configuration issue, missing dependency, or test failure
- Provide clear error diagnosis and suggested fixes
- Ensure partial results are still captured for analysis

## Integration Points

- **Input from:** `orchestrate` skill (test scope and type)
- **Output to:** `orchestrate` skill (screenshots and test results for visual regression routing)
- **References:** Test files created by `arrange` skill
- **Context:** Implementation from `play` skill milestones

## Execution

Use the test scope from the invocation, then proceed with Phase 1: Test Discovery.
