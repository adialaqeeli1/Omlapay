# Domain Layer

This folder contains the core business logic of the application, organized in a domain-driven design (DDD) style.

## Structure

Each domain should have:
- **entity.ts**: Database entity/model definitions
- **repository.ts**: Data access layer (if using repository pattern)
- **logic.ts**: Core business logic and domain services

## Example Structure

```
domain/
├── users/
│   ├── user.entity.ts      (or reference from common/database/model)
│   ├── user.repository.ts  (optional custom repository)
│   └── user.logic.ts       (business logic)
├── orders/
│   ├── order.entity.ts
│   ├── order.repository.ts
│   └── order.logic.ts
└── payments/
    ├── payment.entity.ts
    ├── payment.repository.ts
    └── payment.logic.ts
```

## When to Use Domain Layer

The domain layer is **optional** but recommended when:
- You need to share business logic across multiple API versions
- You're planning to migrate to microservices
- You want to separate business logic from API/transport concerns
- You have complex business rules that shouldn't be in controllers or services

## Current Setup

For now, entities are located in `common/database/model/`.
You can gradually move complex business logic here as the application grows.
When migrating to microservices, this layer becomes the shared domain logic.
