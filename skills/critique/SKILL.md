---
name: critique
description: Critique visual issues - collaborate with user to identify screenshot regressions against expected styling and layout requirements
argument-hint: "[screenshot paths and plan reference]"
allowed-tools:
  - read
  - ask_user_question
permissions:
  allow:
    - Read(./tests/screenshots/**/*)
    - Read(./test-results/**/*)
    - Read(./tests/**/*)
    - Read(./plans/**/*)
    - Read(./src/**/*)
    - Read(./**/*.css)
    - Read(./**/*.scss)
    - Read(./**/*.less)
    - Read(./**/*.styl)
    - Read(./**/*.html)
    - Read(./**/*.jsx)
    - Read(./**/*.tsx)
    - Read(./**/*.vue)
    - Read(./**/*.svelte)
    - Read(./**/*.xml)
    - Read(./**/*.xaml)
    - Read(./**/*.json)
    - Read(./**/*.yaml)
    - Read(./**/*.yml)
  deny:
    - write
    - edit
    - exec
    - web_search
---

# Critique Visual Issues

Collaborate with user to identify and diagnose screenshot regressions against expected styling and layout requirements. This skill combines human visual inspection with AI code analysis to provide accurate defect diagnosis and remediation, regardless of the technology stack (testing framework, CSS system, or UI framework).

## Pre-flight

- Working folder: `{{workspace_dir}}` - the root of the project/workspace
- Target folders: Framework-specific screenshot directories (read-only access)
- Required input: Screenshot paths (provided by the testing framework) and `Plan` reference from orchestrate/audition
- **Framework Flexibility:** This skill works with any testing framework that provides screenshot comparison (Playwright, Cypress, Selenium, custom solutions, etc.) - screenshot paths are provided as input rather than assumed

## Validation

- If required inputs are missing or screenshot files don't exist, abort with error
- **Screenshot Pattern Flexibility:** While baseline/actual/diff is a common pattern across many frameworks, the skill accepts whatever screenshot paths the framework provides - it adapts to available comparison images

## Specifications & Methodologies

Read the following reference specification files from `{{workspace_dir}}/.agents/references/` to understand formats, rules, and methodologies before analyzing screenshots:

- **Testing Principles:** [testing-principles.md]({{workspace_dir}}/.agents/references/testing-principles.md) - testing philosophy and methodology
- **Design Principles:** [design-principles.md]({{workspace_dir}}/.agents/references/design-principles.md) - interface design and dependency patterns
- **Plan Structure:** [plan.md]({{workspace_dir}}/.agents/references/plan.md) - Plan format and milestone specifications

## 🔌 Input & Output Interface

- **Inputs (from orchestrate/audition):**
  - **Option A: Visual Regression Diff**
    - `Baseline Screenshot Path:` Path to the expected/baseline screenshot (framework-specific location)
    - `Actual Screenshot Path:` Path to the current/actual screenshot (framework-specific location)
    - `Diff Screenshot Path:` Path to the diff/comparison screenshot (optional, framework-specific)
    - `Plan Reference:` `{{workspace_dir}}/plans/{feature-slug}.md`
  - **Option B: Single-Screenshot Crash Diagnosis**
    - `Diagnostic Screenshot Path:` Path to a screenshot captured during test failure (framework-specific location)
    - `Failure Log / Error Message:` Exact string of the test error (e.g. element click intercepted, timeout, or assertion failure).
    - `Plan Reference:` `{{workspace_dir}}/plans/{feature-slug}.md`
- **Outputs / Execution Prompt Pattern (returned to orchestrate/audition):**
  When passed an evaluation payload, output the analysis in this exact format:
  - **Defect Diagnosis:** What is visually wrong, broken, or in a crash state (and where on the screen).
  - **Root Cause:** Why the styling, component overlay, or layout state caused the crash/failure.
  - **Verdict:** For Option A: `REJECT` or `APPROVE`. For Option B: `CRASH_DIAGNOSED`.
  - **Remediation Patch:** Specific styling rules, layout adjustments, or configuration changes to apply to resolve the glitch or click blockage.

## Strict File Routing Rules

