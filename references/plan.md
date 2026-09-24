# Plan

> Defines the execution strategy for a feature: the intent it serves, milestones as a DAG, test tiers, and development specifications.

## File Location and Naming

- **Directory:** `{{WORKSPACE}}/plans/`
- **Naming convention:** Meaningful feature code with sequential number: `AUTH-001-user-authentication.md`, `PAY-002-stripe-integration.md`, etc.
- **Index file:** `{{WORKSPACE}}/plans/index.md` tracks all plans and their status
- **Directory creation:** Create `{{WORKSPACE}}/plans/` lazily when the first plan is needed

## Plan Approval

Every Plan carries an `Approved` header field — the human gate between composition and execution. A Plan that satisfies every milestone can still miss the user's actual need; approval is where a human reads the Plan and signs off on the target, at the point where fixing it costs a comment instead of a rewrite.

- `## Approved: pending` — the value `compose` writes; every new Plan starts here. Draft is not approved, and file existence is not approval.
- `## Approved: approved` — set **only by the `cue` skill**, after its readiness audit and the user's explicit approval in that session. No other skill or agent may flip this field. The user editing the Plan file by hand is equally valid — the deliberate act is the point.
- `orchestrate` refuses to execute a Plan whose `Approved` field does not read `approved`. A **missing field counts as not approved** — Plans created before this field existed must pass through `/cue` once before orchestration will run them.
- `elaborate` runs pre-approval (it is part of authoring). If it modifies an already-approved Plan, it MUST reset `Approved` to `pending` — the spec changed, so re-approval is required.
- While unapproved, the Plans Index entry carries the `🔒` marker; `cue` removes it on approval.

## Intent

The requirements layer: what this change is *for*, stated before any technical decision. It is the part a reviewer checks against the user's actual need without reading code, the part `play` falls back on when a milestone is ambiguous, and the part future Plans read instead of reverse-engineering behavior from the codebase.

Structure:

```markdown
## Intent

{Purpose: one short paragraph — why this change exists, who it serves, and what breaks if the underlying why is missed. Not a feature list; the "so that".}

### Outcomes

- **FR-001**: {User-visible outcome, testable on its own. Use EARS for conditional, error, and validation behavior.}

### Non-Goals

- {Deliberately excluded capability} — {one-line rationale, especially where the exclusion looks like an oversight}
```

Rules:

- **FR IDs** are per-Plan, sequential, zero-padded (`FR-001`, `FR-002`). They are the traceability keys for milestone `Covers:` tags, the `critique` agent's coverage review, and test derivation in `arrange`.
- **Every FR MUST be covered** by at least one milestone's `Covers:` list. An uncovered FR is a plan defect; `cue`'s readiness audit rejects it.
- **Non-Goals are a defense, not documentation.** Each line stops an executor from "helpfully" building something adjacent. Prefer scoping by exclusion over restating scope by inclusion.
- Purpose is written for a reader with none of the author's context. If the executor would have to guess the why, the Purpose is not done.

### Intent Depth by Test Tier

| Test Tier | Purpose | Outcomes (FRs) | Non-Goals |
| --------- | ------- | -------------- | --------- |
| e2e / integration | required | required — every user-visible behavior; EARS for conditional, error, and validation rules | required — at least 3 entries, each with a rationale |
| smoke | required | optional — include FRs where business rules or error behavior exist | required — at least 3 entries |
| none | required (one line) | omitted | encouraged, not required |

## Test Tier Classification

Each plan must specify a `Test Tier` to indicate the level of automated testing required:

- **e2e** — Full end-to-end testing with comprehensive Playwright test coverage for major features and user flows
- **integration** — Integration testing via `arrange` + `audition` for multi-component behavior (API contracts, service interactions, data flow between modules) without browser/E2E flows or visual regression
- **smoke** — Basic smoke testing with minimal automated tests for smaller changes and bug fixes
- **none** — No automated testing required for trivial changes that don't affect user-facing behavior

## Documentation Impact

Each plan must specify `Docs Affected` to indicate whether the change requires documentation updates:

- **true** — The change affects user-facing behavior, API contracts, or requires manual updates
- **false** — The change is internal, refactoring, or doesn't impact user documentation

