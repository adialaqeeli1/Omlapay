# Omlapay

Omlapay is a crypto payments platform. This repository holds all three parts:

| Folder | What it is | Built with |
| --- | --- | --- |
| [`backend/`](backend/README.md) | The API used by the app and the admin panel | NestJS, PostgreSQL |
| [`admin/`](admin/README.md) | Admin panel for the Omlapay team | React, Vite, Tailwind |
| [`mobile-app/`](mobile-app/README.md) | The Omlapay app for Android and iOS | Flutter |

## Run it with one command

```bash
./run.sh
```

This starts the backend and the admin panel on your computer:

- Admin panel: <http://localhost:5173>
- Backend API: <http://localhost:3000>
- API docs: <http://localhost:3000/docs> (username and password are in `backend/.env`)

Press `Ctrl+C` to stop everything.

The first run takes a few minutes. It:

1. scans the code for malware (see [Security](#security))
2. checks that Node.js, pnpm and Docker are installed
3. creates `backend/.env` and `admin/.env` from the examples and generates the secret keys
4. starts a PostgreSQL database in Docker (port 5433, data is kept between runs)
5. installs the packages for the backend and the admin panel
6. starts both; the backend creates the database tables on its first start

### Log in to the admin panel

There is no admin account at the start. Create one (with the backend running, in a second terminal):

```bash
./run.sh create-admin you@example.com 'A-Strong-Password-1!'
```

Then open <http://localhost:5173>, choose **Email**, enter the email, click **Send OTP**, and log in
with the password and the 6-digit code. On a local run no email service is set up, so the code is
printed in the terminal instead, in a `[backend]` line: "Your Omlapay verification code is: ...".
It is valid for 60 seconds.

## What you need installed

| Tool | Version | Needed for |
| --- | --- | --- |
| [Node.js](https://nodejs.org) | 20 or 22 (LTS) | backend, admin |
| [pnpm](https://pnpm.io/installation) | 10 or newer (`npm install -g pnpm`) | backend, admin |
| [Docker Desktop](https://www.docker.com/products/docker-desktop/) | any recent version, running | the local database |
| [Flutter](https://docs.flutter.dev/get-started/install) | 3.44 (see `mobile-app/.flutter-version`) | mobile app only |
| Git | any | getting the code, malware scan |

Windows: run the commands in **Git Bash** (comes with Git for Windows) or in **WSL**.

Check everything at once without starting anything:

```bash
./run.sh check
```

## All commands

| Command | What it does |
| --- | --- |
| `./run.sh` | backend + admin panel + local database |
| `./run.sh backend` | backend + local database only |
| `./run.sh backend --no-db` | backend only, using the database set in `backend/.env` |
| `./run.sh admin` | admin panel only (expects the backend to be running) |
| `./run.sh mobile` | the Flutter app on a connected phone or emulator (`--release` for a release build) |
| `./run.sh create-admin <email> <password>` | create an admin login for the local admin panel |
| `./run.sh check` | check the tools and scan for malware, start nothing |
| `./run.sh stop-db` | stop the local database (data is kept) |
| `./run.sh help` | show this list |

## Settings

### Backend: `backend/.env`

Created on the first run from [`backend/.env.example`](backend/.env.example), which explains
every setting. The run script fills in the secrets for you. You only need to edit this file to
turn on outside services:

| To make this work | Fill in |
| --- | --- |
| File uploads (support attachments, KYC documents) | `AWS_*`, `S3_*` |
| Emails with login codes | `MAILGUN_*` or `TAQNYAT_*` |
| SMS | `TAQNYAT_*` |
| KYC checks | `SUMSUB_*`, `BINANCE_KYC_*` |
| Trading, wallets, deposits, withdrawals | `BINANCE_*` |

Without them the backend still starts and the admin panel works. The features above return errors
until their keys are added. Restart `./run.sh` after editing the file.

Keep `FIELD_ENCRYPTION_KEY` safe: data saved with one key cannot be read with another.

### Admin panel: `admin/.env`

Created from [`admin/.env.example`](admin/.env.example) and pointed at the local backend. Change
the two URLs to use a different backend.

### Mobile app

The app calls the API set in `mobile-app/lib/core/constants/endpoints.dart` (`domain`, currently
the live server `api.omlapay.xyz`). To use your local backend, set `protocol` to `http` and
`domain` to your computer's address and port, for example `192.168.1.20:3000` on a real phone
or `10.0.2.2:3000` on the Android emulator. More detail in [`mobile-app/README.md`](mobile-app/README.md).

## Running a part by hand

If you prefer not to use `run.sh`:

```bash
# database
docker run -d --name omlapay-postgres -p 127.0.0.1:5433:5432 \
  -e POSTGRES_DB=omlapay -e POSTGRES_USER=omlapay -e POSTGRES_PASSWORD=omlapay \
  -v omlapay-pgdata:/var/lib/postgresql/data postgres:15-alpine

# backend (fill in backend/.env first, see backend/.env.example)
cd backend && pnpm install && pnpm start:dev

# admin panel (in another terminal)
cd admin && cp .env.example .env && pnpm install && pnpm dev

# mobile app
cd mobile-app && ./scripts/run.sh
```

## Problems

| You see | Do this |
| --- | --- |
| `Docker is installed but not running` | Open Docker Desktop, wait until it says it is running, then run again |
| `Could not start Postgres. Is port 5433 free?` | Change `POSTGRES_PORT` in `backend/.env` to a free port |
| `Backend did not answer on port 3000` | Read the `[backend]` lines; usually a wrong value in `backend/.env` |
| `Port 5173 is in use` | Stop the other program using it, or close an older `./run.sh` |
| Admin panel says it cannot reach the server | Check the backend is running and `admin/.env` points at it |
| `The scan failed. Do not run this code.` | Stop. Do not open the project in an editor. Contact the development team |

## Security

In 2026 this repository was attacked by malware that hides code in project files and runs when
the project is opened or started. It has been removed from all branches and from the history.
`./run.sh` scans the code before it runs anything, and every push is scanned on GitHub
(the "Malware scan" check). Details and the rules for working safely are in
[`scripts/security/README.md`](scripts/security/README.md).

If you cloned this repository before November 2026, delete that copy and clone it again.
