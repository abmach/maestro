# Plan

> Defines the execution strategy for a feature: milestones as a DAG, test tiers, and development specifications.

## File Location and Naming

- **Directory:** `{{workspace_dir}}/plans/`
- **Naming convention:** Meaningful feature code with sequential number: `AUTH-001-user-authentication.md`, `PAY-002-stripe-integration.md`, etc.
- **Index file:** `{{workspace_dir}}/plans/index.md` tracks all plans and their status
- **Directory creation:** Create `{{workspace_dir}}/plans/` lazily when the first plan is needed

## Test Tier Classification

Each plan must specify a `Test Tier` to indicate the level of automated testing required:

- **e2e** — Full end-to-end testing with comprehensive Playwright test coverage for major features and user flows
- **smoke** — Basic smoke testing with minimal automated tests for smaller changes and bug fixes
- **none** — No automated testing required for trivial changes that don't affect user-facing behavior

## Documentation Impact

Each plan must specify `Docs Affected` to indicate whether the change requires documentation updates:

- **true** — The change affects user-facing behavior, API contracts, or requires manual updates
- **false** — The change is internal, refactoring, or doesn't impact user documentation

When `Docs Affected` is `true`, the plan must also track `Docs Updated` to indicate whether documentation has been completed:

- **true** — Documentation has been updated
- **false** — Documentation not yet updated, or not applicable (when `Docs Affected` is `false`)

## Writing Rules

### Use Relative Paths

Always use relative paths (e.g., `src/`, `tests/`, `package.json`) instead of absolute repository paths.

### Define Milestones as a DAG

Structure the plan as a Directed Acyclic Graph where each milestone has:
- A unique numeric ID
- A list of dependencies (referencing preceding milestone IDs)
- A clear, actionable description

Independent milestones (empty dependencies) can execute in parallel. Integration milestones depend on completion of their prerequisites.

### DAG Milestone Requirements

When defining milestones in the Steps section, incorporate these mandatory milestones based on plan metadata:

**E2E Testing (if `Test Tier` is `e2e`):**
- Milestone for E2E Test Creation (depends on feature completion)
- Milestone for E2E Test Execution (depends on test creation)

**Smoke Testing (if `Test Tier` is `smoke`):**
- You MAY include basic smoke testing milestones if appropriate for the change scope

**Documentation (if `Docs Affected` is `true`):**
- Milestone for Documentation Update (depends on development or E2E testing completion)

### Be Specific and Unambiguous

- List exact file paths to modify or create
- Define explicit API routes with method, path, and JSON structures
- Specify exact unit test file paths and test cases
- Provide precise component hierarchies, props, and state definitions

### Optional Milestone Elaboration

- **Implementation Guidance:** Detailed step-by-step breakdowns, specific file paths, prerequisite checks, integration points
- **Code Patterns:** Relevant code snippets following project conventions, interface implementations, configuration examples
- **Testing Strategy:** Specific test cases, edge cases to cover, mock data requirements, test file locations
- **Error Handling:** Common error scenarios, validation requirements, failure modes, recovery strategies
- **Best Practices:** Performance considerations, security considerations, code organization patterns
- **Common Pitfalls:** Mistakes to avoid, anti-patterns to watch for, debugging hints

Elaboration format example:

```markdown
- ⏳ **Milestone 1 (ID: 1, Dependencies: [])**: [Short Title] - Specific detailed task description.
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
  - Create test file at `tests/path/to/test.spec.ts`
  - Test cases: [specific cases]
  - Mock data: [specific mock requirements]
```

### Status Management

Use the standard status legend for both the overall plan and individual milestones:
- ✅ Done
- 🔄 In progress
- ⏳ Pending
- ⚠️ Blocked
- ❌ Failed

### Numbering Strategy

