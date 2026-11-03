# Omlapay backend

The API for the Omlapay app and admin panel. NestJS, TypeORM, PostgreSQL.

The quickest way to run it is from the repository root: `./run.sh backend`
(see the [main README](../README.md)).

## Run by hand

```bash
cp .env.example .env   # then fill in the values, see the comments in the file
pnpm install
pnpm start:dev         # http://localhost:3000, API docs at /docs
```

You need a PostgreSQL database matching the `POSTGRES_*` settings. The backend creates and updates
the tables itself on start (migrations run automatically).

## Commands

| Command | What it does |
| --- | --- |
| `pnpm start:dev` | run with auto-reload |
| `pnpm build` then `pnpm start:prod` | production build and run |
| `pnpm test` / `pnpm test:e2e` | tests |
| `pnpm lint` | lint and fix |
| `pnpm migration:generate:dev src/common/database/migrations/<Name>` | create a migration from entity changes |
| `pnpm migration:run:dev` / `pnpm migration:revert:dev` | apply or undo migrations by hand |

## Settings

All settings are in `.env`; [`.env.example`](.env.example) lists and explains each one. The ones
under "Required to start" must be set. AWS S3 settings are also checked at start, so local runs use
placeholders (uploads then fail until real keys are added). The other integrations (email, SMS,
KYC, Binance) are only needed for the features that use them.

## Layout

- `src/api/` HTTP endpoints, grouped by version (`v1`) and feature, see [src/api/README.md](src/api/README.md)
- `src/domain/` business logic, see [src/domain/README.md](src/domain/README.md)
- `src/common/` shared modules: database, config, guards, outside services, see [src/common/README.md](src/common/README.md)
