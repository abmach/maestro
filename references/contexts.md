# Contexts

> Defines the ubiquitous language for bounded contexts—the shared vocabulary that eliminates ambiguity by establishing authoritative definitions for domain-specific terms.

## File Location and Naming

- **Directory:** `{{workspace_dir}}/knowledge/`
- **Filename:** `contexts.md`
- **Directory creation:** Create `{{workspace_dir}}/knowledge/` lazily when the first context is needed

## Structure

### Single File with Area Headers

All repositories use a single `contexts.md` file in the `{{workspace_dir}}/knowledge/` folder. For repositories with multiple bounded contexts, use area headers with folder references:

```markdown
# {Project Name} Context

{One or two sentence description of the overall project.}

## {Area Name} Context (`{folder/path/}`)

{Optional: Brief description of this area.}

### Language

**Term**:
A one or two sentence description of the term.
_Avoid_: Alternative term1, alternative term2

**Another Term**:
A one or two sentence description of the term.
_Avoid_: Alternative term1, alternative term2

## {Another Area} Context (`{another/folder/path/}`)

{Optional: Brief description of this area.}

### Language

**Term**:
A one or two sentence description of the term.
_Avoid_: Alternative term1, alternative term2

## Relationships

- **{Area Name} → {Another Area}**: Description of the relationship and communication pattern
- **{Another Area} → {Third Area}**: Description of the relationship and communication pattern
- **{Area Name} ↔ {Another Area}**: Description of bidirectional relationship or shared elements
```

## Writing Rules

### Be Opinionated

When multiple words exist for the same concept, pick the best one and list the alternatives under `_Avoid_`.

### Keep Definitions Tight

Limit definitions to one or two sentences maximum. Focus on defining what the concept **is**, not what it **does** or how it's implemented.

### Context-Specific Terms Only

Only include terms that are specific to this project's domain context. General programming concepts (timeouts, error types, utility patterns) do not belong.

### Group Terms Logically

Keep a flat list of terms under the Language section. Avoid subheadings unless you have many terms that clearly fall into distinct categories.

## Inference Strategy

1. If `{{workspace_dir}}/knowledge/contexts.md` exists, read it to understand the project's domain language
2. If multiple area contexts exist, the system infers which area the current topic relates to based on folder references
3. If the area is unclear, it will ask for clarification
4. If no `{{workspace_dir}}/knowledge/contexts.md` exists, create it lazily when the first term is resolved

## Example

```markdown
# E-Commerce Context

This project handles e-commerce operations including order management, customer accounts, and payment processing across multiple bounded contexts.

## Ordering Context (`src/ordering/`)

Handles customer order lifecycle from placement to fulfillment.

### Language

**Order**:
A customer's request to purchase products, including selected items and shipping information.
_Avoid_: Purchase, transaction, cart

**Invoice**:
A formal payment request sent to a customer after order fulfillment.
_Avoid_: Bill, payment request, receipt

**Customer**:
A registered person or organization that can place orders and manage account information.
_Avoid_: Client, buyer, user, account

## Billing Context (`src/billing/`)

Manages payment processing and financial transactions.

### Language

**Order**:
A request for payment sent to a customer after delivery.
_Avoid_: Bill, payment request

**Payment**:
Financial transaction for goods or services.
_Avoid_: Transaction, charge

**Credit Card**:
Payment method using card networks (Visa, Mastercard, etc.) with immediate authorization.
_Avoid_: Card payment, electronic payment

**Bank Transfer**:
Direct transfer from customer bank account to merchant account.
_Avoid_: Wire transfer, ACH, direct debit

## Relationships

- **Ordering → Billing**: Ordering emits `OrderPlaced` events; Billing consumes them to generate invoices
- **Billing → Ordering**: Billing emits `PaymentFailed` events; Ordering consumes them to update order status
- **Ordering ↔ Billing**: Shared types for `CustomerId` and `Money`
```