When `Docs Affected` is `true`, the plan must also track `Docs Updated` to indicate whether documentation has been completed:

- **true** — Documentation has been updated
- **false** — Documentation not yet updated, or not applicable (when `Docs Affected` is `false`)

## Verification Command

Each plan may specify a `Verify Cmd` — a single shell command that orchestrate runs to verify milestone-level and Phase-2 (smoke/none tier) work:

- **e.g.,** `yarn test`, `npm run lint`, `go test ./...`, `dotnet test`
- Run after each milestone passes (per-milestone verification)
- Run at Phase 2 when `Test Tier` is `smoke` or `none` (catch-all verification)
- Leave empty (or omit) when there's no meaningful verify command for the Plan
- The `orchestrate` skill reads this field; skills and agents do NOT read it directly

## Writing Rules

### Use Relative Paths

Always use relative paths (e.g., `src/`, `tests/`, `package.json`) instead of absolute repository paths.

### Define Milestones as a DAG

Structure the plan as a Directed Acyclic Graph where each milestone has:
- A unique numeric ID
- A list of dependencies (referencing preceding milestone IDs)
- A `retry_count` field (default `0`, written as `Retries: 0` in the milestone header) — counts spawns, not failures: orchestrate increments it immediately BEFORE each `play` spawn and refuses to spawn when `Retries >= 3`, marking the milestone `❌ Failed`. Persists across compaction. Canonical rule: `conventions.md`.
- A `Covers` list (FR IDs from `Intent` Outcomes that this milestone implements) — required in every milestone header whenever the Plan defines Outcomes; `Covers: []` marks an enabling or infrastructure milestone. Every FR must appear in at least one milestone's `Covers`.

Independent milestones (empty dependencies) can execute in parallel. Integration milestones depend on completion of their prerequisites.

### DAG Milestone Requirements

The DAG should only contain **development milestones** — things the `play` agent can implement (features, components, API endpoints, schema changes, etc.). Do not include testing or documentation as milestones.

**File-overlap rule:** milestones whose *Files to modify/create* lists overlap must either be merged into one milestone or ordered via an explicit dependency. Shared read-only references (imported types, consumed helpers) don't count — only files both milestones WRITE. orchestrate enforces this at spawn time; a well-formed Plan never triggers that warning.

### Be Specific and Unambiguous

- List exact file paths to modify or create
- Define explicit API routes with method, path, and JSON structures
- Specify exact unit test file paths and test cases
- Provide precise component hierarchies, props, and state definitions

The quality bar for everything below: a competent executor with full technical skill, full repo access, and none of the author's intent context must be able to build the right thing from this Plan alone. If they would have to guess — a rule, a failure path, a boundary — the spec, not the executor, is what needs work. (Smart Kid test: the point is not to simplify; it is to drag tacit knowledge into the open.)

### State Rules in EARS

Conditional, error, and validation rules — in `Intent` Outcomes and in `Business Logic` — use EARS (Easy Approach to Requirements Syntax) sentence patterns. The grammar closes the interpretation space an executor would otherwise fill with its most common training pattern:

| Pattern | Template | Use for |
| ------- | -------- | ------- |
| Ubiquitous | `THE SYSTEM SHALL [action].` | always-true behavior |
| Event-driven | `WHEN [trigger], THE SYSTEM SHALL [response].` | user and system actions |
| State-driven | `WHILE [state], THE SYSTEM SHALL NOT [prohibited action].` | invariants that hold while a state holds |
| Unwanted behavior | `IF [condition], THE SYSTEM SHALL [mitigation].` | failure paths, edge cases, limit enforcement |

Adjectives are not requirements. "Handle errors gracefully" leaves the error codes to the executor; `IF the amount is <= 0, THE SYSTEM SHALL reject with 422 "amount must be positive"` does not. Numbers over adjectives everywhere: not "the API should be fast" but "GET /api/v1/tasks responds under 500ms at p95 for lists up to 1,000 tasks".

### Validation Rules Get Input/Output Tables

Any validation, state, or conditional boundary gets concrete input/output pairs — one row per boundary: empty or whitespace, minimum, maximum, invalid format. The row set is the requirement; prose around it is orientation. The whitespace row is the one executors skip unless it is written down.

