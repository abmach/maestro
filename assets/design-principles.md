# Design Principles

Design principles and patterns for creating maintainable, testable software architecture.

## Purpose

The design principles serve as the single source of truth for:
- **Module Design** - Deep module principles for clean architecture
- **Interface Design** - Patterns for testable, maintainable interfaces
- **Dependency Patterns** - Dependency injection and system boundary design
- **Refactoring Strategy** - Guidelines for improving code structure

## When to Reference

Skills and agents should consult these principles when:
- Designing new modules or components
- Creating interfaces between components
- Deciding on dependency injection patterns
- Planning refactoring work
- Evaluating code quality and structure

## Integration with Other Assets

These design principles work alongside:
- **[Repo Fingerprint]({{workspace_dir}}/.devin/assets/repo-fingerprint.md)** - Primary reference for actual technology stack in use - design patterns should align with current frameworks, databases, and tools
- **[Tech Preferences]({{workspace_dir}}/.devin/assets/tech-preferences.md)** - Secondary reference for preferred technologies when making new choices
- **[ADRs]({{workspace_dir}}/.devin/assets/adrs.md)** - Document significant architectural decisions that deviate from these principles
- **[Contexts]({{workspace_dir}}/.devin/assets/contexts.md)** - Use domain language when designing interfaces and modules

## Core Principles

### Deep Modules

From "A Philosophy of Software Design":

**Deep module** = small interface + lots of implementation

```
┌─────────────────────┐
│   Small Interface   │  ← Few methods, simple params
├─────────────────────┤
│                     │
│                     │
│  Deep Implementation│  ← Complex logic hidden
│                     │
│                     │
└─────────────────────┘
```

**Shallow module** = large interface + little implementation (avoid)

```
┌─────────────────────────────────┐
│       Large Interface           │  ← Many methods, complex params
├─────────────────────────────────┤
│  Thin Implementation            │  ← Just passes through
└─────────────────────────────────┘
```

When designing interfaces, ask:

- Can I reduce the number of methods?
- Can I simplify the parameters?
- Can I hide more complexity inside?

### Interface Design for Testability

Good interfaces make testing natural:

1. **Accept dependencies, don't create them**

   ```typescript
   // Testable
   function processOrder(order, paymentGateway) {}

   // Hard to test
   function processOrder(order) {
     const gateway = new StripeGateway();
   }
   ```

2. **Return results, don't produce side effects**

   ```typescript
   // Testable
   function calculateDiscount(cart): Discount {}

   // Hard to test
   function applyDiscount(cart): void {
     cart.total -= discount;
   }
   ```

3. **Small surface area**
   - Fewer methods = fewer tests needed
   - Fewer params = simpler test setup

### Dependency Injection & System Boundaries

**Mock at system boundaries only:**

- External APIs (payment, email, etc.)
- Databases (sometimes - prefer test DB)
- Time/randomness
- File system (sometimes)

**Don't mock:**

- Your own classes/modules
- Internal collaborators
- Anything you control

#### Designing for Dependency Injection

At system boundaries, design interfaces that are easy to mock:

**1. Use dependency injection**

Pass external dependencies in rather than creating them internally:

```typescript
// Easy to mock
function processPayment(order, paymentClient) {
  return paymentClient.charge(order.total);
}

// Hard to mock
function processPayment(order) {
  const client = new StripeClient(process.env.STRIPE_KEY);
  return client.charge(order.total);
}
```

**2. Prefer SDK-style interfaces over generic fetchers**

Create specific functions for each external operation instead of one generic function with conditional logic:

```typescript
// GOOD: Each function is independently mockable
const api = {
  getUser: (id) => fetch(`/users/${id}`),
  getOrders: (userId) => fetch(`/users/${userId}/orders`),
  createOrder: (data) => fetch('/orders', { method: 'POST', body: data }),
};

// BAD: Mocking requires conditional logic inside the mock
const api = {
  fetch: (endpoint, options) => fetch(endpoint, options),
};
```

The SDK approach means:
- Each mock returns one specific shape
- No conditional logic in test setup
- Easier to see which endpoints a test exercises
- Type safety per endpoint

### Refactoring Candidates

After development cycles, look for:

- **Duplication** → Extract function/class
- **Long methods** → Break into private helpers (keep tests on public interface)
- **Shallow modules** → Combine or deepen
- **Feature envy** → Move logic to where data lives
- **Primitive obsession** → Introduce value objects
- **Existing code** the new code reveals as problematic

## Application Guidelines

### When Applying These Principles

1. **Design Phase** - Apply deep module and interface design principles when planning new components
2. **Implementation** - Use dependency injection patterns when integrating external services
3. **Refactoring** - Use refactoring candidates checklist during code improvement cycles
4. **Code Review** - Evaluate code against these principles during review processes

### Trade-offs

These principles should be applied pragmatically:
- Deep modules may require more upfront design
- Dependency injection adds complexity to simple cases
- Over-refactoring can waste time on code that works fine
- Balance principles with project timeline and constraints
