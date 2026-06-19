# Architecture Decision Records (ADRs)

ADRs capture significant architectural decisions, their context, and their consequences. They serve as historical documentation for future maintainers to understand "why" the codebase is structured a certain way.

## File Location and Naming

- **Directory:** `{{workspace_dir}}/knowledge/adrs/`
- **Naming convention:** Sequential numbering with descriptive slug: `0001-slug.md`, `0002-slug.md`, etc.
- **Directory creation:** Create `{{workspace_dir}}/knowledge/adrs/` lazily when the first ADR is needed

## Core Template

An ADR can be as simple as a single paragraph. The value lies in recording that a decision was made and why—not in filling out bureaucratic sections.

```markdown
---
status: accepted | proposed | deprecated | superseded by ADR-NNNN
---

# {Short, descriptive title of the decision}

{1-3 sentences summarizing: the context, what was decided, and the rationale.}
```

## Optional Sections

Only include these sections when they add genuine value. Most ADRs will not need them.

### Status (Frontmatter)

Use the `status` field to track the lifecycle of a decision:

- `proposed` — decision is under discussion
- `accepted` — decision is implemented and active
- `deprecated` — decision is no longer recommended but still in use
- `superseded by [ADR NNNN](./NNNN-slug.md)` — decision has been replaced by another ADR

### Considered Options

List alternatives that were evaluated and rejected. Only include when:

- The rejected alternatives are worth remembering
- The rejection reason is non-obvious
- Future engineers might suggest the same alternative

### Consequences

Document downstream effects that are not immediately obvious:

- Performance implications
- Operational constraints
- Maintenance burden
- Security considerations

## When to Write an ADR

Write an ADR only when **all three** of the following criteria are true:

1. **Hard to Reverse** — Changing the decision later would incur meaningful cost
2. **Surprising Without Context** — A future reader would look at the code and ask "why on earth did they do it this way?"
3. **Result of a Real Trade-off** — Genuine alternatives existed and one was chosen for specific reasons

If a decision is easy to reverse, skip it—you'll just reverse it. If it's not surprising, nobody will wonder why. If there was no real alternative, there's nothing to record beyond "we did the obvious thing."

## Examples of ADR-Worthy Decisions

### Architectural Shape

- "We're using a monorepo structure."
- "The write model is event-sourced; the read model is projected into Postgres."

### Integration Patterns

- "Ordering and Billing contexts communicate via domain events, not synchronous HTTP."

### Technology Choices (High-Lock-In)

- Database, message bus, authentication provider, deployment target
- Only for technologies that would take a quarter or more to swap out
- Not for every library—only those with significant migration cost

### Boundary and Scope Decisions

- "Customer data is owned by the Customer context; other contexts reference it by ID only."
- Explicit "no" decisions are as valuable as "yes" decisions.

### Deliberate Deviations

- "We're using manual SQL instead of an ORM because X."
- Anything where a reasonable engineer would assume the opposite.
- These prevent future engineers from "fixing" something that was intentional.

### Invisible Constraints

- "We cannot use AWS due to compliance requirements."
- "Response times must be under 200ms due to partner API contract."
- Constraints that are not visible in the code but affect implementation.

### Rejected Alternatives (Non-Obvious)

- "We considered GraphQL but chose REST for subtle reasons."
- Record this to prevent the same suggestion from recurring in six months.

## Numbering Strategy

1. Scan `knowledge/adrs/` for the highest existing ADR number
2. Increment by one for the new ADR
3. Use zero-padded four-digit numbers (e.g., `0001`, `0002`) for consistent sorting

## Example ADR

```markdown
---
status: accepted
---

# Use Domain Events for Cross-Context Communication

To avoid tight coupling between bounded contexts, Ordering and Billing communicate via asynchronous domain events instead of synchronous HTTP calls. This allows each context to scale independently and evolve its internal schema without breaking others.
```
