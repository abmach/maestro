# Issues

> Defines a codebase problem: type, severity, priority, reproduction steps, impact assessment, and resolution tracking.

## File Location and Naming

- **Directory:** `{{WORKSPACE}}/issues/`
- **Naming convention:** Issue type with sequential number: `BUG-001-authentication-failure.md`, `BUILD-002-compilation-error.md`, `PERF-003-slow-query.md`, etc.
- **Index file:** `{{WORKSPACE}}/issues/index.md` tracks all issues and their status
- **Directory creation:** Create `{{WORKSPACE}}/issues/` lazily when the first issue is needed

## Issue Types

Classify issues by type to enable better tracking and prioritization:

- **BUG** — Functional bugs, incorrect behavior, logic errors
- **BUILD** — Compilation errors, dependency issues, build failures
- **PERF** — Performance problems, slow queries, memory leaks
- **SEC** — Security vulnerabilities, authentication issues, data exposure
- **UI** — User interface problems, layout issues, accessibility
- **TEST** — Test failures, flaky tests, coverage gaps
- **DOCS** — Documentation errors, outdated information, missing docs
- **DEP** — Deprecated code, technical debt, refactoring needs

## Issue Structure

Each issue file must follow this structure:

```markdown
# {ISSUE-TYPE}-{NUMBER}: {Issue Title}

**Status:** {Open/In Progress/Resolved/Wontfix}
**Severity:** {Critical/High/Medium/Low}
**Priority:** {P1/P2/P3/P4}
**Reported By:** {User/System}
**Reported Date:** {YYYY-MM-DD}
**Affected Components:** {Component list}

## Description

{Detailed description of the problem}

## Error Details

{Error messages, stack traces, build logs}

## Reproduction Steps

1. Step one
2. Step two
3. Step three

## Expected Behavior

{What should happen}

## Actual Behavior

{What actually happens}

## Impact Assessment

- **User Impact:** {Effect on users}
- **System Impact:** {Effect on system stability/performance}
- **Business Impact:** {Business consequences}

## Environment

- **Environment:** {Development/Staging/Production}
- **Configuration:** {Relevant configuration settings}
- **Dependencies:** {Affected dependencies/versions}

## Investigation Notes

{Analysis of root cause, debugging steps taken}

## Resolution Attempts

### Attempt 1: {Description}
- **Date:** {YYYY-MM-DD}
- **Approach:** {Solution attempted}
- **Result:** {Success/Failure/Partial}
- **Notes:** {Additional details}

### Attempt 2: {Description}
- **Date:** {YYYY-MM-DD}
- **Approach:** {Solution attempted}
- **Result:** {Success/Failure/Partial}
- **Notes:** {Additional details}

## Resolution

{Final solution if issue is resolved}

## Prevention

{Steps to prevent similar issues in future}

## Related Issues

- [ISSUE-TYPE-NUMBER](./issues/ISSUE-TYPE-NUMBER-issue-title.md) — Related issue description
- [PLAN-TYPE-NUMBER](./plans/PLAN-TYPE-NUMBER-plan-title.md) — Related plan if fix requires feature work

## References

Links to relevant workspace content (NOT specification files in `.agents/references/`):

- [Error Logs](./path/to/logs}) — Link to relevant logs
- [Contexts](./knowledge/contexts.md) — Domain language references
- [ADRs](./knowledge/adrs/) — Architectural decisions that may be relevant
```

## Severity Classification

- **Critical** — System down, data loss, security breach, complete feature failure
- **High** — Major functionality broken, significant performance degradation, security risk
- **Medium** — Minor functionality issues, moderate performance problems, workaround available
- **Low** — Cosmetic issues, minor inconvenience, no workaround needed

## Priority Classification

- **P1** — Immediate resolution required (Critical issues)
- **P2** — High priority, resolve within 24-48 hours (High issues)
- **P3** — Normal priority, resolve within 1 week (Medium issues)
- **P4** — Low priority, resolve when convenient (Low issues)

## Status Workflow

Issues follow this status progression:
1. **Open** — Issue reported and triaged
2. **In Progress** — Investigation and resolution underway
3. **Resolved** — Issue fixed and verified
4. **Wontfix** — Issue declined (not a bug, out of scope, etc.)

## Writing Rules

### Be Specific

- **Bad:** "Authentication doesn't work"
- **Good:** "JWT token validation fails with 'Invalid signature' error when token expires after 1 hour"