| Input | Expected result |
| ----- | --------------- |
| `""` (empty) | Error: "Title is required" (trim before validating) |
| `"A"` (1 char) | Error: "Title must be at least 2 characters" |
| `"A"` × 501 | Error: "Title must be 500 characters or fewer" |
| `"Ship it"` | Success: saved |

### Optional Milestone Elaboration

- **Implementation Guidance:** Detailed step-by-step breakdowns, specific file paths, prerequisite checks, integration points
- **Code Patterns:** Relevant code snippets following project conventions, interface implementations, configuration examples
- **Testing Strategy:** Specific test cases, edge cases to cover, mock data requirements, test file locations
- **Error Handling:** Common error scenarios, validation requirements, failure modes, recovery strategies
- **Best Practices:** Performance considerations, security considerations, code organization patterns
- **Common Pitfalls:** Mistakes to avoid, anti-patterns to watch for, debugging hints

Elaboration format example:

```markdown
- ⏳ **Milestone 1 (ID: 1, Dependencies: [], Retries: 0, Covers: [FR-001])**: [Short Title] - Specific detailed task description.
  **Implementation Guidance:**
  - Step 1: [Detailed step with file paths]
  - Step 2: [Detailed step with specific actions]
  - Follow the pattern in [existing-file](path/to/existing-file)
  **Code Pattern:**
    ```typescript
    // Example following project conventions
    interface Example {
      // Specific implementation
    }
    ```
  **Testing Strategy:**
  - Create test file at `tests/auth.spec.ts`
  - Test cases: [specific cases]
  - Mock data: [specific mock requirements]
```

### Why & Limits (per milestone)

Each milestone MAY carry a **`Why & Limits:`** sub-block, nested under the milestone bullet at the same indent as elaboration blocks:

