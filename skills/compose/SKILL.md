---
name: compose
description: Compose technical solutions - map deep, precise code designs, test blueprints, and metadata parameters
argument-hint: "[feature description]"
subagent: true
permissions:
  allow:
    - read
    - find_file_by_name
    - grep
    - glob
    - web_search
    - Write(knowledge/**/*)
    - Edit(knowledge/**/*)
    - Write(plans/**/*)
    - Edit(plans/**/*)
  deny:
    - exec
---

# Compose Technical Solutions

Analyze requirements and create structured technical plans with precise specifications for development and testing.

## Pre-flight

- Working folder: `{{workspace_dir}}` - the root of the project/workspace (you should only modify files in this folder)

## Core Concepts

- **Repo Fingerprint:** [repo-fingerprint.md]({{workspace_dir}}/.devin/assets/repo-fingerprint.md) - workspace-specific technical stack
- **Tech Preferences:** [tech-preferences.md]({{workspace_dir}}/.devin/assets/tech-preferences.md) - preferred technologies and versions
- **Contexts:** [contexts.md]({{workspace_dir}}/.devin/assets/contexts.md) - domain language and terminology
- **ADRs:** [adrs.md]({{workspace_dir}}/.devin/assets/adrs.md) - architectural decision records
- **Plan:** [plan.md]({{workspace_dir}}/.devin/assets/plan.md) - complete plan structure and metadata
- **Plans Index:** [plans-index.md]({{workspace_dir}}/.devin/assets/plans-index.md) - plans index file format and management

### Execution Steps:

1. `read` the asset files directly using the paths specified above to extract your constraints before modifying code.

## Core Workflow

0. **Validate Input:** Ensure feature request is provided
1. **Get Request:** Extract the feature/change request from the user prompt
2. **Check Repo Fingerprint:** If `Repo Fingerprint` exists, review it to understand current technical stack
3. **Check Contexts:** Read `Contexts` to understand domain language and existing terminology
4. **Check ADRs:** Review `ADRs` for relevant architectural decisions
5. **Analyze Workspace:** Examine current codebase structure, existing patterns, and technical constraints
6. **Check Existing Plans:** Review `Plans Index` to avoid conflicts with ongoing work
7. **Create Plan:** Generate a new plan following the `Plan`
8. **Update Index:** Add the new plan to the `Plans Index` with status ⏳ Pending
9. **Update Repo Fingerprint:** If plan introduces new technologies, update `Repo Fingerprint`

## Input Sources

**Required:**

- User prompt with feature/change request
- Current workspace structure and patterns

**Optional but recommended:**

- `Repo Fingerprint` - current technical stack information (create if missing)
- `Contexts` - domain language and terminology
- `ADRs` - relevant architectural decisions
- `Plans Index` - existing work to avoid conflicts

## Quality Checklist

Before completing the plan:

0. **Input Validated:** Ensure feature request is provided and clear
1. **Context Alignment:** Use terminology from `Contexts`
2. **Technical Compatibility:** Match existing codebase patterns and frameworks
3. **No Ambiguity:** Define specific implementations, not placeholders
4. **Template Compliance:** Follow the exact structure from `Plan`
5. **Index Updated:** Ensure the `Plans Index` includes the new plan
6. **Fingerprint Updated:** If `Repo Fingerprint` exists, update it if plan introduces new technologies
