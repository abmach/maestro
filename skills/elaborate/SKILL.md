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
    - Read(./.agents/assets/**/*)
    - Read(./knowledge/**/*)
  deny:
    - exec
---

# Elaborate Plans

Elaborate existing plans with detailed, actionable guidance distilled from higher-quality models, filling gaps and making them easier for simpler models to execute during development.

## Pre-flight

- Working folder: `{{workspace_dir}}` - the root of the project/workspace
- Target folders: `{{workspace_dir}}/plans/` (you should only modify files in this folder)
- Required input: Plan ID (e.g., "AUTH-001") or plan file path (e.g., "plans/AUTH-001-user-authentication.md")

## Specifications & Methodologies

Read the following asset specification files from `{{workspace_dir}}/.agents/assets/` to understand plan structure and enhancement methodologies before elaborating:

- **Plan:** [plan.md]({{workspace_dir}}/.agents/assets/plan.md) - plan structure and metadata specification
- **Plans Index:** [plans-index.md]({{workspace_dir}}/.agents/assets/plans-index.md) - plans index specification
- **Repo Fingerprint:** [repo-fingerprint.md]({{workspace_dir}}/.agents/assets/repo-fingerprint.md) - technical stack documentation
- **Tech Preferences:** [tech-preferences.md]({{workspace_dir}}/.agents/assets/tech-preferences.md) - preferred technologies
- **Contexts:** [contexts.md]({{workspace_dir}}/.agents/assets/contexts.md) - domain language documentation
- **Design Principles:** [design-principles.md]({{workspace_dir}}/.agents/assets/design-principles.md) - interface design and dependency patterns
- **Testing Principles:** [testing-principles.md]({{workspace_dir}}/.agents/assets/testing-principles.md) - testing philosophy and TDD methodology
- **Working Files:** Located in `{{workspace_dir}}/plans/` following specifications

## Validation

- If required input is missing, abort with error
- If plan file doesn't exist in plans directory, abort with error
- If plan is already marked as Done or Failed, abort with error

## Core Workflow

### Phase 0: Setup

1. **Parse Input:** Determine if input is a plan ID or file path
2. **Locate Plan:** If plan ID provided, read `{{workspace_dir}}/plans/index.md` to find the full plan filename
3. **Read Plan:** Read the full plan file to understand its structure, milestones, and current detail level
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
   - "I've elaborated the plan with detailed implementation guidance, code patterns, testing strategies, and best practices. Key additions include: [summary of major elaborations]. Should I apply these enhancements to the plan?"
   - Options: "Yes, apply all", "Review specific sections", "No, cancel"
2. **Selective Review:** If user chooses "Review specific sections", present elaborations section by section for approval

### Phase 5: Plan Enhancement

1. **Apply Elaborations:** Update the plan file with approved elaborations
2. **Maintain Structure:** Ensure elaborations are added without breaking the existing plan structure and DAG dependencies
3. **Preserve Metadata:** Keep original plan metadata (Test Tier, Docs Affected, Status) unchanged
4. **Update Index:** If elaborations significantly change the plan scope, consider updating the description in `{{workspace_dir}}/plans/index.md`

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

- [ ] Plan file successfully read and understood
- [ ] Gaps identified in existing milestones
- [ ] Knowledge gathered from documentation and codebase
- [ ] Elaborations follow project conventions and patterns
- [ ] Code examples match existing codebase style
- [ ] Domain language from contexts.md used correctly
- [ ] Testing strategies are specific and actionable
- [ ] Error handling covers common scenarios
- [ ] Best practices are relevant to the tech stack
- [ ] User approval obtained for elaborations
- [ ] Plan structure and DAG dependencies preserved
- [ ] Original plan metadata maintained

## Error Handling

- If plan file cannot be found, abort with error message suggesting user check the plans index
- If plan is already Done or Failed, abort with error message suggesting the plan may not need elaboration
- If web research fails for a specific technology, note this in elaborations and proceed with codebase patterns only
- If user rejects elaborations, do not modify the plan file
- If elaborations would fundamentally change the plan scope, suggest creating a new plan instead

## Integration with Other Skills

The elaborate skill integrates with:

- **compose**: Can be invoked automatically after compose creates a new plan to add detail before execution
- **orchestrate**: Elaborated plans provide better guidance for subagent execution
- **play**: Enhanced plans make execution more reliable and efficient
- **rehearse**: Can be called if rehearse identifies areas needing more technical detail
- **tune**: If tune identifies that a plan needs more detail for successful implementation

## Usage Patterns

**Automatic Elaboration:**
- Invoke after `compose` creates a new plan
- Run before `orchestrate` begins execution
- Ensures all plans have sufficient detail for reliable execution

**Manual Elaboration:**
- User invokes on existing plans that are proving difficult to execute
- Can target specific complex milestones that need more guidance
- Useful when onboarding new team members or technologies

**Selective Elaboration:**
- Elaborate only high-risk or complex milestones
- Focus on areas where the team has less experience
- Target milestones that have failed in previous execution attempts