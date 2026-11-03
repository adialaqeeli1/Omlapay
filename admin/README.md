# Omlapay admin panel

The admin panel for the Omlapay team: users, support requests, fees, settings and notifications.
React, Vite, TanStack Router and Query, Tailwind.

The quickest way to run it is from the repository root: `./run.sh` (backend + admin) or
`./run.sh admin` (see the [main README](../README.md)).

## Run by hand

```bash
cp .env.example .env   # points at the backend, http://localhost:3000 by default
pnpm install
pnpm dev               # http://localhost:5173
```

The backend must be running. To log in you need an admin account: from the repository root run
`./run.sh create-admin <email> <password>`.

## Commands

| Command | What it does |
| --- | --- |
| `pnpm dev` | run with hot reload |
| `pnpm build` | production build into `dist/` |
| `pnpm preview` | serve the production build |
| `pnpm lint` / `pnpm typecheck` | checks (`pnpm codereview` runs both) |

## Settings

| Setting in `.env` | Meaning |
| --- | --- |
| `VITE_API_URL` | backend address, for example `http://localhost:3000` |
| `VITE_API_BASE_URL` | the same address with `/v1` at the end |

## Docker

`docker compose -f dev-docker-compose.yml up` runs the dev server in a container on port 5173.
`docker-compose.yml` and `Dockerfile` build the production image.
