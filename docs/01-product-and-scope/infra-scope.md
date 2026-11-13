# Infra Scope

## Yang diurus `infra/`

| Hal | Status |
|---|---|
| PostgreSQL dan Redis untuk development (`docker-compose.yml`) | Ada |
| Compose produksi: `api`, `worker`, `web`, `postgres`, `redis`, `caddy` | Fase deploy |
| Reverse proxy Caddy: TLS, routing `/api`, `/webhooks`, web | Fase deploy |
| Backup dan restore database | Fase deploy |
| Observabilitas: log, error tracking, health check, metrik antrean | Fase deploy |
| Object storage (R2 / MinIO) | Keputusan penyedia masih terbuka |

## Yang tidak di sini

| Hal | Tempat |
|---|---|
| Migrasi skema (Alembic) | `backend/migrations` (berubah bersama model) |
| Seed data | `backend` (`fredd.seed`) |
| Dockerfile aplikasi | `backend/` dan `frontend/` (dibangun dari kode masing-masing) |
| Variabel env aplikasi | `backend/.env.example`, `frontend/.env.example` |

## Pertanyaan terbuka

1. Hosting: VPS sendiri, cloud lokal, atau cloud global? Ada syarat data tetap di Indonesia?
2. Postgres dikelola sendiri di container atau managed service?
3. Penyedia object storage untuk foto.
4. Penyedia error tracking.
