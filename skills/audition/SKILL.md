---
name: audition
description: Audition tests - execute test suites to validate implementation and capture results for analysis
argument-hint: "[test type and scope]"
allowed-tools:
  - read
  - find_file_by_name
  - grep
  - write
  - edit
  - exec
permissions:
  allow:
    - Read(./tests/**/*)
    - Read(./plans/**/*)
    - Read(./src/**/*)
    - Write(./test-results/**/*)
    - Exec(yarn test*)
    - Exec(npm run test*)
    - Exec(python -m pytest*)
    - Exec(dotnet test*)
  deny:
    - web_search
---

# Audition Tests

Execute test suites to validate implementation, capture results, and generate artifacts for analysis. This skill runs tests created by the `arrange` skill and provides outputs for the `critique` skill to analyze.

## Pre-flight

- Working folder: `{{workspace_dir}}` - the root of the project/workspace
- Target folders: `{{workspace_dir}}/tests/` and `{{workspace_dir}}/test-results/`
- Required input: Test type and scope from orchestrate

## References

Reference specs are in `{{workspace_dir}}/.agents/references/`. Read them on-demand when the workflow requires them — do NOT read all upfront.

### On-demand (read only when needed)
- **`Testing Tech Preferences` (quick):** Read `testing-tech-preferences-quick.md` — only if an unusual/non-standard test framework is in use
- **`Repo Fingerprint`:** Read `{{workspace_dir}}/knowledge/repo-fingerprint.md` (the working file, not the spec) — to identify the current testing stack

### Cross-references
For how references relate to each other, see `references-map.md`.

## Validation

- If required input is missing, abort with error
- If test files don't exist for the specified scope, abort with error

## Core Workflow

### 1. Test Discovery

1. **Read Asset Specifications:** Load `Testing Tech Preferences` and `Repo Fingerprint` to understand the testing stack
2. **Locate Test Files:** Find test files matching the specified scope using `find_file_by_name` and `grep`
3. **Identify Test Framework:** Determine which testing framework is in use (Vitest, Jest, pytest, xUnit, etc.)

### 2. Test Execution

1. **Select Execution Command:** Choose appropriate command based on testing framework:
   - **Vitest:** `yarn test` or `npm run test`
   - **Jest:** `yarn test` or `npm run test`
   - **pytest:** `python -m pytest`
   - **xUnit:** `dotnet test`
2. **Execute Tests:** Run the test suite using the appropriate command
3. **Capture Results:** Collect test output, exit codes, and any generated artifacts
4. **Generate Screenshots:** For E2E tests, ensure screenshots are captured to `test-results/` or framework-specific location

### 3. Result Processing

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
- **Output to:** `critique` skill (screenshots and test results for visual analysis)
- **References:** Test files created by `arrange` skill
- **Context:** Implementation from `play` skill milestones

Execute the test suite, capture comprehensive results and artifacts, and provide structured output for visual analysis and debugging.
