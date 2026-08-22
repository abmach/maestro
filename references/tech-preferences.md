# Tech Preferences

> Preferred technologies, frameworks, libraries, and version strategy for new projects and technology choices.

## ⚡ Priority: Free and Lightweight

**Free and lightweight frameworks are prioritized** over commercial or heavy alternatives. When choosing technologies, prefer:
- **Open source** with active communities
- **Minimal dependencies** and small bundle sizes
- **Fast execution** and low resource requirements
- **No licensing costs** or restrictions
- **Simple setup** and configuration

Commercial tools should only be considered when they provide essential functionality not available in free alternatives.

## File Location and Naming

- **Directory:** None. This file is just for reference, it's not part of the workspace.

## ⚠️ When to Check Online

Use web search to confirm current versions **only when selecting a NEW technology** to introduce to the project — i.e., when no `Repo Fingerprint` exists yet, or when introducing a framework/library not already recorded in the existing `Repo Fingerprint`. **Do not** re-validate versions for technologies already in the recorded stack: the fingerprint's versions are authoritative. Training-data versions for unfamiliar libraries remain unreliable; web search is the corrective for new selections, not for routine re-validation.

## Preferences

### Package Managers

- **JavaScript/TypeScript:** bun
- **Python:** pip with poetry for dependency management
- **Rust:** Cargo (built-in)
- **Go:** Go modules (built-in)
- **.NET:** NuGet (built-in)

### Runtimes

- **C#/.NET:** LTS version (preferred)
- **Node.js:** LTS version (preferred)
- **Python:** 3.x

### Backend Frameworks

- **Node.js:** Fastify (preferred for performance and lightweight) or Express.js (for simplicity)
- **Python:** FastAPI - modern, async, type-safe, lightweight
- **.NET:** ASP.NET Core Minimal APIs for lightweight services

### Frontend Frameworks

- **Svelte (Preferred):** SvelteKit - lightweight by design, no virtual DOM, excellent performance
- **React:** Vite + React (lightweight SPA) or Next.js when SSR needed
- **Vue:** Vite + Vue (lightweight SPA) or Nuxt when SSR needed
- **Vanilla:** Vite as build tool

### UI Libraries

- **Framework-Agnostic (Preferred):** knadh/oat - ultra-lightweight (~8KB), zero-dependency, semantic HTML/CSS/JS - use for maximum portability and minimal dependencies
- **CSS Framework:** Tailwind CSS - utility-first, modern, lightweight
- **Framework-Specific Component Libraries (use only when needed):**
  - React: shadcn/ui - component-based (copy-paste, no dependency bloat)
  - Vue: Headless UI (unstyled, lightweight) or Nuxt UI
  - Svelte: Skeleton UI (lightweight)
- **Icons:** Lucide (tree-shakeable, modern)

### Database

- **Relational:** SQLite (preferred for lightweight apps) or PostgreSQL (for production scale)
- **Document:** MongoDB
- **Key-Value:** Redis
- **Embedded:** SQLite - for local development/testing

### ORM/Database Tools

- **Node.js:** Drizzle ORM (preferred for lightweight and performance) or Prisma (for type safety)
- **Python:** SQLAlchemy with async support, or Django ORM
- **.NET:** Entity Framework Core

### Build Tools

- **JavaScript/TypeScript:** Vite - fast, modern, lightweight
- **Python:** Poetry for dependency management and packaging
- **Rust:** Cargo (built-in)
- **Go:** Go build (built-in)
- **.NET:** dotnet build (built-in)

### CI/CD

- **Platform:** GitHub Actions (preferred) or GitLab CI
- **Node.js Runner:** Use LTS version
- **Python Runner:** Use stable 3.x version
- **.NET Runner:** Use LTS version

### Additional Tools

- **API Documentation:** OpenAPI/Swagger
- **Code Quality:**
  - JavaScript/TypeScript: ESLint, Prettier
  - Python: Black, Ruff, mypy
  - .NET: StyleCop, Analyzers
- **Containerization:** Docker with multi-stage builds
- **Environment Management:** .env files (never commit)

## Deviation Guidelines

Deviations from these preferences are acceptable when:

1. **Workspace Requirements:** The existing workspace uses different technologies
2. **Specific Needs:** A project has unique requirements that necessitate different choices
3. **Performance:** Alternative technologies offer significant performance benefits
4. **Team Preference:** The development team has established different standards
5. **Legacy Integration:** Integrating with existing systems requires specific technologies

When deviating, document the reason in the ADR or project documentation.

## Version Strategy

- **Verify Online for New Selections:** Search online for the current latest stable release when introducing a technology not in the existing `Repo Fingerprint`. Use the `Repo Fingerprint`'s recorded versions when working with the existing stack.
- **Latest Preferred:** Generally prefer the latest stable version of libraries and tools to ensure access to modern features, bug fixes, and security patches.
- **Stable Only:** Use stable releases, never alpha/beta unless explicitly required
- **LTS for Runtimes:** Prefer Long Term Support versions for Node.js and .NET
- **Security Updates:** Always use versions that receive security updates
- **Breaking Changes:** Be cautious with major version upgrades

## Technology Stacks

### Full-Stack JavaScript (Lightweight)

- **Runtime:** Node.js (LTS)
- **Backend:** Fastify
- **Frontend:** SvelteKit
- **UI:** knadh/oat or Tailwind CSS + Skeleton UI + Lucide icons
- **Database:** SQLite + Drizzle ORM (or PostgreSQL for scale)
- **Build:** Vite
- **Testing:** See [Testing Tech Preferences]({{WORKSPACE}}/{{MAESTRO_CONFIG}}/references/testing-tech-preferences.md)

### Full-Stack JavaScript (Full-Featured)

- **Runtime:** Node.js (LTS)
- **Backend:** Fastify or Express.js
- **Frontend:** SvelteKit or Next.js with App Router (when SSR needed)
- **UI:** knadh/oat or Tailwind CSS + shadcn/ui + Lucide icons
- **Database:** PostgreSQL + Prisma
- **Build:** Vite
- **Testing:** See [Testing Tech Preferences]({{WORKSPACE}}/{{MAESTRO_CONFIG}}/references/testing-tech-preferences.md)

### Python Web (Lightweight)

- **Runtime:** Python (3.x)
- **Backend:** FastAPI
- **Database:** SQLite + SQLAlchemy (or PostgreSQL for scale)
- **Dependency Management:** Poetry
- **Testing:** See [Testing Tech Preferences]({{WORKSPACE}}/{{MAESTRO_CONFIG}}/references/testing-tech-preferences.md)

### .NET

- **Runtime:** .NET (LTS)
- **Backend:** ASP.NET Core
- **Database:** PostgreSQL + Entity Framework Core
- **Frontend:** Next.js or Blazor (if using .NET-only stack)
- **Testing:** See [Testing Tech Preferences]({{WORKSPACE}}/{{MAESTRO_CONFIG}}/references/testing-tech-preferences.md)
