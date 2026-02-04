# Common Infrastructure

This folder contains shared infrastructure used across all API versions.

## Structure

```
common/
├── config/          # Application configuration
├── database/        # Database setup, entities, migrations
├── decorators/      # Custom decorators (e.g., @CurrentUser)
├── filters/         # Exception filters
├── guards/          # Auth guards, role guards
├── interceptors/    # Request/response interceptors
├── pipes/           # Validation pipes, transformation pipes
├── services/        # Shared services (mail, otp, etc.)
└── utils/           # Helper functions, constants
```

## Key Components

### Database (`database/`)
- TypeORM configuration
- Entity definitions
- Migrations
- Data source setup

### Services (`services/`)
- **Mail**: Email sending functionality
- **OTP**: One-time password generation and validation
- Add other shared services here

### Guards (`guards/`)
- JWT authentication
- Admin authentication
- Role-based access control

### Filters (`filters/`)
- Global exception handling
- Error formatting
- WebSocket error handling

### Interceptors (`interceptors/`)
- Logging interceptor
- Response transformation
- Performance monitoring

## Best Practices

1. **Global by Design**: Use `@Global()` decorator for modules that should be available everywhere
2. **Reusability**: Only add truly shared code here
3. **Version-Agnostic**: Keep this layer independent of API versions
4. **Microservices Ready**: Design for potential extraction into shared packages

## Microservices Migration

When moving to microservices, this folder can become:
- Shared npm package: `@omlapay/common`
- Git submodule: Referenced by all services
- Monorepo package: Using tools like Nx or Turborepo
