# Plans Index

> Central registry for all feature plans, tracking status from pending through completion.

## File Location and Naming

- **Directory:** `{{workspace_dir}}/plans/`
- **Index file:** `{{workspace_dir}}/plans/index.md` — central registry for all plans
- **Directory creation:** Create `{{workspace_dir}}/plans/` lazily when the first plan is needed

## Writing Rules

### Entry Format

Each plan entry must follow this exact format:

```markdown
- [status] **Title** *([plan-file.md](plan-file.md))*
  Brief description
```

### Status Legend

Use these status indicators for each plan:
- ✅ Done — Plan fully executed and completed
- 🔄 In progress — Currently being executed
- ⏳ Pending — Queued for execution
- ⚠️ Blocked — Waiting on dependencies or external factors
- ❌ Failed — Execution failed and requires attention

### Entry Content

- **Title**: Concise, descriptive name of the feature or change
- **Link**: Markdown link to the specific plan file
- **Description**: One to two sentences explaining what the plan implements

### Ordering

- Group entries by status (Done → In progress → Pending → Blocked → Failed)
- Within each status group, order by recency (newest first)
- Maintain consistent ordering to support quick scanning

---

## Template

```markdown
# Plans Index

(✅ Done/🔄 In progress/⏳ Pending/⚠️ Blocked/❌ Failed)

## Done

- ✅ **User Authentication System** *([AUTH-001-user-authentication.md](AUTH-001-user-authentication.md))*
  Implemented JWT-based authentication with login, registration, and password reset flows.

- ✅ **Database Migration System** *([DB-001-migration-framework.md](DB-001-migration-framework.md))*
  Created automated database migration framework with rollback capabilities.

## In Progress

- 🔄 **Payment Integration** *([PAY-001-stripe-integration.md](PAY-001-stripe-integration.md))*
  Integrating Stripe for payment processing with subscription management.

## Pending

- ⏳ **Admin Dashboard** *([UI-001-admin-dashboard.md](UI-001-admin-dashboard.md))*
  Build comprehensive admin interface for user and content management.

- ⏳ **API Rate Limiting** *([API-001-rate-limiting.md](API-001-rate-limiting.md))*
  Implement rate limiting for all public API endpoints.

## Blocked

- ⚠️ **File Upload System** *([STR-001-file-uploads.md](STR-001-file-uploads.md))*
  Waiting on S3 bucket configuration from infrastructure team.

## Failed

- ❌ **Email Service Integration** *([COM-001-email-service.md](COM-001-email-service.md))*
  Failed due to SMTP configuration issues, requires retry.
```

## Maintenance

### Creating Plans

When a new plan is created by the `compose` skill:
1. Add entry to index.md with status ⏳ Pending
2. Place at top of Pending section
3. Include link to new plan file
4. Add brief description

### Updating Status

When plan status changes during orchestration:
1. Move entry to appropriate status section
2. Update status emoji
3. Maintain position within section (newest first)

### Cleaning Up

When plans are completed and archived:
1. Move to Done section
2. Consider archiving old Done entries to separate file if index grows too large
3. Keep recent Done entries visible for reference
