# Repo Fingerprint

A REPO FINGERPRINT file captures the technical stack and infrastructure details of a repository. It serves as a quick reference for understanding the project's technology choices and enables efficient delta-context auditing by avoiding repeated full repository scans.

## Purpose

The repo fingerprint serves as a single source of truth for:
- **Technology Stack** — Package managers, runtimes, frameworks, and libraries
- **Infrastructure** — Build tools, CI/CD systems, and deployment targets
- **Database** — Database systems, ORM tools, and connection patterns
- **Efficiency** — Enables delta-context auditing by identifying what has changed since the last scan

## File Location and Naming

- **Directory:** `{{workspace_dir}}/plans/`
- **Filename:** `{{workspace_dir}}/plans/repo-fingerprint.md`
- **Creation:** Create lazily when the compose skill first needs technical stack information
- **Updates:** Update only when significant technology changes are detected

## Structure

```markdown
# Repo Fingerprint

Last updated: {timestamp}

## Package Manager

{package manager and version}

## Runtime

{runtime environment and version}

## Backend Framework

{backend framework and version}

## Frontend Framework

{frontend framework and version}

## UI Library

{UI library and version}

## Testing

{testing frameworks and tools}

## Database

{database system and version}

## ORM/Database Tools

{ORM or database tools and versions}

## Build Tools

{build tools and versions}

## CI/CD

{CI/CD system and configuration}

## Additional Context

{any other relevant technical details}
```

## Writing Rules

### Be Specific with Versions

Always include specific version numbers for all technologies. Use the latest stable versions unless the existing codebase requires specific versions for compatibility.

### Scan Key Configuration Files

Generate the fingerprint by examining:
- `package.json`, `yarn.lock`, `package-lock.json` — Node.js projects
- `.csproj`, `.sln` — .NET projects
- `requirements.txt`, `pyproject.toml` — Python projects
- `Cargo.toml` — Rust projects
- `go.mod` — Go projects
- `.github/workflows/`, `.gitlab-ci.yml` — CI/CD configuration
- `docker-compose.yml`, `Dockerfile` — container configuration

### Update Strategically

Only update the fingerprint when:
- New dependencies are added that change the technology stack
- Major version upgrades occur
- New frameworks or tools are introduced
- CI/CD configuration changes significantly

## Example

```markdown
# Repo Fingerprint

Last updated: 2026-06-17

## Package Manager

yarn 1.22.19

## Runtime

Node.js 20.10.0

## Backend Framework

Express 4.18.2

## Frontend Framework

Svelte 4.2.0

## UI Library

Tailwind CSS 3.4.0

## Testing

Jest 29.7.0, Playwright 1.40.0

## Database

PostgreSQL 15.2

## ORM/Database Tools

Prisma 5.8.0

## Build Tools

Vite 5.0.0

## CI/CD

GitHub Actions with Node.js 20 runner

## Additional Context

- Monorepo structure using Turborepo
- Docker containers for local development
- Redis for caching layer