1. **Image Isolation:** Read visual artifacts from the paths provided by the testing framework (framework-agnostic)
2. **Context Intake:** Read the active `Plan`s in `{{workspace_dir}}/plans/` to determine if a layout change is intended or an accidental regression
3. **Code Analysis:** Read relevant styling, layout, component, and configuration files to understand implementation and identify root causes

## Core Workflow

### Phase 1: User Visual Inspection

1. **Read Screenshots:** Load the provided screenshots using the paths supplied (baseline, actual, diff, or diagnostic - depending on what the testing framework provides)
2. **Display Context:** Present the screenshots to the user with relevant context:
   - For visual regression: Show available comparison images (if baseline/actual/diff are all provided, show them; otherwise work with what's available)
   - For crash diagnosis: Show the diagnostic screenshot with the error message
3. **User Inspection:** Use `ask_user_question` to prompt the user:
   - **Question:** "Please examine the screenshot(s). Do you see any visual issues, layout problems, or unexpected behavior?"
   - **Options:**
     - "Yes, I see issues" (with text input for description)
     - "No, looks correct to me"
     - "Skip - let AI analyze only"
4. **Capture User Input:** Record the user's visual observations and specific concerns

### Phase 2: Collaborative Analysis

#### If User Reports Issues:
1. **Analyze User Description:** Parse the user's visual observations
2. **Code Investigation:** Read relevant styling, layout, component, and configuration files to understand the implementation
3. **Cross-Reference Plan:** Check if the visual difference matches intended changes from the `Plan`
4. **Root Cause Analysis:** Correlate user's visual observations with code to identify:
   - Styling rules causing the issue
   - Layout properties that need adjustment
   - Component hierarchy problems
   - Responsive design breakpoints
   - Configuration issues
5. **Provide Remediation:** Generate specific styling fixes, layout adjustments, or configuration changes based on both user input and code analysis

#### If User Says It Looks Correct:
1. **Plan Verification:** Cross-reference with the `Plan`'s QA specifications
2. **Intended Change Check:** If the visual difference matches an intended change from the `Plan`, mark as `APPROVE`
3. **Baseline Update Recommendation:** If appropriate, recommend updating the baseline snapshot
4. **Final Verdict:** Provide `APPROVE` with explanation

#### If User Skips:
1. **AI-Only Analysis:** Proceed with the original automated analysis workflow
2. **Comprehensive Audit:** Conduct full spatial analysis following the audit guidelines
3. **Provide Diagnosis:** Output defect diagnosis, root cause, and remediation based on AI analysis alone

## Aesthetic & Spatial Audit Guidelines

When evaluating screenshots (either in AI-only mode or to supplement user input), conduct the analysis through these core dimensions:
1. **Blueprint Verification:** Read the active `Plan`'s QA Testing Specifications. If a visual difference matches an explicitly requested style, layout, or viewport modification, mark it as `APPROVE`
2. **Layout & Alignment Check:** Look for broken alignments, overlapping elements, unexpected word wraps, container height collapses, or grid gutter blowouts
3. **Responsive Breakpoint Auditing:** Verify visual consistency and correctness across different viewport dimensions (desktop, tablet, mobile). Look for layout shifts or hidden elements
4. **Code-Level Investigation:** Examine styling rules, component structure, and configuration files to identify the root cause of visual issues
5. **Actionable Remediation:** When issuing a `REJECT`, provide the exact styling properties, layout adjustments, or configuration changes that resolve the layout glitch, explaining the spatial logic behind the fix

## 🛑 Mandatory Pre-Handoff Self-Correction Checklist

1. **Cross-Reference Blueprint:** Verify whether the layout failure is actually an intended adjustment from `{{workspace_dir}}/plans/`. If it is, explicitly authorize the E2E agent to update the snapshot baseline instead of flagging it as a defect
2. **User Input Integration:** Ensure user's visual observations are correlated with code analysis for accurate diagnosis
3. **Code-Level Verification:** Always inspect the actual styling/layout code or configuration to confirm root cause analysis before providing remediation
4. **Technology Agnosticism:** Ensure all analysis and remediation works regardless of the testing framework, CSS system, or UI framework being used

Execute the collaborative workflow: present screenshots to the user, capture their visual observations, analyze the relevant code and configuration, and provide the verdict in the required output format with specific, code-backed remediation.
