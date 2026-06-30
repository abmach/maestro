---
name: tune
description: Resolve issues by investigating problems, implementing fixes, and documenting solutions - apply systematic debugging and TDD workflow
argument-hint: "[issue ID]"
allowed-tools:
  - read
  - find_file_by_name
  - grep
  - write
  - edit
  - ask_user_question
permissions:
  allow:
    - Read(./issues/**/*)
    - Read(./.agents/references/**/*)
    - Write(./**/*)
    - Edit(./**/*)
    - Exec(yarn add *)
    - Exec(yarn dev*)
    - Exec(yarn test*)
    - Exec(yarn lint*)
    - Exec(yarn build*)
    - Exec(npm install *)
    - Exec(npm run dev*)
    - Exec(npm run test*)
    - Exec(npm run lint*)
    - Exec(npm run build*)
    - Exec(dotnet *)
    - Exec(python -m pytest*)
  ask:
    - webfetch
---

# Tune Issue Resolution

Resolve `Issue`s by investigating problems, implementing fixes, and documenting solutions with systematic debugging, test-driven development, and verification.

## Pre-flight

- Working folder: `{{workspace_dir}}` - the root of the project/workspace
- Target folders: `{{workspace_dir}}/issues/` (read/write) and code files in the project (read/write)
- Required input: `Issue` ID (e.g., "BUG-001", "BUILD-002", "PERF-003")

## References

Reference specs are in `{{workspace_dir}}/.agents/references/`. Read them on-demand when the workflow requires them — do NOT read all upfront.

### Always needed
- **`Issue` (quick):** Read `issue-quick.md` — for Issue format, types, and status workflow
- **`Issues Index`:** Read `issues-index.md` — for index format and status updates

### On-demand (read only when needed)
- **`Testing Principles`:** Read `testing-principles.md` — when applying TDD to reproduce and fix the issue
- **`Design Principles`:** Read `design-principles.md` — during optional refactor phase
- **`Repo Fingerprint`:** Read `repo-fingerprint.md` — only if `{{workspace_dir}}/knowledge/repo-fingerprint.md` exists and tech stack is ambiguous
- **`Contexts`:** Read `contexts.md` — only if `{{workspace_dir}}/knowledge/contexts.md` exists and domain terminology matters

### Cross-references
For how references relate to each other, see `references-map.md`.

## Validation

- If required input is missing or `Issue` ID doesn't exist in `Issues Index`, abort with error
- If `Issue` is already resolved or marked as wontfix, abort with error

## Core Workflow

### Phase 0: Setup

1. Read the `Issues Index` at `{{workspace_dir}}/issues/index.md` to find the full `Issue` filename for the given `Issue` ID
2. Construct the full `Issue` file path: `{{workspace_dir}}/issues/{full_filename}.md`
3. Read the `Issue` file to understand the problem, error details, and context

### Phase 1: Investigation

1. **Analyze Problem:** Review error details, reproduction steps, and environment information
2. **Explore Codebase:** Use `read`, `find_file_by_name`, and `grep` to locate relevant code and understand the system
3. **Reproduce Issue:** If possible, attempt to reproduce the `Issue` using the provided steps
4. **Root Cause Analysis:** Investigate to identify the underlying cause of the problem
5. **Document Findings:** Add investigation notes to the `Issue` file with your analysis

### Phase 2: Solution Design

1. **Design Fix:** Propose a solution based on root cause analysis
2. **Consider Alternatives:** Evaluate multiple approaches if applicable
3. **Assess Impact:** Consider potential side effects and dependencies
4. **User Confirmation:** Use `ask_user_question` to present proposed solution and get user approval:
   - "Proposed fix: [brief description]. Approach: [approach details]. Should I proceed with this solution?"
   - Options: "Yes, proceed", "No, try different approach", "Cancel"

### Phase 3: Implementation

1. **Update Issue Status:** Change `Issue` status to "In Progress" in the `Issue` file
2. **Update Issues Index:** Move `Issue` to "In Progress" section in `Issues Index`
3. **Apply TDD Approach:** If applicable, write a test that reproduces the `Issue` before fixing:
   - Write a failing test that captures the `Issue` behavior (RED)
   - This ensures the fix addresses the actual problem
   - Provides regression protection for the future