1. Choose a meaningful feature code (e.g., `AUTH` for authentication, `PAY` for payments, `UI` for user interface)
2. Scan `{{workspace_dir}}/plans/` for the highest existing number for that feature code
3. Increment by one for the new plan
4. Use hyphen-separated format: `{CODE}-{number}-{descriptive-slug}.md`
5. Use zero-padded three-digit numbers (e.g., `AUTH-001`, `PAY-002`) for consistent sorting

## Template

````markdown
# {Feature Title}

> Brief one-line summary of the feature or change.

## Test Tier: e2e/smoke/none

## Docs Affected: true/false

## Docs Updated: true/false

## Status: ✅ Done/🔄 In progress/⏳ Pending/⚠️ Blocked/❌ Failed

## Steps

(✅ Done, 🔄 In progress, ⏳ Pending, ⚠️ Blocked, ❌ Failed)

- ⏳ **Milestone 1 (ID: 1, Dependencies: [])**: [Short Title] - Specific detailed task description.
- ⏳ **Milestone 2 (ID: 2, Dependencies: [])**: [Short Title] - Independent milestone (can run in parallel with Milestone 1).
- ⏳ **Milestone 3 (ID: 3, Dependencies: [1, 2])**: [Short Title] - Integration milestone (requires both Milestone 1 and 2 to be completed first).
- ⏳ **Milestone 4 (ID: 4, Dependencies: [3])**: [E2E Test Creation] - Spawn `e2e_test_developer` to write Playwright test cases covering the integrated user flow.
- ⏳ **Milestone 5 (ID: 5, Dependencies: [4])**: [E2E Test Execution] - Invoke `audition` skill to execute test specs and capture results.
- ⏳ **Milestone 6 (ID: 6, Dependencies: [5])**: [Documentation Update] - Spawn `doc_processor` to update manuals, Readmes, or API descriptions under `docs/` based on final layout and E2E visual captures.
- ...

**Optional Elaboration Example:**

```markdown
- ⏳ **Milestone 1 (ID: 1, Dependencies: [])**: Implement JWT authentication service
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
  - Create `tests/auth/jwt-authenticator.spec.ts`
  - Test token generation with valid user data
  - Test token validation with valid and expired tokens
  - Test error handling for malformed tokens
  **Common Pitfalls:**
  - Don't store secrets in frontend code
  - Ensure token expiration is properly validated
  - Handle clock skew in token validation
```

## Development Specifications

### Backend

- **Files to modify/create:** List exact file paths.
- **API Routes:** Define method, path, request/response JSON structures.
- **Data Models / Schema Changes:** Define fields, types, constraints, migration details.
- **Business Logic:** Define explicit conditional boundaries, expected inputs, and outputs. No ambiguity.
- **Automated Unit Tests:** Define the exact unit/integration test suites, file paths, and test cases to create or extend locally (specifying positive flows, edge cases, error codes, and validation failures).

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

### Playwright Element Selectors

- List all mandatory `data-testid` attributes that the frontend must implement to support automated targeting.

### Visual Regression Viewports

- List viewport dimensions for automated screenshot comparisons (e.g., 1920x1080, 768x1024, 375x812).
````

## Example

