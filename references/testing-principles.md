# Testing Principles

Testing philosophy and patterns for writing maintainable, reliable tests that verify behavior rather than implementation.

## Purpose

The testing principles serve as the single source of truth for:
- **Test Philosophy** - Core principles for behavior-driven testing
- **Test Design** - Patterns for writing good tests vs bad tests
- **Test Maintenance** - Guidelines for tests that survive refactoring
- **Integration Testing** - Approaches for testing through real interfaces
- **TDD Methodology** - Red-green-refactor workflow and test-driven development practices

## When to Reference

Skills and agents should consult these principles when:
- Writing new tests or test frameworks
- Evaluating existing test quality
- Designing test strategies for features
- Debugging test failures
- Planning test coverage
- Applying TDD methodology for feature development
- Designing interfaces for testability

## Integration with Other References

These testing principles work alongside:
- **[Repo Fingerprint]({{workspace_dir}}/.agents/references/repo-fingerprint.md)** - Primary reference for actual testing frameworks and tools in use - test patterns should align with current testing setup
- **[Design Principles]({{workspace_dir}}/.agents/references/design-principles.md)** - Apply design patterns that make testing natural
- **[Tech Preferences]({{workspace_dir}}/.agents/references/tech-preferences.md)** - Secondary reference for preferred testing tools when making new choices
- **[Contexts]({{workspace_dir}}/.agents/references/contexts.md)** - Use domain language in test names and assertions

## Core Philosophy

**Test behavior, not implementation.**

Tests should verify what the system does, not how it does it. Good tests are integration-style: they exercise real code paths through public APIs. They describe what the system does, not how it does it.

A good test reads like a specification - "user can checkout with valid cart" tells you exactly what capability exists. These tests survive refactors because they don't care about internal structure.

Bad tests are coupled to implementation. They mock internal collaborators, test private methods, or verify through external means (like querying a database directly instead of using the interface). The warning sign: your test breaks when you refactor, but behavior hasn't changed.

## Good Tests

**Integration-style**: Test through real interfaces, not mocks of internal parts.

```typescript
// GOOD: Tests observable behavior
test("user can checkout with valid cart", async () => {
  const cart = createCart();
  cart.add(product);
  const result = await checkout(cart, paymentMethod);
  expect(result.status).toBe("confirmed");
});
```

**Characteristics:**

- Tests behavior users/callers care about
- Uses public API only
- Survives internal refactors
- Describes WHAT, not HOW
- One logical assertion per test

## Bad Tests

**Implementation-detail tests**: Coupled to internal structure.

```typescript
// BAD: Tests implementation details
test("checkout calls paymentService.process", async () => {
  const mockPayment = jest.mock(paymentService);
  await checkout(cart, payment);
  expect(mockPayment.process).toHaveBeenCalledWith(cart.total);
});
```

**Red flags:**

- Mocking internal collaborators
- Testing private methods
- Asserting on call counts/order
- Test breaks when refactoring without behavior change
- Test name describes HOW not WHAT
- Verifying through external means instead of interface

```typescript
// BAD: Bypasses interface to verify
test("createUser saves to database", async () => {
  await createUser({ name: "Alice" });
  const row = await db.query("SELECT * FROM users WHERE name = ?", ["Alice"]);
  expect(row).toBeDefined();
});

// GOOD: Verifies through interface
test("createUser makes user retrievable", async () => {
  const user = await createUser({ name: "Alice" });
  const retrieved = await getUser(user.id);
  expect(retrieved.name).toBe("Alice");
});
```

## Test Design Guidelines

### Test Naming

Test names should describe the behavior being tested, not the implementation:

- **Good**: "user can checkout with valid cart"
- **Bad**: "checkout calls paymentService.process"

### Test Structure

Each test should:
1. Set up the minimal state needed
2. Execute the behavior being tested
3. Assert on the observable outcome
4. Avoid testing multiple behaviors in one test

### Test Isolation

Tests should be independent:
- Each test should be able to run alone
- Tests shouldn't depend on execution order
- Clean up state after each test

## Integration with Design Principles

These testing principles work best when combined with the design principles:

- **Interface Design** - Good interfaces make testing natural
- **Dependency Injection** - Makes external dependencies easy to mock
- **Deep Modules** - Small interfaces mean fewer tests needed

## When to Apply Different Test Approaches

### Unit Tests

