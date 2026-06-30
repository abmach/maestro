---
name: elaborate
description: Elaborate plans with distilled information from higher-quality models to fill gaps and simplify execution for simpler models
argument-hint: "[plan ID or plan file path]"
allowed-tools:
  - read
  - write
  - edit
  - find_file_by_name
  - grep
  - web_search
  - webfetch
  - ask_user_question
permissions:
  allow:
    - Read(./plans/**/*)
    - Write(./plans/**/*)
    - Read(./.agents/references/**/*)
    - Read(./knowledge/**/*)
  deny:
    - exec
---

# Elaborate Plans

Elaborate existing `Plan`s with detailed, actionable guidance distilled from higher-quality models, filling gaps and making them easier for simpler models to execute during development.

## Pre-flight

- Working folder: `{{workspace_dir}}` - the root of the project/workspace
- Target folders: `{{workspace_dir}}/plans/` (you should only modify files in this folder)
- Required input: `Plan` ID (e.g., "AUTH-001") or `Plan` file path (e.g., "plans/AUTH-001-user-authentication.md")

## References

Reference specs are in `{{workspace_dir}}/.agents/references/`. Read them on-demand when the workflow requires them — do NOT read all upfront.

### Always needed
- **`Plan` (quick):** Read `plan-quick.md` — for Plan format, milestone fields, and status management
- **`Plans Index`:** Read `plans-index.md` — for index lookup and status updates

### On-demand (read only when needed)
- **`Contexts`:** Read `contexts.md` — when checking domain language for elaborations
- **`Repo Fingerprint`:** Read `repo-fingerprint.md` — when checking tech stack for elaborations
- **`Testing Principles`:** Read `testing-principles.md` — when elaborating test strategy
- **`Design Principles`:** Read `design-principles.md` — when elaborating code patterns
- **`Tech Preferences`:** Read `tech-preferences.md` — when elaborating tech choices

### Cross-references
For how references relate to each other, see `references-map.md`.

## Validation

- If required input is missing, abort with error
- If `Plan` file doesn't exist in plans directory, abort with error
- If `Plan` is already marked as Done or Failed, abort with error

## Core Workflow

### Phase 0: Setup

1. **Parse Input:** Determine if input is a `Plan` ID or file path
2. **Locate Plan:** If `Plan` ID provided, read `{{workspace_dir}}/plans/index.md` to find the full `Plan` filename
3. **Read Plan:** Read the full `Plan` file to understand its structure, milestones, and current detail level
4. **Read Context:** Read relevant knowledge files (`{{workspace_dir}}/knowledge/contexts.md`, `{{workspace_dir}}/knowledge/repo-fingerprint.md`) to understand domain language and technical stack

### Phase 1: Gap Analysis

1. **Identify Gaps:** Analyze each milestone for missing detail:
   - Vague or ambiguous implementation steps
   - Missing error handling guidance
   - Unclear testing strategies
   - Absence of code patterns or examples
   - Undefined edge cases
2. **Complexity Assessment:** Evaluate which milestones would benefit most from elaboration based on technical complexity and dependencies
3. **Knowledge Gaps:** Identify areas where external documentation or best practices would be helpful

### Phase 2: Knowledge Gathering

1. **Tech Stack Research:** Use `web_search` and `webfetch` to gather:
   - Latest documentation for referenced technologies and frameworks
   - Best practices for the specific implementation patterns
   - Common pitfalls and how to avoid them
2. **Codebase Patterns:** Use `grep` and `find_file_by_name` to find:
   - Existing similar implementations in the codebase
   - Established patterns for the technology stack
   - Relevant utility functions or helper classes
3. **Domain Alignment:** Ensure elaboration uses terminology from `{{workspace_dir}}/knowledge/contexts.md`

### Phase 3: Elaboration Generation

For each milestone identified as needing elaboration, add:

**Implementation Guidance:**
- Detailed step-by-step breakdown
- Specific file paths and directory structures
- Code patterns and examples following existing codebase conventions
- Prerequisite checks and setup steps
- Integration points with existing code

**Error Handling:**
- Common error scenarios and how to handle them
- Validation requirements
- Failure modes and recovery strategies
- Rollback procedures if needed

**Testing Strategy:**
- Specific test cases to implement
- Edge cases to cover
- Mock data requirements
- Test file locations and naming conventions

**Best Practices:**
- Performance considerations
- Security considerations
- Code organization patterns
- Documentation requirements

