# Fredd Infra

Supporting services shared by the backend and frontend: PostgreSQL, Redis, the Caddy reverse proxy, and the Docker Compose that runs everything locally. Production compose and backup jobs come later. Technical docs: [docs/README.md](docs/README.md).

All commands run from the parent folder that holds `backend/`, `frontend/` and `infra/` (see [Repositories](#repositories)).

## Two ways to run Fredd

| Mode | Use when | Command |
|---|---|---|
| **Native** | Day-to-day coding, hot reload | `docker compose -f infra/docker-compose.yml up -d --wait`, then run backend and frontend with their own commands |
| **Docker** | Try the whole app without installing Python/Node, or check production-like behaviour | `docker compose -f infra/docker-compose.yml --profile app up -d --build --wait` |

### Native mode

Starts only PostgreSQL and Redis. Follow the backend and frontend READMEs for the rest.

| Service | Host address | Credentials |
|---|---|---|
| PostgreSQL 17 | `127.0.0.1:5433` | `fredd` / `fredd`, database `fredd` |
| Redis 8 | `127.0.0.1:6380` | none |

### Docker mode

Builds the backend and frontend images, runs migrations, and serves everything behind Caddy:

- App: http://localhost:8080
- API health: http://localhost:8080/api/v1/health

| Service | What it does |
|---|---|
| `postgres`, `redis` | Same as native mode |
| `migrate` | Runs `alembic upgrade head` once, then exits |
| `api` | FastAPI image from `backend/Dockerfile` |
| `web` | Next.js standalone image from `frontend/Dockerfile` |
| `caddy` | Routes `/api` and `/webhooks` to `api`, everything else to `web` ([caddy/Caddyfile](caddy/Caddyfile)) |

Images are production builds: code changes need `--build` again. Use native mode for hot reload.

### Common commands

```bash
docker compose -f infra/docker-compose.yml --profile app ps        # status
docker compose -f infra/docker-compose.yml --profile app logs -f api
docker compose -f infra/docker-compose.yml --profile app down      # stop everything
docker compose -f infra/docker-compose.yml --profile app down -v   # stop and wipe the database
```

### Ports

Defaults: Postgres 5433, Redis 6380, app 8080, all bound to `127.0.0.1`. To change them, copy `infra/.env.example` to `infra/.env` and edit. Use `127.0.0.1`, not `localhost`, when connecting from Windows.

Database migrations live in `backend/migrations` (Alembic), next to the models they describe.

## Repositories

Fredd is split into three GitLab repos. Clone them side by side in one folder; commands in the docs assume this layout.

```bash
mkdir fredd && cd fredd
git clone https://gitlab.com/databiota-fredd/backend.git
git clone https://gitlab.com/databiota-fredd/frontend.git
git clone https://gitlab.com/databiota-fredd/infra.git
```
