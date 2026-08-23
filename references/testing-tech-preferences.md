# Testing Technology Preferences

> Preferred testing frameworks, libraries, and tools by language, with config templates and best practices.

## ⚡ Priority: Free and Lightweight

**Free and lightweight frameworks are prioritized** over commercial or heavy alternatives. When choosing testing tools, prefer:
- **Open source** with active communities
- **Minimal dependencies** and small bundle sizes
- **Fast execution** and low resource requirements
- **No licensing costs** or restrictions
- **Simple setup** and configuration

Commercial tools should only be considered when they provide essential functionality not available in free alternatives.

## File Location and Naming

- **Directory:** None. This file is just for reference, it's not part of the workspace.

## ⚠️ When to Check Online

Use web search to confirm current versions **only when selecting a NEW testing technology** to introduce to the project — i.e., when no `Repo Fingerprint` exists yet, or when introducing a testing framework/library not already recorded in the existing `Repo Fingerprint`. The `Repo Fingerprint`'s recorded versions are authoritative for the existing stack; do not re-search them.

## Artifact Path Contract

Binding locations (see also `conventions.md`):

| Content | Path | Committed |
| ------- | ---- | --------- |
| E2E/integration test specs | `tests/` (flat) | yes |
| Visual regression baselines | `tests/screenshots/baselines/` | yes |
| Runtime artifacts (actual/diff screenshots, logs, traces) | `test-results/` | no — gitignore |

Configure the framework's baseline path explicitly (Playwright: top-level `snapshotPath`). Downstream consumers use only paths reported by `audition`'s result summary — never assumed locations.

## Preferences

### Unit Testing Frameworks

- **JavaScript/TypeScript:** Vitest (preferred - free, lightweight, fast) or Jest
  - Vitest: Native ESM support, faster execution, better TypeScript support, minimal dependencies
  - Jest: Widely adopted, extensive ecosystem, good for legacy projects (heavier alternative)
- **Node.js built-in (node:test):** Zero-dependency runner for small services and CLIs — use when adding a test framework would outweigh the code under test; pairs with `node:assert`
- **Python:** pytest
  - Native support for fixtures, parametrized tests, async testing
  - Extensive plugin ecosystem
- **.NET:** xUnit
  - Modern, actively maintained, good async/await support
- **Rust:** built-in test framework
- **Go:** built-in testing package

### E2E Testing Frameworks

- **Playwright:** Cross-browser, modern, reliable (free, lightweight)
  - Excellent TypeScript support
  - Built-in waiting and retry mechanisms
  - Visual regression testing capabilities
  - Multi-browser support (Chromium, Firefox, WebKit)
- **Cypress:** JavaScript-focused, developer-friendly (free, but heavier)
  - Good for teams with strong JavaScript background
  - Real-time reload and debugging
  - Note: Heavier than Playwright, use only for specific team preferences
- **Selenium:** Legacy support, widely adopted (free, but complex)
  - Use only when maintaining existing Selenium test suites

#### Playwright Configuration

When initializing or configuring Playwright (`playwright.config.ts`), use this canonical configuration. Option placement matters — browser-context features live under `use:`, and the snapshot baseline path is a TOP-LEVEL option:

```typescript
import { defineConfig } from '@playwright/test';

export default defineConfig({
  // Test artifacts output directory (runtime artifacts: actuals, diffs, logs — gitignored)
  outputDir: 'test-results',

  // Structured reporting for Maestro integration (note the nested [reporter, options] form)
  reporter: [['json', { outputFile: 'test-results/summary.json' }]],

  // Visual regression baselines — TOP-LEVEL option, committed to git.
  // expect(page).toHaveScreenshot() baselines resolve against this directory.
  snapshotPath: 'tests/screenshots/baselines',

  // Browser context features belong under use:
  use: {
    screenshot: 'only-on-failure', // failure screenshots for debugging
    video: 'off',                   // video capture adds significant overhead
    trace: 'off',                   // trace capture adds significant overhead
  },

  // Screenshot comparison tuning lives under expect.toHaveScreenshot, e.g.:
  // expect: { toHaveScreenshot: { maxDiffPixels: 100 } }

  // Other project-specific Playwright configuration...
})
```

**Note:** Ensure `test-results/` is added to `.gitignore` so runtime artifacts stay out of git. Baselines under `tests/screenshots/baselines/` SHOULD be committed.

#### Cypress Configuration

When configuring Cypress (`cypress.config.js`), align screenshot output with the artifact contract:

```javascript
export default defineConfig({
  e2e: {
    screenshotsFolder: 'test-results/screenshots',
    // Other Cypress configuration...
  }
})
```

Cypress manages its own baseline comparison differently from Playwright; prefer Playwright when visual regression is a first-class requirement of the Plan.

### Test Doubles and Mocking

- **JavaScript/TypeScript:**
  - vi.mock (Vitest built-in)
  - jest.mock (Jest built-in)
  - MSW (Mock Service Worker) for API mocking
- **Python:**
  - unittest.mock (built-in)
  - pytest-mock for pytest integration
