# Tech Preferences

These are the preferred technologies, frameworks, libraries, and versions to use when creating new projects or making technology choices. These preferences guide agents and skills in their decisions, ensuring consistency across workspaces.

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

## ⚠️ Important: Always Check Online

When selecting technologies, always search online for the current latest stable versions. Use web search to verify current versions before making technology choices.

## Purpose

The tech preferences serve as a single source of truth for:
- **Technology Selection** - Preferred frameworks and libraries for new projects
- **Consistency** - Standardizing choices across different workspaces
- **Best Practices** - Industry-standard combinations that work well together

## Usage

When an agent or skill needs to:
- Choose a framework for a new project
- Select a library for a specific task
- Determine package manager or runtime
- Pick build tools

They should consult this file first and use the preferred options unless there's a compelling reason to deviate. For testing technology decisions, consult [Testing Tech Preferences]({{workspace_dir}}/.devin/assets/testing-tech-preferences.md).

## Integration with Other Assets

These technology preferences work alongside:
- **[Testing Tech Preferences]({{workspace_dir}}/.devin/assets/testing-tech-preferences.md)** - Detailed testing framework preferences and guidance
- **[Repo Fingerprint]({{workspace_dir}}/.devin/assets/repo-fingerprint.md)** - Current technology stack in use

The tech preferences provide general technology guidance, while testing-tech-preferences provides specialized testing guidance. When making testing technology decisions, consult testing-tech-preferences first.

## Preferences

### Package Managers

- **JavaScript/TypeScript:** yarn
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
- **Note:** Prefer Svelte for maximum lightweight and performance. Prefer SPA (Single Page Application) over SSR unless SEO or server-side features are required

### UI Libraries

- **Framework-Agnostic (Preferred):** knadh/oat - ultra-lightweight (~8KB), zero-dependency, semantic HTML/CSS/JS - use for maximum portability and minimal dependencies
- **CSS Framework:** Tailwind CSS - utility-first, modern, lightweight
- **Framework-Specific Component Libraries (use only when needed):**
  - React: shadcn/ui - component-based (copy-paste, no dependency bloat)
  - Vue: Headless UI (unstyled, lightweight) or Nuxt UI
  - Svelte: Skeleton UI (lightweight)
- **Icons:** Lucide (tree-shakeable, modern)
- **Note:** Prefer framework-agnostic UI (knadh/oat) over framework-specific components. Only use framework-specific libraries when framework features are required.

### Database

- **Relational:** SQLite (preferred for lightweight apps) or PostgreSQL (for production scale)
- **Document:** MongoDB
- **Key-Value:** Redis
- **Embedded:** SQLite - for local development/testing
- **Note:** SQLite is excellent for lightweight applications and can scale to significant workloads

### ORM/Database Tools

- **Node.js:** Drizzle ORM (preferred for lightweight and performance) or Prisma (for type safety)
- **Python:** SQLAlchemy with async support, or Django ORM
- **.NET:** Entity Framework Core
- **Note:** Drizzle ORM is significantly lighter and faster than Prisma for Node.js

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

- **Always Verify Online:** Before selecting any version, search online for the current latest stable release
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
- **Testing:** See [Testing Tech Preferences]({{workspace_dir}}/.devin/assets/testing-tech-preferences.md)

### Full-Stack JavaScript (Full-Featured)

- **Runtime:** Node.js (LTS)
- **Backend:** Fastify or Express.js
- **Frontend:** SvelteKit or Next.js with App Router (when SSR needed)
- **UI:** knadh/oat or Tailwind CSS + shadcn/ui + Lucide icons
- **Database:** PostgreSQL + Prisma
- **Build:** Vite
- **Testing:** See [Testing Tech Preferences]({{workspace_dir}}/.devin/assets/testing-tech-preferences.md)

### Python Web (Lightweight)

- **Runtime:** Python (3.x)
- **Backend:** FastAPI
- **Database:** SQLite + SQLAlchemy (or PostgreSQL for scale)
- **Dependency Management:** Poetry
- **Testing:** See [Testing Tech Preferences]({{workspace_dir}}/.devin/assets/testing-tech-preferences.md)

### .NET

- **Runtime:** .NET (LTS)
- **Backend:** ASP.NET Core
- **Database:** PostgreSQL + Entity Framework Core
- **Frontend:** Next.js or Blazor (if using .NET-only stack)
- **Testing:** See [Testing Tech Preferences]({{workspace_dir}}/.devin/assets/testing-tech-preferences.md)
