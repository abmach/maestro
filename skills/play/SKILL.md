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
permissions:
  allow:
    - Read(./plans/**/*)
    - Read(./.devin/assets/**/*)
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

Read the following asset specification files from `{{workspace_dir}}/.devin/assets/` to understand TDD methodology and design patterns before implementing the milestone:

- **Testing Principles:** [testing-principles.md]({{workspace_dir}}/.devin/assets/testing-principles.md) - TDD methodology and test philosophy
- **Design Principles:** [design-principles.md]({{workspace_dir}}/.devin/assets/design-principles.md) - Interface design and dependency patterns
- **Repo Fingerprint:** [repo-fingerprint.md]({{workspace_dir}}/.devin/assets/repo-fingerprint.md) - Current technology stack and testing frameworks
- **Plan Structure:** [plan.md]({{workspace_dir}}/.devin/assets/plan.md) - Plan format and milestone specifications
- **Plans Index:** [plans-index.md]({{workspace_dir}}/.devin/assets/plans-index.md) - Plans index file format and management
- **Working Files:** Located in `{{workspace_dir}}/plans/` following specifications

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

## Quality Checklist

Before considering the milestone complete:

- [ ] All specified behaviors from the milestone are implemented
- [ ] All milestone-specific tests pass
- [ ] Tests follow `Testing Principles` specification (behavior, not implementation)
- [ ] Code follows `Design Principles` specification (deep modules, testable interfaces)
- [ ] No linting warnings on modified files
- [ ] Code is minimal and focused (no speculative features)

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
