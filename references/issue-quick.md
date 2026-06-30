# Issue (Quick Spec)

> Compact format reference. See `{{workspace_dir}}/.agents/references/issue.md` for full spec with example and writing rules.

## File Location

- **Directory:** `{{workspace_dir}}/issues/`
- **Naming:** `{TYPE}-{NNN}-{slug}.md` (e.g., `BUG-001-authentication-failure.md`)
- **Index:** `{{workspace_dir}}/issues/index.md`

## Issue Types

`BUG` | `BUILD` | `PERF` | `SEC` | `UI` | `TEST` | `DOCS` | `DEP`

## Classifications

**Severity:** `Critical` | `High` | `Medium` | `Low`
**Priority:** `P1` (immediate) | `P2` (24-48h) | `P3` (1 week) | `P4` (when convenient)
**Status:** `Open` → `In Progress` → `Resolved` | `Wontfix`

## Template

```markdown
# {TYPE}-{NUMBER}: {Issue Title}

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

## Expected Behavior
{What should happen}

## Actual Behavior
{What actually happens}

## Impact Assessment
- **User Impact:** {Effect on users}
- **System Impact:** {Effect on system stability/performance}
- **Business Impact:** {Business consequences}

## Environment
- **Environment:** {Dev/Staging/Production}
- **Configuration:** {Relevant settings}
- **Dependencies:** {Affected dependencies/versions}

## Investigation Notes
{Analysis of root cause, debugging steps taken}

## Resolution Attempts
### Attempt 1: {Description}
- **Date:** {YYYY-MM-DD}
- **Approach:** {Solution attempted}
- **Result:** {Success/Failure/Partial}
- **Notes:** {Additional details}

## Resolution
{Final solution if issue is resolved}

## Prevention
{Steps to prevent similar issues in future}

## Related Issues
- [ISSUE-TYPE-NUMBER]({{workspace_dir}}/issues/ISSUE-TYPE-NUMBER-issue-title.md) — Related issue description
- [PLAN-TYPE-NUMBER]({{workspace_dir}}/plans/PLAN-TYPE-NUMBER-plan-title.md) — Related plan if fix requires feature work

## References
Links to relevant workspace content (NOT specification files):
- [Error Logs]({{workspace_dir}}/path/to/logs) — Link to relevant logs
- [Contexts]({{workspace_dir}}/knowledge/contexts.md) — Domain language references
- [ADRs]({{workspace_dir}}/knowledge/adrs/) — Architectural decisions
```