### Include Context

- Environment (dev/staging/prod)
- Recent changes that may have introduced the issue
- Configuration settings
- User actions that trigger the problem

### Document Attempts

- What was tried
- Why it failed
- What was learned
- Next steps based on findings

### Link to Related Work

- Other issues that may be related
- Plans that implement fixes
- ADRs that influenced the design
- Contexts that define relevant terminology

## Maintenance

### Creating Issues

When a new issue is identified:
1. Create issue file in `{{WORKSPACE}}/issues/` with appropriate type and number
2. Add entry to `issues/index.md` with status Open
3. Include all available error details and reproduction steps
4. Set severity and priority based on impact assessment

### Updating Status

When issue status changes:
1. Update status field in issue file
2. Move entry to appropriate status section in index
3. Add resolution attempts and final resolution if resolved
4. Update prevention measures if applicable

### Resolving Issues

When an issue is resolved:
1. Document the final solution in the Resolution section
2. Add prevention measures to avoid recurrence
3. Update status to Resolved
4. Move to Resolved section in index
5. Consider if fix requires new plan or documentation update

### Using the Tune Skill

For systematic issue resolution, use the `tune` skill:
- **Invocation:** `/tune ISSUE-ID` (e.g., `/tune BUG-001`)
- **Workflow:** The tune skill follows a systematic debugging and resolution process
- **Benefits:** Automated investigation, solution design, implementation, and verification
- **Integration:** Tune automatically updates issue files and issues index throughout the resolution process

## Example

````markdown
# BUG-001: JWT Authentication Token Expiration

**Status:** Resolved
**Severity:** High
**Priority:** P2
**Reported By:** System
**Reported Date:** 2026-06-22
**Affected Components:** Authentication Service, API Gateway

## Description

Users are being logged out unexpectedly after 1 hour despite JWT tokens being configured with 24-hour expiration.

## Error Details

```
Error: Invalid signature
at JWT.verify (auth-service.js:45)
at authenticate (middleware.js:23)
```

## Reproduction Steps

1. User logs in successfully
2. User remains active for 1 hour
3. After 1 hour, next API request fails with "Invalid signature" error
4. User is forced to log in again

## Expected Behavior

Users should remain authenticated for 24 hours as configured in JWT settings.

## Actual Behavior

Users are logged out after 1 hour with token validation failure.

## Impact Assessment

- **User Impact:** High - frequent logouts disrupt user workflow
- **System Impact:** Medium - authentication service functioning but with incorrect timeout
- **Business Impact:** Medium - user experience degradation, potential user churn

## Environment

- **Environment:** Production
- **Configuration:** JWT_EXPIRATION=24h
- **Dependencies:** jsonwebtoken v8.5.0

## Investigation Notes

Root cause identified: Token refresh mechanism not implemented. Access tokens expire after 1 hour (default JWT setting) but no refresh token flow exists.

## Resolution Attempts

### Attempt 1: Extend JWT expiration to 24h
- **Date:** 2026-06-22
- **Approach:** Changed JWT_EXPIRATION from 1h to 24h
- **Result:** Failed - security team rejected due to increased exposure if token is compromised
- **Notes:** Security concern with long-lived access tokens

### Attempt 2: Implement refresh token flow
- **Date:** 2026-06-23
- **Approach:** Added refresh token mechanism with 7-day expiration
- **Result:** Success - tokens now refresh automatically before expiration
- **Notes:** Requires [PLAN-AUTH-002-refresh-token-implementation](./plans/AUTH-002-refresh-token-implementation.md)

## Resolution

Implemented refresh token flow with access tokens (1h expiration) and refresh tokens (7-day expiration). Access tokens automatically refresh before expiration.

## Prevention

- Add automated tests for token expiration scenarios
- Monitor authentication failures in production
- Document token lifecycle in API documentation

## Related Issues

- None
- [PLAN-AUTH-002](./plans/AUTH-002-refresh-token-implementation.md) — Refresh token implementation plan that resolved this issue

## References

- [Error Logs](./logs/auth-service-2026-06-22.log}) — Authentication error logs
- [Contexts](./knowledge/contexts.md) — Authentication domain language
- [ADRs](./knowledge/adrs/0001-refresh-token-strategy.md) — Decision to adopt refresh token flow over extended JWT expiration
````
