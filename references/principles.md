# Principles

> Defines the format of `{{WORKSPACE}}/knowledge/principles.md` — the workspace's standing invariants: load-bearing rules that apply to every change, stated once instead of being repeated in every Plan.

## File Location and Naming

- **File:** `{{WORKSPACE}}/knowledge/principles.md`
- **Creation:** created lazily — by `prelude` (bootstrap) or by the first writer that needs it (`rehearse`, `tune`)
- **Committed:** yes — it is project truth, shared via git

## Purpose and Scope

Principles are declarative, project-wide invariants whose violation produces the project's most expensive class of bug: "All money arithmetic uses integer cents, never float"; "Every resource query filters by owner, including joins and aggregations"; "No direct database access outside the repository layer."

They differ from their neighbors:

- **ADRs** record *decisions* with context, alternatives, and rationale. A principle may be extracted from an ADR, but strips the story down to the rule.
- **Contexts** define *domain language*. Principles constrain *construction*.
- **`Why & Limits`** blocks transmit constraints *between milestones of one Plan*. Principles apply to *every* Plan — composers read them so they don't restate them, and embed the relevant ones into milestone `Must not` lines where violation risk is visible.

## Format

```markdown
# Principles — {Project}

_Load-bearing rules that apply to every change. A rule nobody needed to write down does not belong here._

1. All money arithmetic uses integer cents — never float or double.
2. Every resource query filters by owner — no exceptions, including joins and aggregations.
3. Uniqueness rules live in the database (constraints), not only in application code. (ADR-0002)
```

Rules:

- One rule per line, numbered, declarative — subject, verb, object. No rationale, no history; if the rule points to one, reference the ADR parenthetically.
- Every line must be load-bearing: if a competent executor would follow it anyway, it does not belong here.
- Keep the file short. If it exceeds ~15 lines, merge or prune — a long principles file gets read the way long terms-of-service get read.

## Writers and Promotion Paths

| Writer | When |
| ------ | ---- |
| `prelude` | Bootstrap: distill invariants from confirmed ADRs and conventions visible in the codebase; confirm with the user line by line |
| `rehearse` | When an invariant crystallizes in dialogue — promote it immediately |
| `tune` | When an Issue's root cause is the *absence of a standing rule* — add the rule that would have prevented the class, not just the instance, and record the promotion in the Issue's Prevention section |

Append-only discipline: rules are added when discovered and deleted when revoked or provably redundant. Never reword silently — a reworded rule is a new rule: add the new one and remove the old one in the same edit.

## Readers

- **compose** — reads before shaping a Plan; embeds the relevant principles in milestone `Why & Limits` `Must not` lines instead of restating them everywhere
- **elaborate** — reads to check elaborations do not contradict the invariants
- **critique** — reads as review criteria
- `play` / `arrange` — not required to read; principles reach executors through the Plan itself
