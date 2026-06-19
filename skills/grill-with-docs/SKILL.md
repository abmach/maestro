---
name: grill-with-docs
description: Grilling session that challenges your plan against the existing domain model, sharpens terminology, and updates documentation (contexts, ADRs) inline as decisions crystallize. Use when user wants to stress-test a plan against their project's language and documented decisions
argument-hint: "[plan or feature description]"
subagent: true
permissions:
  allow:
    - read
    - find_file_by_name
    - grep
    - web_search
    - Write(knowledge/**/*)
    - Edit(knowledge/**/*)
  deny:
    - exec
---

# Grill With Docs

Interview relentlessly about every aspect of a plan to reach shared understanding, walk down each branch of the design tree, and resolve dependencies between decisions. Update domain documentation inline as terminology and architectural decisions crystallize.

## Pre-flight

- Working folder: `{{workspace_dir}}` - the root of the project/workspace (you should only modify files in this folder)

## Core Concepts

- **Contexts:** [contexts.md]({{workspace_dir}}/.devin/assets/contexts.md) - domain language and terminology format
- **ADRs:** [adrs.md]({{workspace_dir}}/.devin/assets/adrs.md) - architectural decision record format and when to write them

### Execution Steps

1. Read the asset files directly using the paths specified above to understand the documentation formats and guidelines
2. Explore the codebase to understand the current domain language and existing documentation

## Core Workflow

1. **Interview Process:** Ask questions one at a time, waiting for feedback on each question before continuing. Walk down each branch of the design tree, resolving dependencies between decisions one-by-one. For each question, provide your recommended answer
2. **Codebase Exploration:** If a question can be answered by exploring the codebase, explore the codebase instead of asking
3. **Terminology Challenge:** When the user uses a term that conflicts with the existing language in `Contexts`, call it out immediately. "Your glossary defines 'cancellation' as X, but you seem to mean Y — which is it?"
4. **Language Sharpening:** When the user uses vague or overloaded terms, propose a precise canonical term. "You're saying 'account' — do you mean the Customer or the User? Those are different things"
5. **Scenario Testing:** When domain relationships are being discussed, stress-test them with specific scenarios. Invent scenarios that probe edge cases and force the user to be precise about the boundaries between concepts
6. **Code Verification:** When the user states how something works, check whether the code agrees. If you find a contradiction, surface it: "Your code cancels entire Orders, but you just said partial cancellation is possible — which is right?"
7. **Inline Documentation Updates:** When a term is resolved, update `Contexts` right there. Don't batch these up — capture them as they happen. Follow the format specified in the `Contexts` asset
8. **ADR Creation:** Only offer to create an `ADR` when the criteria in the `ADRs` asset are met (hard to reverse, surprising without context, result of real trade-off). Follow the format specified in the `ADRs` asset

## Documentation Constraints

- **Contexts** should be totally devoid of implementation details. Do not treat it as a spec, a scratch pad, or a repository for implementation decisions. It is a glossary and nothing else
