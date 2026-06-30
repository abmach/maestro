# References Map

> How reference specifications relate to each other and to workspace content.

## Reference Files

All reference specs live in `{{workspace_dir}}/.agents/references/`:

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

## Workspace Content

These are the actual working files created/maintained in the workspace, following the specs above:

| Content | Location | Spec |
| ------- | -------- | ---- |
| Plans | `{{workspace_dir}}/plans/` | `Plan` |
| Plans Index | `{{workspace_dir}}/plans/index.md` | `Plans Index` |
| Issues | `{{workspace_dir}}/issues/` | `Issue` |
| Issues Index | `{{workspace_dir}}/issues/index.md` | `Issues Index` |
| Contexts | `{{workspace_dir}}/knowledge/contexts.md` | `Contexts` |
| ADRs | `{{workspace_dir}}/knowledge/adrs/` | `ADRs` |
| Repo Fingerprint | `{{workspace_dir}}/knowledge/repo-fingerprint.md` | `Repo Fingerprint` |

## Quick Specs

Compact versions of the largest reference files, containing only templates and required fields:

| Quick Spec | File | Full Spec |
| ---------- | ---- | --------- |
| `Plan` (quick) | `plan-quick.md` | `plan.md` |
| `Issue` (quick) | `issue-quick.md` | `issue.md` |
| `Testing Tech Preferences` (quick) | `testing-tech-preferences-quick.md` | `testing-tech-preferences.md` |

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
