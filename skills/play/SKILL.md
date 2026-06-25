---
name: play
description: Implement plan milestones using test-driven development - apply red-green-refactor workflow to build features with comprehensive test coverage
argument-hint: "[plan code+number] [milestone ID]"
subagent: true
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
    - Read(./.agents/assets/**/*)
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

Implement plan milestones using test-driven development methodology with red-green-refactor cycles.

## Pre-flight

- Working folder: `{{workspace_dir}}` - the root of the project/workspace
- Target folders: `{{workspace_dir}}/plans/` (read-only) and code files in the project (read/write)
- Required input: Plan code+number (e.g., "AUTH-001") and milestone ID to implement

## Specifications & Methodologies

Read the following asset specification files from `{{workspace_dir}}/.agents/assets/` to understand TDD methodology and design patterns before implementing the milestone:

- **Testing Principles:** [testing-principles.md]({{workspace_dir}}/.agents/assets/testing-principles.md) - TDD methodology and test philosophy
- **Design Principles:** [design-principles.md]({{workspace_dir}}/.agents/assets/design-principles.md) - Interface design and dependency patterns
- **Repo Fingerprint:** [repo-fingerprint.md]({{workspace_dir}}/.agents/assets/repo-fingerprint.md) - Current technology stack and testing frameworks
- **Plan Structure:** [plan.md]({{workspace_dir}}/.agents/assets/plan.md) - Plan format and milestone specifications
- **Plans Index:** [plans-index.md]({{workspace_dir}}/.agents/assets/plans-index.md) - Plans index file format and management
- **Issue:** [issue.md]({{workspace_dir}}/.agents/assets/issue.md) - Issue tracking and problem documentation specification
- **Issues Index:** [issues-index.md]({{workspace_dir}}/.agents/assets/issues-index.md) - Issues index specification
- **Working Files:** Located in `{{workspace_dir}}/plans/` and `{{workspace_dir}}/issues/` following specifications

## Validation

- If required inputs are missing or invalid, abort with error
- If plan file doesn't exist in plans index, abort with error
- If milestone ID doesn't exist in the plan, abort with error

## Core Workflow

**Note:** This skill focuses on milestone implementation and verification. Plan milestone status updates are handled by the `orchestrate` skill.

### Phase 0: Setup

1. Read the `Plans Index` at `{{workspace_dir}}/plans/index.md` to find the full plan filename for the given code+number
2. Construct plan file path: `{{workspace_dir}}/plans/{full_filename}.md`
3. Read the plan file to understand milestone requirements and test specifications

### 1. Extract Milestone Requirements

- Read the `Plans Index` at `{{workspace_dir}}/plans/index.md` to find the full filename for the given plan code+number
- Read the plan file at `{{workspace_dir}}/plans/{full_filename}.md`
- Extract the milestone with the specified ID
- Understand the specific requirements from the milestone's development specifications:
  - Files to modify/create
  - API routes or components to implement
  - Business logic requirements
  - Test specifications from the plan
- **Check Execution Context:** Check if `MAESTRO_ORCHESTRATED` environment variable is set to "true"
  - If orchestrated: Skip plan file updates (orchestrate will handle them)
  - If solo: Update plan file with milestone status (In Progress) and plans index

### 2. Apply TDD Methodology

Follow the TDD methodology from the `Testing Principles` specification to implement the milestone:

- Use the red-green-refactor workflow described in `Testing Principles`
- Apply the planning phase: review requirements, identify behaviors, design interfaces
- Execute tracer bullet approach: one test → one implementation → repeat
- Follow the incremental loop: RED → GREEN for each behavior
- Apply refactor phase after all tests pass, using `Design Principles` for guidance

### 3. Milestone-Specific Verification

After completing the TDD cycles for the milestone:

- Run only the specific tests written for this milestone
- Run targeted linting on files modified/created by this milestone
- Ensure all milestone-specific tests pass
- Fix any failures before considering milestone complete

### 4. Update Plan and Index

After milestone verification is complete:

- **Check Execution Context:** Check if `MAESTRO_ORCHESTRATED` environment variable is set to "true"
  - If orchestrated: Return structured status to orchestrate (milestone ID, status, notes, errors)
  - If solo:
    - **Update Plan Status:** Update milestone status to "Done" in the plan file with completion timestamp and implementation notes
    - **Update Plans Index:** Update milestone status in plans index to reflect "Done" for this specific milestone
    - **Add Implementation Notes:** Document any important implementation details, deviations from plan, or technical decisions in the plan file

### 5. Error Handling

If milestone implementation fails:

- **Check Execution Context:** Check if `MAESTRO_ORCHESTRATED` environment variable is set to "true"
  - If orchestrated: Return structured failure status to orchestrate (milestone ID, error details, failure type)
  - If solo:
    - **Update Plan Status:** Update milestone status to "Failed" in the plan file with error details and failure timestamp
    - **Update Plans Index:** Update milestone status in plans index to reflect "Failed" for this specific milestone
    - **Document Failure:** Add error details, reproduction steps, and investigation notes to the plan file
    - **Automatic Issue Creation:** Create a new issue file in `{{workspace_dir}}/issues/` with appropriate type (BUG/BUILD/TEST/PERF) based on failure type
    - **Link to Plan:** Reference the plan ID and milestone in the issue for traceability
    - **Update Issues Index:** Add the new issue to the issues index with status "Open"

## Quality Checklist

Before considering the milestone complete:

- [ ] All specified behaviors from the milestone are implemented
- [ ] All milestone-specific tests pass
- [ ] Tests follow `Testing Principles` specification (behavior, not implementation)
- [ ] Code follows `Design Principles` specification (deep modules, testable interfaces)
- [ ] No linting warnings on modified files
- [ ] Code is minimal and focused (no speculative features)
- [ ] Milestone status updated appropriately (based on execution context)
  - If solo: Updated in plan file and plans index
  - If orchestrated: Returned structured status to orchestrate
- [ ] Implementation notes added (solo) or included in status return (orchestrated)
- [ ] If failed, issue automatically created with appropriate type (solo) or error details returned (orchestrated)

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
