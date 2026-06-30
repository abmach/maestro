# Plan (Quick Spec)

> Compact format reference. See `{{workspace_dir}}/.agents/references/plan.md` for full spec with examples and elaboration format.

## File Location

- **Directory:** `{{workspace_dir}}/plans/`
- **Naming:** `{CODE}-{NNN}-{slug}.md` (e.g., `AUTH-001-user-authentication.md`)
- **Index:** `{{workspace_dir}}/plans/index.md`

## Required Metadata

- **Test Tier:** `e2e` | `smoke` | `none`
- **Docs Affected:** `true` | `false`
- **Docs Updated:** `true` | `false` (set to `true` after documentation is complete)
- **Status:** `✅ Done` | `🔄 In progress` | `⏳ Pending` | `⚠️ Blocked` | `❌ Failed`

## DAG Milestone Rules

- Each milestone has: unique numeric `ID`, `Dependencies` list (referencing preceding IDs), description
- Empty dependencies = can run in parallel
- **If `Test Tier` is `e2e`:** must include E2E Test Creation + E2E Test Execution milestones
- **If `Docs Affected` is `true`:** must include Documentation Update milestone

## Template

```markdown
# {Feature Title}

> Brief one-line summary.

## Test Tier: e2e/smoke/none

## Docs Affected: true/false

## Docs Updated: true/false

## Status: ⏳ Pending

## Steps

(✅ Done, 🔄 In progress, ⏳ Pending, ⚠️ Blocked, ❌ Failed)

- ⏳ **Milestone 1 (ID: 1, Dependencies: [])**: [Title] - Description.
- ⏳ **Milestone 2 (ID: 2, Dependencies: [])**: [Title] - Independent milestone.
- ⏳ **Milestone 3 (ID: 3, Dependencies: [1, 2])**: [Title] - Integration milestone.
- ⏳ **Milestone 4 (ID: 4, Dependencies: [3])**: [E2E Test Creation] - Write E2E tests.
- ⏳ **Milestone 5 (ID: 5, Dependencies: [4])**: [E2E Test Execution] - Run E2E tests.
- ⏳ **Milestone 6 (ID: 6, Dependencies: [5])**: [Documentation Update] - Update docs.

## Development Specifications

### Backend
- **Files to modify/create:** [paths]
- **API Routes:** [method, path, request/response JSON]
- **Data Models / Schema Changes:** [fields, types, constraints]
- **Business Logic:** [conditional boundaries, inputs, outputs]
- **Automated Unit Tests:** [test file paths and cases]

### Frontend
- **Files to modify/create:** [paths]
- **Components:** [hierarchy, props, state, events]
- **API Integration:** [endpoints → components, JSON field bindings]
- **Styling Notes:** [semantic HTML, breakpoints, accessibility]
- **Automated Component Tests:** [test files, mocked state, expected renders]

### Automated User Flows
1. **{Flow Name}:** Navigate → Fill `[data-testid="..."]` → Click `[data-testid="..."]` → Assert redirect or element

### Playwright Element Selectors
- `[data-testid="..."]` — description

### Visual Regression Viewports
- [dimensions, e.g., 1920x1080, 768x1024, 375x812]
```

## Numbering

1. Choose meaningful feature code (`AUTH`, `PAY`, `UI`)
2. Scan `{{workspace_dir}}/plans/` for highest existing number
3. Increment, zero-padded: `AUTH-001`, `PAY-002`
