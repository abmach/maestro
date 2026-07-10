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

## ⚠️ Important: Always Check Online

When selecting testing technologies, always search online for the current latest stable versions. Use web search to verify current versions before making technology choices.

## Preferences

### Unit Testing Frameworks

- **JavaScript/TypeScript:** Vitest (preferred - free, lightweight, fast) or Jest
  - Vitest: Native ESM support, faster execution, better TypeScript support, minimal dependencies
  - Jest: Widely adopted, extensive ecosystem, good for legacy projects (heavier alternative)
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
  - Fast execution and minimal resource usage
- **Cypress:** JavaScript-focused, developer-friendly (free, but heavier)
  - Good for teams with strong JavaScript background
  - Real-time reload and debugging
  - Note: Heavier than Playwright, use only for specific team preferences
- **Selenium:** Legacy support, widely adopted (free, but complex)
  - Use only when maintaining existing Selenium test suites
  - Requires more setup and maintenance overhead

**Path Conventions:**
- **{name} placeholder**: Replaced with test-specific screenshot names
- **Framework flexibility**: The `critique` skill accepts screenshot paths as input, making it framework-agnostic
- **Consistency**: Projects can choose to follow these conventions or use custom paths
- **Recommended structure**: `tests/screenshots/baselines/`, `tests/screenshots/actuals/`, `tests/screenshots/diffs/`

#### Playwright Configuration

When initializing or configuring Playwright (`playwright.config.ts`), use this recommended configuration:

```typescript
import { defineConfig } from '@playwright/test';

export default defineConfig({
  // Test artifacts output directory (Playwright default)
  outputDir: 'test-results',

  // Structured reporting for Maestro integration
  reporter: ['json', { outputFile: './test-results/summary.json' }],

  // Screenshot configuration for debugging (temporary, git-ignored)
  screenshot: 'only-on-failure', // Captures screenshots on test failure for debugging

  // Disable heavy features for performance
  video: 'off', // Video capture adds significant overhead
  trace: 'off', // Trace capture adds significant overhead

  // Visual regression snapshot configuration
  // Used by expect(page).toHaveScreenshot() calls in E2E tests
  expect: {
    snapshotPath: 'tests/screenshots/baselines',
  },

  // Other project-specific Playwright configuration...
})
```

**Note:** Ensure the `test-results/` directory is added to `.gitignore` to avoid committing runtime test outputs. Visual regression baselines in `tests/screenshots/baselines/` SHOULD be committed to git.

#### Cypress Configuration

When configuring Cypress (`cypress.config.js`), consider these settings for Maestro workflow compatibility:

**Screenshot Path Configuration:**

To configure Cypress to use a Playwright-like structure for consistency:

```javascript
export default defineConfig({
  e2e: {
    screenshotsFolder: 'tests/screenshots',
    // Other Cypress configuration...
  }
})
```

This allows Cypress projects to use the same screenshot directory structure as Playwright for consistency across projects.

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

- **JavaScript/TypeScript:** Vitest or Jest (framework-integrated)
- **Python:** pytest
- **.NET:** dotnet test
- **Rust:** cargo test
- **Go:** go test

### Visual Regression Testing

- **Playwright:** Screenshot comparison with pixelmatch (free, built-in, lightweight)
- **Percy:** Cloud-based visual testing platform (commercial, paid)
- **Chromatic:** Component-focused visual testing (commercial, free tier available)
- **Note:** Strongly prefer Playwright's built-in screenshot comparison for simplicity, cost-effectiveness, and lightweight operation

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
- **Visual Regression:** Playwright screenshot comparison
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

**Free and Lightweight Priority:** When deviating to commercial or heavier tools, explicitly justify why the free and lightweight alternatives are insufficient. Document the specific features or requirements that necessitate the deviation.

When deviating, document the reason in the ADR or project documentation.

## Version Strategy

- **Always Verify Online:** Before selecting any version, search online for the current latest stable release
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
- **Parallel Execution:** Configure tests to run in parallel when possible
- **Selective Testing:** Run only affected tests during development
- **CI Integration:** Ensure tests run reliably in CI environments

### Test Maintenance

- **Refactoring:** Refactor tests alongside production code
- **Flaky Tests:** Identify and fix flaky tests immediately
- **Test Coverage:** Monitor coverage but avoid targeting arbitrary percentages
- **Documentation:** Document complex test scenarios and setup
