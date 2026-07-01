# Repo Fingerprint

> Captures the technical stack and infrastructure details of a repository for quick reference and delta-context auditing.

## File Location and Naming

- **Directory:** `{{workspace_dir}}/knowledge/`
- **Filename:** `{{workspace_dir}}/knowledge/repo-fingerprint.md`
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

### Unit Testing Framework

{unit testing framework and version}

### E2E Testing Framework

{E2E testing framework and version}

### Mocking Libraries

{mocking libraries and versions}

### Coverage Tools

{code coverage tools and versions}

### Additional Testing Tools

{other testing tools like visual regression, performance testing, etc.}

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

Always include specific version numbers for all technologies.

### Scan Key Configuration Files

Examine:
- `package.json`, `yarn.lock`, `package-lock.json` — Node.js projects
- `.csproj`, `.sln` — .NET projects
- `requirements.txt`, `pyproject.toml` — Python projects
- `Cargo.toml` — Rust projects
- `go.mod` — Go projects
- `.github/workflows/`, `.gitlab-ci.yml` — CI/CD configuration
- `docker-compose.yml`, `Dockerfile` — container configuration

### Update Strategically

Only update when:
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

### Unit Testing Framework

Vitest 1.2.0

### E2E Testing Framework

Playwright 1.40.0

### Mocking Libraries

MSW 2.0.0, vi.mock (Vitest built-in)

### Coverage Tools

c8 9.0.0

### Additional Testing Tools

axe-core for accessibility testing

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
