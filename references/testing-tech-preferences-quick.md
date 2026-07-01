# Testing Tech Preferences (Quick Spec)

> Compact framework/tool reference. See `{{workspace_dir}}/.agents/references/testing-tech-preferences.md` for full spec with config templates and best practices.

## Unit Testing Frameworks

| Language | Preferred | Alternative |
| -------- | --------- | ----------- |
| JS/TS | **Vitest** (free, lightweight, fast, native ESM) | Jest (legacy projects) |
| Python | **pytest** | — |
| .NET | **xUnit** | — |
| Rust | built-in | — |
| Go | built-in | — |

## E2E Testing Frameworks

| Framework | Notes |
| --------- | ----- |
| **Playwright** (preferred) | Cross-browser, TypeScript support, visual regression, lightweight |
| **Cypress** | JS-focused, developer-friendly, heavier |
| **Selenium** | Legacy only, for existing suites |

## Test Runner Commands (Common)

| Framework | Command |
| --------- | ------- |
| Vitest | `yarn test` |
| Jest | `yarn test` |
| pytest | `python -m pytest` |
| xUnit | `dotnet test` |

## Screenshot Path Conventions

- Baselines: `tests/screenshots/baselines/`
- Actuals: `tests/screenshots/actuals/`
- Diffs: `tests/screenshots/diffs/`

## Other Testing Tools

- **Test Doubles:** Vitest (built-in), pytest (pytest-mock), .NET (Moq/NSubstitute)
- **Code Coverage:** Vitest (built-in c8), pytest (pytest-cov), .NET (coverlet)
- **Visual Regression:** Playwright (built-in snapshot)
- **Performance Testing:** k6, Benchmark.js (JS/TS); pytest-benchmark (Python)
- **API Testing:** Vitest (supertest), pytest (httpx), .NET (WebApplicationFactory)
- **Accessibility Testing:** axe-core

## Path Conventions

- **Unit tests:** Co-locate with source following the project's existing convention (e.g., `src/auth/jwt.test.ts`, `test_auth.py`)
- **E2E tests:** Flat in root `tests/` (e.g., `tests/auth.spec.ts`) — no subdirectories
- `{name}` placeholder: replaced with test-specific screenshot names
- `critique` skill accepts screenshot paths as input (framework-agnostic)
- `test-results/` directory should be in `.gitignore`

## Version Strategy

- **Always verify online** for current latest stable versions
- **Latest preferred** for libraries/tools
- **Stable only** — never alpha/beta
- **LTS** for runtimes (Node.js, .NET)
