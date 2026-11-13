# Infrastructure Architecture

## Topologi produksi (rencana)

```
Internet ──► Caddy :443 (TLS otomatis)
               ├── /api/*       → api:8000   (FastAPI)
               ├── /webhooks/*  → api:8000
               └── /*           → web:3000   (Next.js standalone)

Jaringan internal Docker (tidak terekspos):
  api, worker ──► postgres:5432
  api, worker ──► redis:6379
  worker      ──► internet (WhatsApp Cloud API, Telegram, LLM, object storage)
```

Hanya Caddy yang membuka port ke publik. Postgres dan Redis tidak pernah diberi port host di produksi.

## Layanan

| Layanan | Image | Volume | Catatan |
|---|---|---|---|
| `caddy` | `caddy:2` | `caddy-data` (sertifikat) | Satu-satunya pintu masuk |
| `web` | dibangun dari `frontend/` | – | `node server.js` |
| `api` | dibangun dari `backend/` | – | `uvicorn`, bisa lebih dari 1 replika |
| `worker` | sama dengan `api` | – | `arq fredd.worker.WorkerSettings` |
| `migrate` | sama dengan `api` | – | Job satu kali `alembic upgrade head` sebelum `api`/`worker` start |
| `postgres` | `postgres:17` | `postgres-data` | |
| `redis` | `redis:8` | `redis-data` | AOF aktif agar antrean tidak hilang saat restart |

## Lingkungan

| Lingkungan | Isi | Domain |
|---|---|---|
| development | `infra/docker-compose.yml` (Postgres + Redis); api dan web jalan native | `localhost` |
| staging | Compose produksi + seed `demo` | `staging.<domain>` |
| production | Compose produksi | `<domain>` |

## Development lokal

| Layanan | Port host | Alasan |
|---|---|---|
| Postgres | 5433 | 5432 sering dipakai Postgres native |
| Redis | 6380 | 6379 sering dipakai Redis native |

Port hanya di-bind ke `127.0.0.1`. Nama project compose dikunci `fredd` agar nama container dan volume tidak tergantung nama folder.
