# Repository Guidelines

## Project Structure & Module Organization
This repository is operations-first and documentation-heavy.
- Root docs: `README.md`, `spec.md`, `user-stories.md`, `ITERATION2.md`, `deployment.md`
- Docs mirror: `docs/` contains synced planning/runbook files (`docs/spec.md`, `docs/ITERATION2.md`, `docs/user-stories.md`)
- Deployment assets: `iteration2/docker-compose.yml` and `iteration2/.env.example`
- Host hardening script: `harden-vps.sh`

Keep infra changes close to the relevant runbook and update both root and `docs/` copies when both exist.

## Build, Test, and Development Commands
There is no app build pipeline in this repo; validation is command-driven.
- `cp iteration2/.env.example iteration2/.env`: create local deployment config
- `docker compose -f iteration2/docker-compose.yml --env-file iteration2/.env up -d`: start Mattermost/Postgres stack
- `docker compose -f iteration2/docker-compose.yml --env-file iteration2/.env ps`: check container health
- `docker compose -f iteration2/docker-compose.yml --env-file iteration2/.env logs --tail=80 mattermost`: inspect startup/runtime logs
- `curl -sf http://127.0.0.1:8065/api/v4/system/ping | jq .`: verify Mattermost API responsiveness

## Coding Style & Naming Conventions
For Bash (`harden-vps.sh`):
- Use `#!/usr/bin/env bash` + `set -euo pipefail`
- Prefer uppercase env-config vars (for example `ADMIN_USER`, `POSTGRES_PASSWORD`)
- Keep scripts idempotent and safe to re-run

For Markdown docs:
- Use concise, task-oriented headings and numbered runbook steps
- Keep filenames descriptive and lowercase-hyphenated where possible

## Testing Guidelines
Automated unit/integration tests are not currently defined. Treat operational verification as required testing:
- Bring up services with Compose
- Validate `/api/v4/system/ping`
- Check logs for errors
- Confirm security controls (UFW/Cloudflare constraints) per `deployment.md` and `ITERATION2.md`

Document any manual verification steps you add.

## Commit & Pull Request Guidelines
Git history is currently minimal (`first commit`), so conventions are lightweight but should be tightened:
- Commit messages: imperative, specific subject lines (for example `docs: refine iteration2 verification steps`)
- One logical change per commit
- PRs should include: purpose, changed files, deployment impact, verification commands run, and screenshots only when UI/admin-console changes are relevant
- Link related issue/task IDs when available

## Security & Configuration Tips
Never commit secrets (`.env`, bot tokens, passwords, keys). Use `iteration2/.env.example` as the template, keep real values local, and rotate any credential exposed in logs or screenshots.

## Assistant Memory Tracking
- Maintain `assistant-tracker.md` as a persistent working log.
- After each task, add or update entries for:
  - mistakes made during the task (what happened, impact, fix, prevention rule)
  - user preferences discovered or stated (and how to apply them)
- Add newest entries at the top of each table in `assistant-tracker.md`.