**Code Examples:**
- Relevant code snippets following project conventions
- Interface implementations
- Configuration examples
- Data structure definitions

**Common Pitfalls:**
- Mistakes to avoid
- Anti-patterns to watch for
- Debugging hints for common issues

### Phase 4: User Review

1. **Present Elaborations:** Use `ask_user_question` to present proposed elaborations:
   - "I've elaborated the `Plan` with detailed implementation guidance, code patterns, testing strategies, and best practices. Key additions include: [summary of major elaborations]. Should I apply these enhancements to the `Plan`?"
   - Options: "Yes, apply all", "Review specific sections", "No, cancel"
2. **Selective Review:** If user chooses "Review specific sections", present elaborations section by section for approval

### Phase 5: Plan Enhancement

1. **Apply Elaborations:** Update the `Plan` file with approved elaborations
2. **Maintain Structure:** Ensure elaborations are added without breaking the existing `Plan` structure and DAG dependencies
3. **Preserve Metadata:** Keep original `Plan` metadata (Test Tier, Docs Affected, Status) unchanged
4. **Update Index:** If elaborations significantly change the `Plan` scope, consider updating the description in `{{workspace_dir}}/plans/index.md`

## Elaboration Format

Add elaborations as nested bullet points under each milestone:

```markdown
- ⏳ **Milestone 1 (ID: 1, Dependencies: [])**: [Short Title] - Specific detailed task description.
  **Implementation Guidance:**
  - Step 1: [Detailed step with file paths]
  - Step 2: [Detailed step with specific actions]
  - Follow the pattern in [existing-file](path/to/existing-file)
  **Code Pattern:**
    ```typescript
    // Example following project conventions
    interface Example {
      // Specific implementation
    }
    ```
  **Testing Strategy:**
  - Create test file at `tests/path/to/test.spec.ts`
  - Test cases: [specific cases]
  - Mock data: [specific mock requirements]
  **Error Handling:**
  - Handle [specific error scenario]
  - Validate [specific conditions]
  - Fallback: [specific fallback strategy]
  **Common Pitfalls:**
  - Avoid [specific mistake]
  - Watch for [specific anti-pattern]
  **Best Practices:**
  - Use [specific pattern] for [specific purpose]
  - Consider [specific performance/security implication]
```

## Quality Checklist

Before completing the elaboration:

- [ ] `Plan` file successfully read and understood
- [ ] Gaps identified in existing milestones
- [ ] Knowledge gathered from documentation and codebase
- [ ] Elaborations follow project conventions and patterns
- [ ] Code examples match existing codebase style
- [ ] Domain language from contexts.md used correctly
- [ ] Testing strategies are specific and actionable
- [ ] Error handling covers common scenarios
- [ ] Best practices are relevant to the tech stack
- [ ] User approval obtained for elaborations
- [ ] `Plan` structure and DAG dependencies preserved
- [ ] Original `Plan` metadata maintained

## Error Handling

- If `Plan` file cannot be found, abort with error message suggesting user check the `Plans Index`
- If `Plan` is already Done or Failed, abort with error message suggesting the `Plan` may not need elaboration
- If web research fails for a specific technology, note this in elaborations and proceed with codebase patterns only
- If user rejects elaborations, do not modify the `Plan` file
- If elaborations would fundamentally change the `Plan` scope, suggest creating a new `Plan` instead

## Integration with Other Skills

The elaborate skill integrates with:

- **compose**: Can be invoked automatically after compose creates a new `Plan` to add detail before execution
- **orchestrate**: Elaborated `Plan`s provide better guidance for subagent execution
- **play**: Enhanced `Plan`s make execution more reliable and efficient
- **rehearse**: Can be called if rehearse identifies areas needing more technical detail
- **tune**: If tune identifies that a `Plan` needs more detail for successful implementation

## Usage Patterns

**Automatic Elaboration:**
- Invoke after `compose` creates a new `Plan`
- Run before `orchestrate` begins execution
- Ensures all `Plan`s have sufficient detail for reliable execution

**Manual Elaboration:**
- User invokes on existing `Plan`s that are proving difficult to execute
- Can target specific complex milestones that need more guidance
- Useful when onboarding new team members or technologies

**Selective Elaboration:**
- Elaborate only high-risk or complex milestones
- Focus on areas where the team has less experience
- Target milestones that have failed in previous execution attempts