- **.NET:**
  - Moq (popular mocking framework)
  - NSubstitute (alternative mocking framework)

### Code Coverage

- **JavaScript/TypeScript:** c8 (Vitest native) or Istanbul (Jest)
- **Python:** pytest-cov
- **.NET:** Coverlet
- **Rust:** tarpaulin
- **Go:** built-in coverage tool

### Test Runners and Execution

- **JavaScript/TypeScript:** Vitest or Jest (framework-integrated); Playwright CLI for E2E
- **Python:** pytest
- **.NET:** dotnet test
- **Rust:** cargo test
- **Go:** go test

### Visual Regression Testing

- **Playwright:** Built-in screenshot comparison via `expect(page).toHaveScreenshot()` (free, lightweight)
- **Percy / Chromatic:** Cloud-based visual testing platforms (commercial)
- **Note:** Strongly prefer Playwright's built-in screenshot comparison for simplicity and cost

### Performance Testing

- **k6:** Modern, scriptable performance testing (free, lightweight, developer-friendly)
- **Locust:** Python-based, distributed load testing (free, but heavier setup)
- **Apache Bench:** Simple HTTP benchmarking (free, very lightweight, limited features)
- **Note:** Strongly prefer k6 for modern, developer-friendly, lightweight performance testing

### API Testing

- **JavaScript/TypeScript:** Supertest (HTTP assertions)
- **Python:** requests + pytest
- **.NET:** WebApplicationFactory (ASP.NET Core integration testing)

### Accessibility Testing

- **axe-core:** Deque accessibility testing engine
- **Playwright:** Built-in accessibility tree inspection
- **Lighthouse:** Chrome DevTools integration
- **Note:** Integrate axe-core with Playwright for automated accessibility testing

## Language-Specific Testing Stacks

### JavaScript/TypeScript Stack

- **Unit Testing:** Vitest
- **E2E Testing:** Playwright
- **Mocking:** vi.mock (Vitest) or MSW for API mocking
- **Coverage:** c8 (Vitest native)
- **Visual Regression:** Playwright screenshot comparison → `tests/screenshots/baselines/`
- **Performance:** k6
- **API Testing:** Supertest

### Python Stack

- **Unit Testing:** pytest
- **E2E Testing:** Playwright with pytest-playwright plugin
- **Mocking:** pytest-mock or unittest.mock
- **Coverage:** pytest-cov
- **API Testing:** requests + pytest

### .NET Stack

- **Unit Testing:** xUnit
- **E2E Testing:** Playwright with .NET bindings
- **Mocking:** Moq or NSubstitute
- **Coverage:** Coverlet
- **API Testing:** WebApplicationFactory

## Deviation Guidelines

Deviations from these testing preferences are acceptable when:
1. **Workspace Requirements:** The existing workspace uses different testing frameworks
2. **Specific Needs:** A project has unique testing requirements that necessitate different choices
3. **Legacy Code:** Maintaining existing test suites requires specific tools
4. **Team Expertise:** The development team has established expertise with different tools
5. **Integration Requirements:** Specific tool integrations require particular testing frameworks
6. **Commercial Justification:** A commercial tool provides essential functionality not available in free alternatives

When deviating, document the reason in an ADR or project documentation.

## Version Strategy

- **Verify Online for New Selections:** Search online for the current latest stable release when introducing a testing technology not in the existing `Repo Fingerprint`. Use the recorded versions for the existing stack.
- **Stable Only:** Use stable releases, never alpha/beta unless explicitly required
- **Security Updates:** Always use versions that receive security updates
- **Breaking Changes:** Be cautious with major version upgrades in testing frameworks

## Best Practices

### Test Organization

- **Unit Tests:** Co-locate with source code following the project's existing convention (e.g., `src/auth/jwt.test.ts`, `test_auth.py`, `Auth.Tests.cs`)
- **E2E Tests:** Flat in the root `tests/` directory (e.g., `tests/auth.spec.ts`, `tests/login.spec.ts`) — do NOT nest in subdirectories
- **Test Files:** Use `.test.ts`, `.spec.ts`, or `test_*.py` naming conventions

### Test Data Management

- **Fixtures:** Use test fixtures for reusable test data
- **Factories:** Use factory patterns for complex object creation
- **Test Databases:** Use separate test databases or in-memory databases
- **Cleanup:** Ensure proper cleanup in test teardown

### Test Execution

- **Fast Feedback:** Run unit tests frequently during development
- **Invocation:** Prefer the package script (`npm test`) or bare runner form (`node --test`, `pytest`) over positional directory arguments — runners reject or mishandle those across versions (e.g., `node --test test/` fails on Node 26)
- **Parallel Execution:** Configure tests to run in parallel when possible
- **Selective Testing:** Run only affected tests during development
- **CI Integration:** Ensure tests run reliably in CI environments

### Test Maintenance
- **Refactoring:** Refactor tests alongside production code
- **Flaky Tests:** Identify and fix flaky tests immediately
- **Test Coverage:** Monitor coverage but avoid targeting arbitrary percentages
- **Documentation:** Document complex test scenarios and setup
