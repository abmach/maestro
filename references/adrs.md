# Architecture Decision Records (ADRs)

> Captures significant architectural decisions, their context, and consequences for future maintainers.

## File Location and Naming

- **Directory:** `{{WORKSPACE}}/knowledge/adrs/`
- **Naming convention:** Sequential numbering with descriptive slug: `0001-slug.md`, `0002-slug.md`, etc.
- **Directory creation:** Create `{{WORKSPACE}}/knowledge/adrs/` lazily when the first ADR is needed

## Core Template

```markdown
---
status: accepted | proposed | deprecated | superseded by ADR-NNNN
---

# {Short, descriptive title of the decision}

{1-3 sentences summarizing: the context, what was decided, and the rationale.}
```

## Optional Sections

### Status (Frontmatter)

Use the `status` field to track the lifecycle of a decision:

- `proposed` — decision is under discussion
- `accepted` — decision is implemented and active
- `deprecated` — decision is no longer recommended but still in use
- `superseded by [ADR NNNN](./NNNN-slug.md)` — decision has been replaced by another ADR

### Considered Options

List alternatives that were evaluated and rejected. Include when:

- The rejected alternatives are worth remembering
- The rejection reason is non-obvious
- Future engineers might suggest the same alternative

### Consequences

Document downstream effects:

- Performance implications
- Operational constraints
- Maintenance burden
- Security considerations

## When to Write an ADR

Write an ADR only when **all three** of the following criteria are true:

1. **Hard to Reverse** — Changing the decision later would incur meaningful cost
2. **Surprising Without Context** — A future reader would look at the code and ask "why on earth did they do it this way?"
3. **Result of a Real Trade-off** — Genuine alternatives existed and one was chosen for specific reasons

## Examples of ADR-Worthy Decisions

- **Architectural shape:** monorepo structure, event-sourced write model with projected read model
- **Integration patterns:** cross-context communication via domain events instead of synchronous HTTP
- **Technology choices (high-lock-in):** database, message bus, auth provider, deployment target — only technologies that take a quarter+ to swap
- **Boundary and scope decisions:** data ownership by context, explicit "no" decisions
- **Deliberate deviations:** manual SQL instead of ORM, anything where a reasonable engineer would assume the opposite
- **Invisible constraints:** compliance restrictions, performance contracts not visible in code
- **Rejected alternatives (non-obvious):** considered GraphQL but chose REST for subtle reasons

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