- Test individual functions/methods in isolation
- Use for business logic, algorithms, utility functions
- Fast execution, focused scope

### Integration Tests

- Test through real interfaces between components
- Use for component interactions, API contracts
- Slower but more realistic

### End-to-End Tests

- Test complete user workflows
- Use for critical paths, user-facing features
- Slowest but highest confidence

## Anti-Pattern: Horizontal Slicing

**DO NOT write all tests first, then all implementation.** This is "horizontal slicing" - treating RED as "write all tests" and GREEN as "write all code."

This produces **crap tests**:

- Tests written in bulk test imagined behavior, not actual behavior
- You end up testing the shape of things (data structures, function signatures) rather than user-facing behavior
- Tests become insensitive to real changes - they pass when behavior breaks, fail when behavior is fine
- You outrun your headlights, committing to test structure before understanding the implementation

**Correct approach**: Vertical slices via tracer bullets. One test → one implementation → repeat. Each test responds to what you learned from the previous cycle.

```text
WRONG (horizontal):
  RED:   test1, test2, test3, test4, test5
  GREEN: impl1, impl2, impl3, impl4, impl5

RIGHT (vertical):
  RED→GREEN: test1→impl1
  RED→GREEN: test2→impl2
  RED→GREEN: test3→impl3
  ...
```

## TDD Methodology

Test-driven development is a workflow that uses the red-green-refactor cycle to drive development through testing.

### When to Use TDD

Use TDD when:
- Building new features with complex business logic
- Fixing bugs where tests can prevent regression
- Designing interfaces that need to be testable
- Working on code that lacks test coverage
- User explicitly requests test-first development

### Red-Green-Refactor Workflow

#### 1. Planning Phase

When exploring the codebase, use the project's domain glossary so that test names and interface vocabulary match the project's language, and respect ADRs in the area you're touching.

Before writing any code:

- [ ] Confirm with user what interface changes are needed
- [ ] Confirm with user which behaviors to test (prioritize)
- [ ] Identify opportunities for [deep modules]({{workspace_dir}}/.agents/references/design-principles.md#deep-modules) (small interface, deep implementation)
- [ ] Design interfaces for [testability]({{workspace_dir}}/.agents/references/design-principles.md#interface-design-for-testability)
- [ ] List the behaviors to test (not implementation steps)
- [ ] Get user approval on the plan

Ask: "What should the public interface look like? Which behaviors are most important to test?"

**You can't test everything.** Confirm with the user exactly which behaviors matter most. Focus testing effort on critical paths and complex logic, not every possible edge case.

#### 2. Tracer Bullet

Write ONE test that confirms ONE thing about the system:

```text
RED:   Write test for first behavior → test fails
GREEN: Write minimal code to pass → test passes
```

This is your tracer bullet - proves the path works end-to-end.

#### 3. Incremental Loop

For each remaining behavior:

```text
RED:   Write next test → fails
GREEN: Minimal code to pass → passes
```

Rules:

- One test at a time
- Only enough code to pass current test
- Don't anticipate future tests
- Keep tests focused on observable behavior

#### 4. Refactor Phase

After all tests pass, look for [refactor candidates]({{workspace_dir}}/.agents/references/design-principles.md#refactoring-candidates):

- [ ] Extract duplication
- [ ] Deepen modules (move complexity behind simple interfaces)
- [ ] Apply SOLID principles where natural
- [ ] Consider what new code reveals about existing code
- [ ] Run tests after each refactor step

**Never refactor while RED.** Get to GREEN first.

### TDD Checklist Per Cycle

```text
[ ] Test describes behavior, not implementation
[ ] Test uses public interface only
[ ] Test would survive internal refactor
[ ] Code is minimal for this test
[ ] No speculative features added
```

### TDD Success Indicators

You're doing TDD well when:
- Tests read like specifications of desired behavior
- Each test focuses on one specific behavior
- You rarely need to debug - tests tell you what's broken
- Refactoring is safe because tests protect against regressions
- The codebase has high test coverage without being brittle

## Test Maintenance

### Keeping Tests Maintainable

- Tests should be as simple as possible
- Avoid complex test setup/teardown
- Use test helpers to reduce duplication
- Review tests during refactoring

### When Tests Fail

If a test fails during refactoring:
- Check if behavior actually changed
- If behavior didn't change, the test was coupled to implementation
- Update the test to focus on behavior, not implementation
- Consider if the refactoring revealed a missing test
