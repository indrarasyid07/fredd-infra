# Fredd Infra

Supporting services shared by the backend and frontend: PostgreSQL and Redis now; later the reverse proxy (Caddy), production compose, and backup jobs. Technical docs: [docs/README.md](docs/README.md).

## Development services

```bash
# from the parent folder that holds backend/, frontend/, infra/
docker compose -f infra/docker-compose.yml up -d --wait
```

| Service | Host address | Credentials |
|---|---|---|
| PostgreSQL 17 | `127.0.0.1:5433` | `fredd` / `fredd`, database `fredd` |
| Redis 8 | `127.0.0.1:6380` | none |

Stop: `docker compose -f infra/docker-compose.yml down`. Wipe the database: add `-v`.

Ports 5433 and 6380 avoid clashing with a native Postgres/Redis. Use `127.0.0.1`, not `localhost`.

Database migrations live in `backend/migrations` (Alembic), next to the models they describe.

## Repositories

Fredd is split into three GitLab repos. Clone them side by side in one folder; commands in the docs assume this layout.

```bash
mkdir fredd && cd fredd
git clone https://gitlab.com/databiota-fredd/backend.git
git clone https://gitlab.com/databiota-fredd/frontend.git
git clone https://gitlab.com/databiota-fredd/infra.git
```