4. **Implement Fix:** Apply the solution using appropriate tools (edit, write, exec)
5. **Test Fix:** Verify the fix resolves the `Issue`:
   - Run the reproduction test to confirm it now passes (GREEN)
   - Reproduce the `Issue` manually to confirm it's fixed
   - Run relevant tests to ensure no regressions
   - Check for side effects in related functionality
6. **Refactor if Needed:** If the code can be improved while keeping the test green, apply refactoring (REFACTOR)
7. **Document Resolution Attempt:** Add resolution attempt details to the `Issue` file

### Phase 4: Verification

1. **Comprehensive Testing:** Test the fix thoroughly in the affected environment
2. **Regression Testing:** Run broader test suite to ensure no new issues introduced
3. **Edge Case Testing:** Test related edge cases and boundary conditions
4. **Performance Verification:** If performance issue, verify improvement metrics

### Phase 5: Finalization

1. **Update Issue Status:** Change `Issue` status to "Resolved" in the `Issue` file
2. **Document Resolution:** Add final resolution details to the `Issue` file
3. **Add Prevention Measures:** Document steps to prevent similar `Issue`s in the future
4. **Update Issues Index:** Move `Issue` to "Resolved" section in `Issues Index`
5. **Related Work:** If fix requires broader changes, suggest creating a plan for systematic improvements

## 🚫 Critical Boundaries

- **No Direct Production Changes:** Do not make changes to production systems without explicit user confirmation
- **Security First:** For security `Issue`s (SEC-***), get explicit approval before any changes
- **Data Safety:** For `Issue`s involving data loss or corruption, ensure proper backups before changes
- **Test Verification:** Never mark an `Issue` as resolved without proper testing and verification

## 🔌 Input & Output Interface

- **Inputs (from user):**
  - `Issue` ID: e.g., "BUG-001", "BUILD-002", "PERF-003"
- **Outputs (returned to user):**
  - Updated `Issue` file with investigation notes, resolution attempts, and final resolution
  - Updated `Issues Index` with new status
  - Fixed code that resolves the `Issue`

## Quality Checklist

Before marking the `Issue` as resolved:

- [ ] `Issue` file successfully read and understood
- [ ] Root cause identified and documented
- [ ] Solution designed and approved by user
- [ ] TDD applied: Test written to reproduce `Issue` before fix (if applicable)
- [ ] Fix implemented correctly
- [ ] `Issue` verified as resolved through testing
- [ ] No regressions introduced
- [ ] Resolution documented in `Issue` file
- [ ] Prevention measures added to `Issue` file
- [ ] `Issue` status updated to "Resolved"
- [ ] `Issues Index` updated with new status
- [ ] Related work identified if needed

## 🛑 Mandatory Pre-Handoff Self-Correction Checklist

Before declaring the `Issue` resolved:

1. **Fix Verification:** Verify the fix actually resolves the reported `Issue` using the reproduction steps
2. **Regression Testing:** Ensure no existing functionality is broken by the changes
3. **Documentation Completeness:** Ensure all investigation notes, resolution attempts, and final resolution are documented
4. **Status Consistency:** Ensure `Issue` status and `Issues Index` are consistent
5. **User Communication:** If the fix has limitations or requires follow-up, document this clearly

## Error Handling

- If `Issue` cannot be reproduced, document this in investigation notes and ask user for additional details
- If multiple solution attempts fail, document each attempt and consider escalating or marking as blocked
- If fix introduces new `Issue`s, create new `Issue` entries for them and document the relationship
- If user cancels the resolution, revert `Issue` status to "Open" and document cancellation reason

## Integration with Other Skills

The tune skill may need to:
- **Invoke arrange** if fix requires new tests
- **Invoke audition** to run test suites for verification
- **Invoke compose** if fix requires broader architectural changes
- **Invoke rehearse** if `Issue` reveals domain language ambiguities

## Execution

Use the `Issue` ID from the invocation, then proceed with Phase 0: Setup.
