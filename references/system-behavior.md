# System Behavior

> Defines the format of `{{WORKSPACE}}/knowledge/system-behavior.md` — the living current-state view of what the shipped system does, distilled from completed Plans so the next Plan starts from intent instead of reverse-engineering code.

## File Location and Naming

- **File:** `{{WORKSPACE}}/knowledge/system-behavior.md`
- **Creation:** created lazily by `score` at the first completed-Plan harvest
- **Committed:** yes — it is project truth, shared via git

## Purpose

Executed Plans are audit records — frozen at completion. This file is what replaces them as living truth: the user-visible capabilities and contracts of the current system, maintained as features ship. A future `compose` reads it to know what already exists, so new Plans build on first-hand intent instead of archaeology, and future sessions stop paying the reconstruction tax on every change.

## Content Rules

- **Capabilities and contracts, not internals.** What the system does for users, what its endpoints guarantee, which invariants hold — never file structure, implementation detail, or design rationale (those live in Plans and ADRs).
- **Current state only.** Entries describe the system as it is now. Changed behavior is *rewritten in place*, not appended as history — the file is not a changelog.
- **One section per capability or domain.** Name sections after the feature scope (e.g., `## Authentication`), not after the Plan ID that shipped them.
- **Traceable.** Each section ends with a one-line provenance pointer to the Plan that last touched it (e.g., `_Last updated: AUTH-001_`).

## Format

```markdown
# System Behavior — {Project}

_What the shipped system does today. Capabilities and contracts only — read the Plans and ADRs for the why._

## Authentication

- Registration: email + password (bcrypt) → account created; duplicate email → 409 without disclosing account state
- Login: correct credentials → JWT valid 24h; wrong credentials → 401 with a generic message
- Logout: invalidates the session and clears the token client-side
- Protected routes: missing, malformed, or expired JWT → 401, no user attached

_Last updated: AUTH-001_
```

## Writers

| Writer | When |
| ------ | ---- |
| `score` | At every completed Plan — orchestrate Phase 3 offers the harvest regardless of `Docs Affected`, because behavior changes even when user docs don't. Distills the Plan's shipped Outcomes and contracts into the matching sections. |
| `tune` | On resolution, when the fix changed behavior — update the affected lines in place |

## Readers

- **compose** — reads (when the file exists) alongside contexts and ADRs to understand current behavior before designing; avoids re-implementing existing capabilities
- **rehearse** — reads when stress-testing whether a proposed feature conflicts with existing behavior
- **critique** — reads to spot contradictions between the Plan under review and current behavior

## Size Discipline

The file mirrors what a new contributor must know, not everything the system does. If a section exceeds ~10 lines, compress it: merge near-duplicate behaviors, drop anything an executor would infer from the endpoint list. A current-state file nobody reads because it is too long is worse than no file.
