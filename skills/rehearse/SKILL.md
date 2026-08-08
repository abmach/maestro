---
name: rehearse
description: Rehearse - stress-test a plan against the project's domain model by challenging assumptions, sharpening terminology, and updating contexts/ADRs inline; invoked via "/rehearse <plan or feature>" to refine language before orchestrate or after compose flags ambiguity
argument-hint: "[plan or feature description]"
---

# Rehearse

Interview relentlessly about every aspect of a plan to reach shared understanding, walk down each branch of the design tree, and resolve dependencies between decisions. Update domain documentation inline as terminology and architectural decisions crystallize.

## Pre-flight

- `{{WORKSPACE}}` = the workspace root. At the start of a session, if not already resolved, run `git rev-parse --show-toplevel` (fall back to your cwd outside a repo) and reuse the result for the session.
- Working folder: `{{WORKSPACE}}` - the resolved workspace root
- Target folders: `{{WORKSPACE}}/knowledge/` (you should only modify files in this folder)
- Required input: Plan or feature description to rehearse

## References

Read reference specs on-demand when the workflow requires them — do NOT read all upfront.

### Always needed
- **`Contexts`:** Read `{{WORKSPACE}}/{{MAESTRO_CONFIG}}/references/contexts.md` — for glossary format (rehearse reads and writes `{{WORKSPACE}}/knowledge/contexts.md`)

### On-demand (read only when needed)
- **`ADRs`:** Read `{{WORKSPACE}}/{{MAESTRO_CONFIG}}/references/adrs.md` — only when an architectural decision meets ADR criteria during the interview (3 criteria already inlined in workflow step 8). Read for the ADR format template at that moment.

### Cross-references
For how references relate to each other, see `{{WORKSPACE}}/{{MAESTRO_CONFIG}}/references/references-map.md`.

## Validation

- If required input is missing, abort with error

## Core Workflow

### Phase 0: Setup

1. Explore the codebase and `{{WORKSPACE}}/knowledge/` folder to understand the current domain language and existing documentation

### Phase 1: Interview Process

2. **Codebase Exploration:** If a question can be answered by exploring the codebase, explore the codebase instead of asking
3. **Terminology Challenge:** When the user uses a term that conflicts with the existing language in `{{WORKSPACE}}/knowledge/contexts.md` (if it exists), call it out immediately. "Your glossary defines 'cancellation' as X, but you seem to mean Y — which is it?"
4. **Language Sharpening:** When the user uses vague or overloaded terms, propose a precise canonical term. "You're saying 'account' — do you mean the Customer or the User? Those are different things"
5. **Scenario Testing:** When domain relationships are being discussed, stress-test them with specific scenarios. Invent scenarios that probe edge cases and force the user to be precise about the boundaries between concepts
6. **Code Verification:** When the user states how something works, check whether the code agrees. If you find a contradiction, surface it: "Your code cancels entire Orders, but you just said partial cancellation is possible — which is right?"
7. **Inline Documentation Updates:** When a term is resolved, update `{{WORKSPACE}}/knowledge/contexts.md` right there. Don't batch these up — capture them as they happen. Follow the format specified in the `Contexts` specification
8. **ADR Creation:** Only offer to create an `ADR` in `{{WORKSPACE}}/knowledge/adrs/` when the criteria in the `ADRs` specification are met (hard to reverse, surprising without context, result of real trade-off). Follow the format specified in the `ADRs` specification

## Documentation Constraints

- **Contexts** (`{{WORKSPACE}}/knowledge/contexts.md`) should be totally devoid of implementation details. Do not treat it as a spec, a scratch pad, or a repository for implementation decisions. It is a glossary and nothing else

## Execution

Use the plan or feature description from the invocation, then proceed with Phase 0: Setup.