- **Why:** one line — the design rationale the executing agent cannot infer from the task text alone (what breaks elsewhere if done differently; which other milestones consume this milestone's shape)
- **Must not:** explicit negative scope — files/areas owned by other milestones or read-only zones (e.g. `knowledge/`), forbidden actions (committing, adding dependencies), each with a one-clause reason
- **If blocked:** typically `return Failed with the blocker named — do not improvise outside scope`

Hard limit: 3 bullets, one line each. Composers MAY add it where violation risk or rationale is non-obvious; `elaborate` MUST fill it in for every milestone. It is the premium model's constraint-transmission channel to cheaper executors: constraints embedded in the milestone outperform rules living only in reference docs the executor may not read. The block is orientation, not the execution authority (that stays `Development Specifications`); orchestrate and `play` read it but never edit it, and it survives status transitions unchanged.

### Status Management

Use the standard status legend for both the overall plan and individual milestones:
- ✅ Done
- 🔄 In progress
- ⏳ Pending
- ⚠️ Blocked
- ❌ Failed

### Numbering Strategy

1. Choose a meaningful feature code (e.g., `AUTH` for authentication, `PAY` for payments, `UI` for user interface)
2. Scan `{{WORKSPACE}}/plans/` for the highest existing number for that feature code
3. Increment by one for the new plan
4. Use hyphen-separated format: `{CODE}-{number}-{descriptive-slug}.md`
5. Use zero-padded three-digit numbers (e.g., `AUTH-001`, `PAY-002`) for consistent sorting
6. Number `Intent` Outcomes per-Plan: sequential, zero-padded (`FR-001`, `FR-002`). FR IDs are scoped to their Plan file and never collide with Plan codes — they are the traceability keys for `Covers:`, coverage review, and test derivation.

## Template

````markdown
# {Feature Title}

> Brief one-line summary of the feature or change.

## Approved: pending/approved

## Test Tier: e2e/integration/smoke/none

## Docs Affected: true/false

## Docs Updated: true/false

## Verify Cmd: <optional verification command, or empty — e.g., "yarn test", "npm run lint", "go test ./...", "dotnet test">. Run by orchestrate after each milestone passes and at Phase 2 for smoke/none tiers.

## Intent

{Purpose: one short paragraph — why this change exists, who it serves, and what breaks if the underlying why is missed. Not a feature list; the "so that".}

### Outcomes

- **FR-001**: {User-visible outcome, testable on its own. Use EARS for conditional, error, and validation behavior.}

### Non-Goals

- {Deliberately excluded capability} — {one-line rationale, especially where the exclusion looks like an oversight}

{Depth per Test Tier: e2e/integration full; smoke Purpose + Non-Goals with FRs optional; none Purpose only. See Intent.}

## Status: ✅ Done/🔄 In progress/⏳ Pending/⚠️ Blocked/❌ Failed

## Assumptions & Open Questions (optional)

{Ambiguities resolved during planning and questions deferred to implementation. Mark each open question `[blocking]` or `[deferred]` — cue refuses approval while a `[blocking]` question is unresolved; an open question in an approved spec is a delayed bug. `play` resolves residual ambiguity autonomously and reports deviations in its status Notes — anything load-bearing belongs here explicitly, so review happens before code exists.}

## Milestones


(✅ Done, 🔄 In progress, ⏳ Pending, ⚠️ Blocked, ❌ Failed)

- ⏳ **Milestone 1 (ID: 1, Dependencies: [], Retries: 0, Covers: [FR-001])**: [Short Title] - Specific detailed task description.
  **Why & Limits:** (optional at compose; mandatory after elaboration — see Writing Rules)
  - Why: [Rationale the executor cannot infer — what breaks if done differently]
  - Must not: [Files owned by other milestones, forbidden actions — each with a one-clause reason]
  - If blocked: Return Failed with the blocker named — do not improvise outside scope.
- ⏳ **Milestone 2 (ID: 2, Dependencies: [], Retries: 0, Covers: [FR-002])**: [Short Title] - Independent milestone (can run in parallel with Milestone 1).
- ⏳ **Milestone 3 (ID: 3, Dependencies: [1, 2], Retries: 0, Covers: [])**: [Short Title] - Integration milestone (requires both Milestone 1 and 2 to be completed first).
- ...

**Optional Elaboration Example:**

```markdown
- ⏳ **Milestone 1 (ID: 1, Dependencies: [], Retries: 0, Covers: [FR-001])**: Implement JWT authentication service
  **Implementation Guidance:**
  - Create `src/auth/jwt-authenticator.ts` following the pattern in `src/auth/base-authenticator.ts`
  - Implement `generateToken()` and `validateToken()` methods
  - Use RS256 algorithm with keys from `config/auth.keys.json`
  - Add error handling for expired tokens and invalid signatures
  **Code Pattern:**

    ```typescript
    class JWTAuthenticator implements Authenticator {
      async generateToken(user: User): Promise<string> {
        // Implementation following existing pattern
      }
      async validateToken(token: string): Promise<User | null> {
        // Implementation following existing pattern
      }
    }
    ```
  **Testing Strategy:**
  - Create `tests/auth.spec.ts`
  - Test token generation with valid user data
  - Test token validation with valid and expired tokens
  - Test error handling for malformed tokens
  **Common Pitfalls:**
  - Don't store secrets in frontend code
  - Ensure token expiration is properly validated
  - Handle clock skew in token validation
```

## Development Specifications

### Test File Locations

- **Unit tests:** Co-locate with source code following the project's existing convention (e.g., `src/auth/jwt.test.ts`, `src/components/auth/LoginForm.test.tsx`, `test_auth.py`)
- **E2E tests:** Flat in the root `tests/` directory (e.g., `tests/auth.spec.ts`, `tests/login.spec.ts`) — do NOT nest in subdirectories

### Backend

- **Files to modify/create:** List exact file paths.
- **API Routes:** Define method, path, request/response JSON structures.
- **Data Models / Schema Changes:** Define fields, types, constraints, migration details.
- **Business Logic:** State rules in EARS form; give validation rules as input/output tables (see Writing Rules). No ambiguity.
- **Automated Unit Tests:** Define the exact unit/integration test suites, file paths, and test cases to create or extend locally (specifying positive flows, edge cases, error codes, and validation failures — derive the error and validation cases from the Intent FR list).

### Frontend

- **Files to modify/create:** List exact file paths.
- **Components:** Define component hierarchy, props, state, and events.
- **API Integration:** Map which endpoints each component consumes, with exact JSON field bindings.
- **Styling Notes:** Semantic HTML tags to use, viewport breakpoints, accessibility requirements.
- **Automated Component Tests:** Define component/unit tests to create or extend locally (specifying test files, mocked state/props, expected layout rendering states, and user interaction sequences).

### Automated User Flows

1. **Flow Name:** Step-by-step automated user interaction sequence.
   - Navigate to `{URL}`
   - Fill `[data-testid="..."]` with `{input}`
   - Click `[data-testid="..."]`
   - Assert page redirects to `{URL}` or displays element `[data-testid="..."]`
   - Capture screenshot: `expect(page).toHaveScreenshot('{flow-name}.png')` for each viewport in Visual Regression Viewports

### Playwright Element Selectors

- List all mandatory `data-testid` attributes that the frontend must implement to support automated targeting.

### Visual Regression Viewports

- List viewport dimensions for automated screenshot comparisons (e.g., 1920x1080, 768x1024, 375x812).
````

## Example

```markdown
# User Authentication System

Implement JWT-based authentication with registration, login, and logout flows.

## Approved: pending

## Test Tier: e2e

## Docs Affected: true

## Docs Updated: false

## Verify Cmd: yarn test && yarn lint

## Intent

Authentication is the app's trust boundary: registration must not leak whether an account already exists, sessions must expire, and protected routes must reject invalid tokens before any business logic runs. A login that "works" but skips these is a working vulnerability — the milestones below exist to make account access safe, not merely possible.

### Outcomes

- **FR-001**: WHEN a visitor registers with a valid email and a password of 8+ characters, THE SYSTEM SHALL create the account with a bcrypt-hashed password (12 rounds); IF the email is already registered, THE SYSTEM SHALL respond 409 without disclosing account state.
- **FR-002**: WHEN a registered user submits correct credentials, THE SYSTEM SHALL issue a JWT expiring in 24 hours; IF the credentials are wrong, THE SYSTEM SHALL respond 401 with a generic message.
- **FR-003**: WHEN a logged-in user logs out, THE SYSTEM SHALL invalidate the session and clear the token client-side.
- **FR-004**: IF a request carries a missing, malformed, or expired JWT, THE SYSTEM SHALL respond 401 and attach no user to the request.

### Non-Goals

- No social OAuth (Google/GitHub) — v2; needs a privacy review.
- No 2FA/TOTP — v2; not blocking the account-recovery use case.
- No password-reset email flow in this slice — lands in AUTH-002; do not scaffold it here.

## Assumptions & Open Questions

- HS256 chosen over RS256 for simplicity — revisit if key management becomes a requirement.
- [deferred] Rate limiting on the login endpoint — needs a store decision; out of this slice.

## Status: ⏳ Pending

## Milestones

(✅ Done, 🔄 In progress, ⏳ Pending, ⚠️ Blocked, ❌ Failed)

- ⏳ **Milestone 1 (ID: 1, Dependencies: [], Retries: 0, Covers: [])**: [Database Schema] - Create User table with email, password_hash, created_at, updated_at fields in `src/database/schema/users.sql`.
  **Why & Limits:**
  - Why: all later milestones read this schema — field names here are the shared contract for Milestones 2–5.
  - Must not: do not touch `src/api/**` (Milestones 2–3 own it); no migration tooling (repo convention is plain SQL files).
  - If blocked: return Failed with the blocker named — do not improvise outside scope.
- ⏳ **Milestone 2 (ID: 2, Dependencies: [], Retries: 0, Covers: [FR-001, FR-002, FR-003])**: [Auth API Endpoints] - Implement POST /api/auth/register, POST /api/auth/login, POST /api/auth/logout in `src/api/routes/auth.ts`.
- ⏳ **Milestone 3 (ID: 3, Dependencies: [1, 2], Retries: 0, Covers: [FR-004])**: [JWT Middleware] - Create authentication middleware in `src/middleware/auth.ts` that validates JWT tokens and attaches user to request.
- ⏳ **Milestone 4 (ID: 4, Dependencies: [3], Retries: 0, Covers: [FR-002])**: [Frontend Login Form] - Build login component at `src/components/auth/LoginForm.tsx` with email/password fields and form validation.
- ⏳ **Milestone 5 (ID: 5, Dependencies: [3, 4], Retries: 0, Covers: [FR-001])**: [Frontend Registration Form] - Build registration component at `src/components/auth/RegisterForm.tsx` with email/password/confirm-password fields.

## Development Specifications

### Backend

- **Files to modify/create:** `src/database/schema/users.sql`, `src/api/routes/auth.ts`, `src/middleware/auth.ts`, `src/services/auth.ts`
- **API Routes:**
  - POST /api/auth/register - Request: {email, password}, Response: {user_id, token}
  - POST /api/auth/login - Request: {email, password}, Response: {user_id, token}
  - POST /api/auth/logout - Request: {}, Response: {success: true}
- **Data Models / Schema Changes:** Users table with id (UUID), email (VARCHAR, unique), password_hash (VARCHAR), created_at (TIMESTAMP), updated_at (TIMESTAMP)
- **Business Logic:** Password hashing using bcrypt with 12 rounds; JWT tokens with 24h expiration using HS256. Registration password validation as input/output pairs (FR-001):

| Input (password) | Expected result |
| ---------------- | ---------------- |
| fewer than 8 characters | 400 "Password must be at least 8 characters" |
| 8+ characters, valid email | 201, account created |
| email already registered | 409, no account-state disclosure |

- **Automated Unit Tests:** Create `src/tests/auth.test.ts` with tests for registration (valid/invalid email, weak password), login (correct/incorrect credentials), token validation (expired/invalid tokens) — error-code and validation cases derive from FR-001..FR-004.

### Frontend

- **Files to modify/create:** `src/components/auth/LoginForm.tsx`, `src/components/auth/RegisterForm.tsx`, `src/hooks/useAuth.ts`, `src/pages/Login.tsx`, `src/pages/Register.tsx`
- **Components:** LoginForm (email input, password input, submit button), RegisterForm (email input, password input, confirm password input, submit button), useAuth hook (login, register, logout functions)
- **API Integration:** LoginForm calls POST /api/auth/login, RegisterForm calls POST /api/auth/register, useAuth manages token in localStorage
- **Styling Notes:** Use semantic HTML (form, label, input), responsive design for mobile (max-width: 400px), accessibility (aria-labels, focus states)
- **Automated Component Tests:** Create `src/components/auth/LoginForm.test.tsx` and `RegisterForm.test.tsx` with tests for form validation, API calls, error handling, loading states

### Automated User Flows

1. **Registration Flow:** Step-by-step automated user interaction sequence.
   - Navigate to `/register`
   - Fill `[data-testid="register-email"]` with `test@example.com`
   - Fill `[data-testid="register-password"]` with `SecurePass123!`
   - Fill `[data-testid="register-confirm-password"]` with `SecurePass123!`
   - Click `[data-testid="register-submit"]`
   - Assert page redirects to `/login` or displays success message `[data-testid="register-success"]`
   - Capture screenshot: `expect(page).toHaveScreenshot('registration.png')` for each viewport

2. **Login Flow:** Step-by-step automated user interaction sequence.
   - Navigate to `/login`
   - Fill `[data-testid="login-email"]` with `test@example.com`
   - Fill `[data-testid="login-password"]` with `SecurePass123!`
   - Click `[data-testid="login-submit"]`
   - Assert page redirects to `/dashboard` or displays user info `[data-testid="user-info"]`
   - Capture screenshot: `expect(page).toHaveScreenshot('login.png')` for each viewport

3. **Logout Flow:** Step-by-step automated user interaction sequence.
   - Navigate to `/dashboard`
   - Click `[data-testid="logout-button"]`
   - Assert page redirects to `/login` and localStorage is cleared
   - Capture screenshot: `expect(page).toHaveScreenshot('logout.png')` for each viewport

### Playwright Element Selectors

- `[data-testid="register-email"]` - Registration email input
- `[data-testid="register-password"]` - Registration password input
- `[data-testid="register-confirm-password"]` - Registration confirm password input
- `[data-testid="register-submit"]` - Registration submit button
- `[data-testid="login-email"]` - Login email input
- `[data-testid="login-password"]` - Login password input
- `[data-testid="login-submit"]` - Login submit button
- `[data-testid="logout-button"]` - Logout button
- `[data-testid="user-info"]` - User info display

### Visual Regression Viewports

- 1920x1080 (desktop)
- 768x1024 (tablet)
- 375x812 (mobile)
```