```markdown
# User Authentication System

Implement JWT-based authentication with login, registration, and password reset flows.

## Test Tier: e2e

## Docs Affected: true

## Docs Updated: false

## Status: ⏳ Pending

## Steps

(✅ Done, 🔄 In progress, ⏳ Pending, ⚠️ Blocked, ❌ Failed)

- ⏳ **Milestone 1 (ID: 1, Dependencies: [])**: [Database Schema] - Create User table with email, password_hash, created_at, updated_at fields in `src/database/schema/users.sql`.
- ⏳ **Milestone 2 (ID: 2, Dependencies: [])**: [Auth API Endpoints] - Implement POST /api/auth/register, POST /api/auth/login, POST /api/auth/logout in `src/api/routes/auth.ts`.
- ⏳ **Milestone 3 (ID: 3, Dependencies: [1, 2])**: [JWT Middleware] - Create authentication middleware in `src/middleware/auth.ts` that validates JWT tokens and attaches user to request.
- ⏳ **Milestone 4 (ID: 4, Dependencies: [3])**: [Frontend Login Form] - Build login component at `src/components/auth/LoginForm.tsx` with email/password fields and form validation.
- ⏳ **Milestone 5 (ID: 5, Dependencies: [3, 4])**: [Frontend Registration Form] - Build registration component at `src/components/auth/RegisterForm.tsx` with email/password/confirm-password fields.
- ⏳ **Milestone 6 (ID: 6, Dependencies: [5])**: [E2E Test Creation] - Spawn `e2e_test_developer` to write Playwright test cases covering the complete auth flow (registration → login → logout).
- ⏳ **Milestone 7 (ID: 7, Dependencies: [6])**: [E2E Test Execution] - Invoke `audition` skill to execute test specs and capture results of auth forms.
- ⏳ **Milestone 8 (ID: 8, Dependencies: [7])**: [Documentation Update] - Spawn `doc_processor` to update API documentation under `docs/api/auth.md` with authentication endpoints and JWT usage.

## Development Specifications

### Backend

- **Files to modify/create:** `src/database/schema/users.sql`, `src/api/routes/auth.ts`, `src/middleware/auth.ts`, `src/services/auth.ts`
- **API Routes:**
  - POST /api/auth/register - Request: {email, password}, Response: {user_id, token}
  - POST /api/auth/login - Request: {email, password}, Response: {user_id, token}
  - POST /api/auth/logout - Request: {}, Response: {success: true}
- **Data Models / Schema Changes:** Users table with id (UUID), email (VARCHAR, unique), password_hash (VARCHAR), created_at (TIMESTAMP), updated_at (TIMESTAMP)
- **Business Logic:** Password hashing using bcrypt with 12 rounds, JWT tokens with 24h expiration using HS256, email validation with regex pattern
- **Automated Unit Tests:** Create `src/tests/auth.test.ts` with tests for registration (valid/invalid email, weak password), login (correct/incorrect credentials), token validation (expired/invalid tokens)

### Frontend

- **Files to modify/create:** `src/components/auth/LoginForm.tsx`, `src/components/auth/RegisterForm.tsx`, `src/hooks/useAuth.ts`, `src/pages/Login.tsx`, `src/pages/Register.tsx`
- **Components:** LoginForm (email input, password input, submit button), RegisterForm (email input, password input, confirm password input, submit button), useAuth hook (login, register, logout functions)
- **API Integration:** LoginForm calls POST /api/auth/login, RegisterForm calls POST /api/auth/register, useAuth manages token in localStorage
- **Styling Notes:** Use semantic HTML (form, label, input), responsive design for mobile (max-width: 400px), accessibility (aria-labels, focus states)
- **Automated Component Tests:** Create `src/components/auth/__tests__/LoginForm.test.tsx` and `RegisterForm.test.tsx` with tests for form validation, API calls, error handling, loading states

### Automated User Flows

1. **Registration Flow:** Step-by-step automated user interaction sequence.
   - Navigate to `/register`
   - Fill `[data-testid="register-email"]` with `test@example.com`
   - Fill `[data-testid="register-password"]` with `SecurePass123!`
   - Fill `[data-testid="register-confirm-password"]` with `SecurePass123!`
   - Click `[data-testid="register-submit"]`
   - Assert page redirects to `/login` or displays success message `[data-testid="register-success"]`

2. **Login Flow:** Step-by-step automated user interaction sequence.
   - Navigate to `/login`
   - Fill `[data-testid="login-email"]` with `test@example.com`
   - Fill `[data-testid="login-password"]` with `SecurePass123!`
   - Click `[data-testid="login-submit"]`
   - Assert page redirects to `/dashboard` or displays user info `[data-testid="user-info"]`

3. **Logout Flow:** Step-by-step automated user interaction sequence.
   - Navigate to `/dashboard`
   - Click `[data-testid="logout-button"]`
   - Assert page redirects to `/login` and localStorage is cleared

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
