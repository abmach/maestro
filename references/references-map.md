# References Map

> How reference specifications relate to each other and to workspace content.

## Reference Files

All reference specs live in `{{WORKSPACE}}/{{MAESTRO_CONFIG}}/references/`:

| Reference | File | Defines |
| --------- | ---- | ------- |
| `Plan` | `plan.md` | Execution strategy: milestones as DAG, test tiers, dev specs |
| `Plans Index` | `plans-index.md` | Index file format for tracking all plans |
| `Issue` | `issue.md` | Problem tracking: types, severity, resolution workflow |
| `Issues Index` | `issues-index.md` | Index file format for tracking all issues |
| `Contexts` | `contexts.md` | Ubiquitous domain language glossary format |
| `ADRs` | `adrs.md` | Architectural decision record format and criteria |
| `Repo Fingerprint` | `repo-fingerprint.md` | Current technology stack snapshot format |
| `Tech Preferences` | `tech-preferences.md` | Preferred technologies for new projects |
| `Testing Principles` | `testing-principles.md` | TDD methodology and test design rules |
| `Testing Tech Preferences` | `testing-tech-preferences.md` | Preferred testing frameworks and tools |
| `Design Principles` | `design-principles.md` | Interface design and dependency patterns |
| `Conventions` | `conventions.md` | Shared contract: workspace rule, placeholders, status vocabularies, retry semantics, artifact paths, file ownership, index-write protocol |
| `References Map` | `references-map.md` | This file: how references relate to each other and to workspace content |

## Workspace Content

These are the actual working files created/maintained in the workspace, following the specs above:

| Content | Location | Spec |
| ------- | -------- | ---- |
| Plans | `{{WORKSPACE}}/plans/` | `Plan` |
| Plans Index | `{{WORKSPACE}}/plans/index.md` | `Plans Index` |
| Issues | `{{WORKSPACE}}/issues/` | `Issue` |
| Issues Index | `{{WORKSPACE}}/issues/index.md` | `Issues Index` |
| Contexts | `{{WORKSPACE}}/knowledge/contexts.md` | `Contexts` |
| ADRs | `{{WORKSPACE}}/knowledge/adrs/` | `ADRs` |
| Instruments | `{{WORKSPACE}}/knowledge/instruments.md` | format defined by the `instruments` skill |
| Repo Fingerprint | `{{WORKSPACE}}/knowledge/repo-fingerprint.md` | `Repo Fingerprint` |

## Relationship Map

How references relate to each other — consult these when working on a specific area:

- **Plan** references: `Contexts` (domain language), `ADRs` (architectural decisions), `Issue` (existing issues), `Repo Fingerprint` (current stack), `Tech Preferences` (new tech), `Design Principles` (patterns), `Testing Principles` (test tiers)
- **Issue** references: `Contexts` (domain language), `ADRs` (architectural decisions), `Repo Fingerprint` (current stack), `Tech Preferences` (solution tech), `Design Principles` (resolution patterns)
- **ADRs** references: `Contexts` (domain language), `Repo Fingerprint` (current stack), `Tech Preferences` (tech choices), `Design Principles` (design patterns)
- **Repo Fingerprint** references: `Testing Tech Preferences` (testing tools), `Tech Preferences` (general preferences)
- **Testing Principles** references: `Design Principles` (testable interfaces), `Repo Fingerprint` (current testing stack), `Tech Preferences` (testing tools), `Contexts` (domain language in tests)
- **Design Principles** references: `Repo Fingerprint` (current stack), `Tech Preferences` (new tech), `ADRs` (documented decisions), `Contexts` (domain language)
- **Testing Tech Preferences** references: `Testing Principles` (methodology), `Tech Preferences` (general tech), `Repo Fingerprint` (current testing stack)
- **Tech Preferences** references: `Testing Tech Preferences` (testing-specific), `Repo Fingerprint` (current stack)
- **Conventions** references: everything above — it binds their shared vocabulary, retry semantics, artifact paths, and ownership rules; every skill and agent reads it before its first write
