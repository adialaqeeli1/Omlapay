# API Layer

This folder contains all API versions of the application.

## Versioning Strategy

We use URI-based versioning with the following structure:
- `/api/v1/*` - Version 1 endpoints (current)
- `/api/v2/*` - Version 2 endpoints (future)

## Version Modules

### V1 Module (`api/v1/`)
Contains all current production endpoints:
- **User endpoints**: Auth, profile, settings
- **Admin endpoints**: Dashboard, user management, tickets
- **Core features**: Coins, notifications, home

### V2 Module (`api/v2/`)
Template for future API version. Add new modules here when:
- Breaking changes are needed
- Major feature overhauls
- New API contract requirements

## Adding a New Version

1. Create new version directory: `api/v3/`
2. Create version module: `api/v3/v3.module.ts`
3. Import in `app.module.ts`
4. Controllers will automatically be versioned via NestJS versioning

## Microservices Migration Path

When moving to microservices:
1. Each module in `v1/` can become its own microservice
2. Share `common/` infrastructure via npm packages or git submodules
3. Use `domain/` layer for shared business logic
4. Implement API gateway to route versioned requests

Example:
```
v1/auth/ → @omlapay/auth-service
v1/user/ → @omlapay/user-service
v1/coins/ → @omlapay/coins-service
```
