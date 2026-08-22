---
name: audition
description: Audition tests - execute test suites and capture pass/fail results, screenshots, and artifacts for visual regression routing; invoked by orchestrate after arrange or via "/audition <scope>"
argument-hint: "[test type and scope]"
---

# Audition Tests

Execute test suites to validate implementation, capture results, and generate artifacts for analysis. This skill runs tests created by the `arrange` skill and provides outputs for the `orchestrate` skill's visual regression routing.

## Pre-flight

- `{{WORKSPACE}}` = workspace root. Resolve once per session and reuse: `git rev-parse --show-toplevel`; fall back to cwd outside a git repo.
- Before your first write, read `{{WORKSPACE}}/{{MAESTRO_CONFIG}}/references/conventions.md` — statuses, retries, artifact paths, and file ownership are defined there and are binding.
- Working folder: `{{WORKSPACE}}`
- Target folders: you only WRITE to `{{WORKSPACE}}/test-results/`. Tests under `tests/` are read-only for you — never modify test files or source code.
- Required input: Test type and scope from orchestrate

## References

Read reference specs on-demand when the workflow requires them — do NOT read all upfront.

### Always needed
- **Repo Fingerprint (working file):** Read `{{WORKSPACE}}/knowledge/repo-fingerprint.md` — to identify the current testing stack and invocation command

### On-demand (read only when needed)
- **`Testing Tech Preferences`:** Read `{{WORKSPACE}}/{{MAESTRO_CONFIG}}/references/testing-tech-preferences.md` — only if an unusual/non-standard test framework is in use
- **`Testing Principles`:** Read `{{WORKSPACE}}/{{MAESTRO_CONFIG}}/references/testing-principles.md` — only if interpreting failures requires methodology context

### Cross-references
For how references relate to each other, see `{{WORKSPACE}}/{{MAESTRO_CONFIG}}/references/references-map.md`.

## Validation

- If required input is missing, abort with error
- If test files don't exist for the specified scope, abort with error

## Core Workflow

### Phase 0: Test Discovery

1. **Read Asset Specifications:** Load the working Repo Fingerprint (and `Testing Tech Preferences` if the stack is unusual) to understand the testing stack
2. **Locate Test Files:** Find test files matching the specified scope
3. **Identify Test Framework AND Runner Command:** Determine which framework is in use and how it is actually invoked:
   - Inspect the project's test configuration and scripts (`package.json` scripts, `playwright.config.ts`, `pytest.ini`, etc.)
   - Verify which runner backs a script before trusting it — an npm `test` script may run Vitest, Jest, or Playwright
   - Typical invocations: `npx vitest run <scope>`, `npx jest <scope>`, `npx playwright test <scope>`, `python -m pytest <scope>`, `dotnet test`

### Phase 1: Test Execution

1. Execute the test suite with the verified command
2. Capture results: output, exit codes, and any generated artifacts
3. For E2E runs, confirm screenshot artifacts were produced where the framework config directs them (baselines → `tests/screenshots/baselines/`; runtime actuals/diffs → `test-results/`)

### Phase 2: Result Processing

1. **Analyze Test Output:** Parse test results to identify pass/fail status, failed cases, error messages, stack traces, and coverage information (if available)
2. **Resolve Artifact Paths:** Collect the concrete paths of every artifact downstream consumers may need — failure screenshots, baseline paths, diff images, logs, machine-readable summaries (e.g., `test-results/summary.json`). Never report a path you have not confirmed exists
3. **Generate Summary:** Create a structured summary of test results in the Output Format below

## Output Format

The result summary is the contract between audition and orchestrate's visual regression routing. Paths must be explicit and verified.

### Success Case

```
STATUS: All tests passed
Test Count: <number executed>
Duration: <execution time>
Coverage: <percentage, if available>
Artifacts:
  summary: <path to machine-readable result file, if any>
  logs: <path>
  screenshots: <paths, if captured>
```

### Failure Case

```
STATUS: Tests failed
Failed Tests: <list of failed test cases with one-line error messages>
Error Details: <stack traces and specific error information>
Visual Regressions:
  - test: <test name>
    baseline: <verified path under tests/screenshots/baselines/>
    actual: <verified path under test-results/>
    diff: <verified path under test-results/>
Artifacts:
  summary: <path>
  logs: <path>
Recommendations: <suggested next steps for debugging>
```

For non-visual failures, omit the `Visual Regressions` block. Every listed path must exist on disk at reporting time.

## Quality Checklist

Before completing the test execution:

- [ ] Correct test framework and runner command identified and verified
- [ ] Tests executed successfully (or failures properly captured)
- [ ] Test results parsed and summarized per the Output Format
- [ ] Screenshots and artifacts located and reported as verified paths
- [ ] Baseline vs runtime-artifact locations distinguished correctly
- [ ] No background test processes left running

## Error Handling

If test execution fails:
- Capture the error message and exit code
- Identify if it's a configuration issue, missing dependency, or test failure
- Provide clear error diagnosis and suggested fixes
- Ensure partial results are still captured for analysis

## Integration Points

- **Input from:** `orchestrate` skill (test scope and type)
- **Output to:** `orchestrate` skill (result summary with verified artifact paths for visual regression routing)
- **References:** Test files created by `arrange` skill
- **Context:** Implementation from `play` skill milestones

## Execution

Use the test scope from the invocation, then proceed with Phase 0: Test Discovery.
