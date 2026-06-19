# Shared Implementation Agent Operational Rules & Target Paths

You must strictly adhere to these common host environment rules, standard directories, autonomous mindsets, and pre-handoff checklists. These rules apply to all implementation agents (backend_developer, frontend_developer, fullstack_developer, e2e_test_runner, and escalators) in addition to your specialized agent guidelines.

**Note:** Planning, documentation, test design, and visual analysis are now handled by skills rather than agents. This file only applies to implementation agents that write code and execute tests.

## 💻 Host Execution Environment (Critical)

- **Operating System:** Windows
- **Terminal Shell:** PowerShell 7 (`pwsh`)
- **Rule:** You must form all terminal commands utilizing valid PowerShell 7 syntax. Do not write bare Linux Bash utilities. Use native cross-platform PowerShell equivalents (e.g., `$env:VAR="value"`, `New-Item -ItemType Directory`, `Remove-Item -Recurse -Force`).

## 📁 Standard Project Directories & Target Paths

All subagents must strictly adhere to these common target paths. Never use absolute paths—always reference files relative to the workspace root:
- **Plan Reference & Specifications:** `{{workspace_dir}}/plans/{feature-slug}.md`
- **Plans Index:** `{{workspace_dir}}/plans/index.md`
- **Subagent Status Summaries:** `{{workspace_dir}}/plans/status/{timestamp}-{milestone_id}-{agent_name}-summary.md`
- **Playwright E2E Integration Tests:** `{{workspace_dir}}/tests/` (specifically for Playwright integration and E2E specs).
- **Test Visual Artifacts / Playwright Screenshots:** `{{workspace_dir}}/tests/screenshots/` (only for E2E runner snapshots and visual auditing).
- **Developer & Escalator Unit Tests:** Stored locally within the package, module, or component directory being developed (e.g., adjacent to source code or inside local `tests/` subdirectories) following local codebase conventions.
- **Technical Manuals, Guides & Public Documentation:** `{{workspace_dir}}/docs/`
- **Embedded Documentation Screenshots:** `{{workspace_dir}}/docs/screenshots/`

### ⏱️ Standard Filename Variables

- `{milestone_id}`: The unique numeric identifier of the active milestone from the feature plan (e.g., `1`, `4`).
- `{timestamp}`: The exact UTC execution timestamp formatted strictly as `YYYYMMDD-HHMMSS` (e.g., `20260616-105700`). This ensures chronological sorting of all execution summaries.

## 🧠 Core Operational Mindset: Total Autonomy

1. **Autonomous Decision Making:** You run in the background and cannot ask questions. When you encounter ambiguity or missing information in the plan or codebase, you MUST MAKE REASONABLE ASSUMPTIONS based on:
   - Existing codebase patterns, structure, and naming conventions.
   - Industry best practices for the current technology stack.
   - Context from similar implementations in the codebase.
   Document your assumptions in your status summary file, and proceed with the implementation. Only escalate if you genuinely cannot proceed.

## 🛑 Common Pre-Handoff Self-Correction Checklist

Before declaring your task completed and returning control, you must execute and verify these steps:

1. **Background Process Cleanup:** Terminate any background processes you started (e.g., dev servers). Use PowerShell `Get-Process` to identify them and `Stop-Process` to terminate them.

---

## 📄 Unified Subagent Status Schema

All subagents returning results to the Orchestrator must write their final summary file (`{{workspace_dir}}/plans/status/{timestamp}-{milestone_id}-{agent_name}-summary.md`) using this exact markdown structure (prefixed by a standardized UTC timestamp to log execution history):

```markdown
# {Agent Name} Execution Summary (Milestone {Milestone ID})

**Execution Timestamp:** YYYY-MM-DD HH:MM:SS UTC

## 📊 Status: (✅ Success / ❌ Failed / ⚠️ Escalated)

## 📁 Modified Files
- `path/to/file1.ext` (Briefly describe changes)
- `path/to/file2.ext`

## 🧪 Verification Results
- **Build/Compilation Command:** `verify_cmd` run and exit code (e.g., `0` or `1`)
- **Unit/Integration Tests:** Pass/Fail counts and outcomes

## 🧠 Assumptions Made
- Description of any reasonable assumptions made during implementation

## 🚨 Blockers & Errors (If Failed or Escalated)
- Direct compiler error messages, test exceptions, or infrastructure blockades
```
