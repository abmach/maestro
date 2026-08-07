# Issues Index

> Central registry for all issues, tracking status, severity, and priority through resolution.

## File Location and Naming

- **Directory:** `{{WORKSPACE}}/issues/`
- **Index file:** `{{WORKSPACE}}/issues/index.md` — central registry for all issues
- **Directory creation:** Create `{{WORKSPACE}}/issues/` lazily when the first issue is needed

## Writing Rules

### Entry Format

Each issue entry must follow this exact format:

```markdown
- [status] **{ISSUE-TYPE}-{NUMBER}: {Title}** *([issue-file.md](issue-file.md))*
  [Severity: {Critical/High/Medium/Low}] [Priority: {P1/P2/P3/P4}] Brief description
```

### Status Legend

Use these status indicators for each issue:
- 🟢 Open — Issue reported and triaged, awaiting resolution
- 🔄 In Progress — Investigation and resolution underway
- ✅ Resolved — Issue fixed and verified
- ⚪ Wontfix — Issue declined (not a bug, out of scope, etc.)

### Severity Legend

Use these severity indicators:
- 🔴 Critical — System down, data loss, security breach
- 🟠 High — Major functionality broken, significant performance degradation
- 🟡 Medium — Minor functionality issues, moderate performance problems
- 🟢 Low — Cosmetic issues, minor inconvenience

### Priority Legend

Use these priority indicators:
- P1 — Immediate resolution required
- P2 — High priority, resolve within 24-48 hours
- P3 — Normal priority, resolve within 1 week
- P4 — Low priority, resolve when convenient

### Entry Content

- **Title**: Issue type with number and descriptive title
- **Link**: Markdown link to the specific issue file
- **Severity**: Impact assessment (Critical/High/Medium/Low)
- **Priority**: Resolution urgency (P1/P2/P3/P4)
- **Description**: One to two sentences explaining the problem

### Ordering

- Group entries by status (Open → In Progress → Resolved → Wontfix)
- Within each status group, order by priority (P1 → P2 → P3 → P4)
- Within same priority, order by severity (Critical → High → Medium → Low)
- Within same priority and severity, order by recency (newest first)

---

## Template

```markdown
# Issues Index

(🟢 Open/🔄 In Progress/✅ Resolved/⚪ Wontfix)

## Open

- 🟢 **BUG-001: Authentication Token Expiration** *([BUG-001-authentication-token-expiration.md](BUG-001-authentication-token-expiration.md))*
  [Severity: 🟠 High] [Priority: P2] Users logged out unexpectedly after 1 hour despite 24-hour token configuration

- 🟢 **BUILD-002: Compilation Error in Payment Module** *([BUILD-002-compilation-error-payment.md](BUILD-002-compilation-error-payment.md))*
  [Severity: 🔴 Critical] [Priority: P1] Payment module fails to compile after dependency update

- 🟢 **PERF-003: Slow Database Query** *([PERF-003-slow-database-query.md](PERF-003-slow-database-query.md))*
  [Severity: 🟡 Medium] [Priority: P3] User list query takes 15 seconds with 10,000 records

## In Progress

- 🔄 **SEC-004: SQL Injection Vulnerability** *([SEC-004-sql-injection-vulnerability.md](SEC-004-sql-injection-vulnerability.md))*
  [Severity: 🔴 Critical] [Priority: P1] User input not properly sanitized in search functionality

## Resolved

- ✅ **UI-005: Mobile Layout Broken** *([UI-005-mobile-layout-broken.md](UI-005-mobile-layout-broken.md))*
  [Severity: 🟡 Medium] [Priority: P3] Navigation menu not responsive on mobile devices

- ✅ **TEST-006: Flaky Integration Test** *([TEST-006-flaky-integration-test.md](TEST-006-flaky-integration-test.md))*
  [Severity: 🟠 High] [Priority: P2] User creation test fails intermittently due to timing issues

## Wontfix

- ⚪ **DOCS-007: Outdated API Documentation** *([DOCS-007-outdated-api-documentation.md](DOCS-007-outdated-api-documentation.md))*
  [Severity: 🟢 Low] [Priority: P4] Legacy API endpoints deprecated, documentation not being updated
```

## Maintenance

### Creating Issues

When a new issue is reported:
1. Create issue file in `{{WORKSPACE}}/issues/` with appropriate type and number
2. Add entry to index.md with status 🟢 Open
3. Set severity and priority based on impact assessment
4. Place in appropriate position within Open section (sorted by priority/severity/recency)

### Updating Status

When issue status changes:
1. Update status field in issue file
2. Move entry to appropriate status section in index
3. Maintain proper ordering within the new status section
4. Update status emoji in index entry

### Resolving Issues

When an issue is resolved:
1. Update status to ✅ Resolved in issue file
2. Document final resolution and prevention measures
3. Move entry to Resolved section in index
4. Consider if resolution requires new plan or documentation update

### Closing Issues

When an issue is marked as Wontfix:
1. Update status to ⚪ Wontfix in issue file
2. Document reason for declining (not a bug, out of scope, etc.)
3. Move entry to Wontfix section in index

### Cleaning Up

Periodically review and clean up the index:
- Archive old resolved issues to separate file if index grows too large
- Keep recent resolved issues visible for reference
- Remove wontfix issues that are no longer relevant
- Ensure all entries have valid links to existing issue files
