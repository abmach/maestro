---
name: play
description: Implement plan milestones using test-driven development - apply red-green-refactor workflow to build features with comprehensive test coverage
argument-hint: "[plan ID/code] [milestone ID]"
allowed-tools:
  - read
  - find_file_by_name
  - grep
  - write
  - edit
  - skill
permissions:
  allow:
    - Read(./plans/**/*)
    - Read(./.agents/references/**/*)
    - Read(./issues/**/*)
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

# Play Milestone Implementation

Implement `Plan` milestones using test-driven development methodology with red-green-refactor cycles.

## Pre-flight

- Working folder: `{{workspace_dir}}` - the root of the project/workspace
- Target folders: `{{workspace_dir}}/plans/` (read-only) and code files in the project (read/write)
- Required input: `Plan` ID/code (e.g., "AUTH-001") and milestone ID to implement

## References

Reference specs are in `{{workspace_dir}}/.agents/references/`. Read them on-demand when the workflow requires them — do NOT read all upfront.

### Always needed
- **`Plan` (quick):** Read `plan-quick.md` — for Plan format, milestone fields, and status management
- **`Plans Index`:** Read `plans-index.md` — for index lookup and status updates
- **`Testing Principles`:** Read `testing-principles.md` — for TDD methodology (red-green-refactor)
- **`Design Principles`:** Read `design-principles.md` — for interface design and refactor guidance

### On-demand (read only when needed)
- **`Issue` (quick):** Read `issue-quick.md` — only on failure AND only in solo mode (not orchestrated)
- **`Issues Index`:** Read `issues-index.md` — only in solo mode when creating an Issue on failure
- **`Repo Fingerprint`:** Read `repo-fingerprint.md` — only if working file exists and tech stack is ambiguous

### Cross-references
For how references relate to each other, see `references-map.md`.

## Validation

- If required inputs are missing or invalid, abort with error
- If `Plan` file doesn't exist in `Plans Index`, abort with error
- If milestone ID doesn't exist in the `Plan`, abort with error

## Core Workflow

**Note:** This skill focuses on milestone implementation and verification. `Plan` milestone status updates are handled by the `orchestrate` skill.

### Phase 0: Setup

1. Read the `Plans Index` at `{{workspace_dir}}/plans/index.md` to find the full `Plan` filename for the given `Plan` ID/code
2. Construct `Plan` file path: `{{workspace_dir}}/plans/{full_filename}.md`
3. Read the `Plan` file to understand milestone requirements and test specifications

### Phase 1: Extract Milestone Requirements

- Read the `Plans Index` at `{{workspace_dir}}/plans/index.md` to find the full filename for the given `Plan` ID/code
- Read the `Plan` file at `{{workspace_dir}}/plans/{full_filename}.md`
- Extract the milestone with the specified ID
- Understand the specific requirements from the milestone's development specifications:
  - Files to modify/create
  - API routes or components to implement
  - Business logic requirements
  - Test specifications from the `Plan`
- **Check Execution Context:** Check if `MAESTRO_ORCHESTRATED` environment variable is set to "true"
  - If orchestrated: Skip `Plan` file updates (orchestrate will handle them)
  - If solo: Update `Plan` file with milestone status (In Progress) and `Plans Index`

### Phase 2: Apply TDD Methodology

Follow the TDD methodology from the `Testing Principles` specification to implement the milestone:

- Use the red-green-refactor workflow described in `Testing Principles`
- Apply the planning phase: review requirements, identify behaviors, design interfaces
- Execute tracer bullet approach: one test → one implementation → repeat
- Follow the incremental loop: RED → GREEN for each behavior
- Apply refactor phase after all tests pass, using `Design Principles` for guidance

### Phase 3: Milestone-Specific Verification

After completing the TDD cycles for the milestone:

- Run only the specific tests written for this milestone
- Run targeted linting on files modified/created by this milestone
- Ensure all milestone-specific tests pass
- Fix any failures before considering milestone complete

### Phase 4: Update Plan and Index

After milestone verification is complete:

- **Check Execution Context:** Check if `MAESTRO_ORCHESTRATED` environment variable is set to "true"
  - If orchestrated: Return structured status to orchestrate (milestone ID, status, notes, errors)
  - If solo:
    - **Update Plan Status:** Update milestone status to "Done" in the `Plan` file with completion timestamp and implementation notes
    - **Update Plans Index:** Update milestone status in `Plans Index` to reflect "Done" for this specific milestone
    - **Add Implementation Notes:** Document any important implementation details, deviations from `Plan`, or technical decisions in the `Plan` file

### Phase 5: Error Handling

If milestone implementation fails:

- **Check Execution Context:** Check if `MAESTRO_ORCHESTRATED` environment variable is set to "true"
  - If orchestrated: Return structured failure status to orchestrate (milestone ID, error details, failure type)
  - If solo:
    - **Update Plan Status:** Update milestone status to "Failed" in the `Plan` file with error details and failure timestamp
    - **Update Plans Index:** Update milestone status in `Plans Index` to reflect "Failed" for this specific milestone
    - **Document Failure:** Add error details, reproduction steps, and investigation notes to the `Plan` file
    - **Automatic Issue Creation:** Create a new `Issue` file in `{{workspace_dir}}/issues/` with appropriate type (BUG/BUILD/TEST/PERF) based on failure type
    - **Link to Plan:** Reference the `Plan` ID and milestone in the `Issue` for traceability
    - **Update Issues Index:** Add the new `Issue` to the `Issues Index` with status "Open"

## Quality Checklist

Before considering the milestone complete:

- [ ] All specified behaviors from the milestone are implemented
- [ ] All milestone-specific tests pass
- [ ] Tests follow `Testing Principles` specification (behavior, not implementation)
- [ ] Code follows `Design Principles` specification (deep modules, testable interfaces)
- [ ] No linting warnings on modified files
- [ ] Code is minimal and focused (no speculative features)
- [ ] Milestone status updated appropriately (based on execution context)
  - If solo: Updated in `Plan` file and `Plans Index`
  - If orchestrated: Returned structured status to orchestrate
- [ ] Implementation notes added (solo) or included in status return (orchestrated)
- [ ] If failed, `Issue` automatically created with appropriate type (solo) or error details returned (orchestrated)

## Error Handling

If tests fail during TDD implementation:
- Follow the debugging guidance in `Testing Principles` specification
- Check if test is coupled to implementation details
- Verify test describes actual behavior, not implementation
- Fix implementation or test as appropriate
- Never proceed to next behavior while current test fails

If milestone verification fails:
- Read error messages carefully
- Fix compilation errors first
- Fix test failures second
- Fix linting issues on modified files third
- Re-run milestone verification until all tests pass

## Definition of Done

The milestone is complete when:
- All specified behaviors from the milestone are implemented with tests
- All milestone-specific tests pass
- Code follows `Testing Principles` and `Design Principles` specifications
- No linting warnings on modified files
- No background processes remain running

## Execution

Use the `Plan` ID/code and milestone ID from the invocation, then proceed with Phase 0: Setup.
