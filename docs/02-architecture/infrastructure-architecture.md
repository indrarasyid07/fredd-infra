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
| `web` | dibangun dari `fredd-frontend/` | – | `node server.js` |
| `api` | dibangun dari `fredd-backend/` | – | `uvicorn`, bisa lebih dari 1 replika |
| `worker` | sama dengan `api` | – | `taskiq worker app.worker:broker` (Taskiq, Redis streams); bisa lebih dari 1 replika |
| `scheduler` | sama dengan `api` | – | `taskiq scheduler app.worker:scheduler`: memulai cron. **Tepat satu** instance |
| `migrate` | sama dengan `api` | – | Job satu kali `alembic upgrade head` sebelum `api`/`worker` start |
| `postgres` | `postgis/postgis:17-3.5` (Postgres 17 + PostGIS) | `postgres-data` | |
| `redis` | `redis:8` | `redis-data` | AOF aktif (`appendonly yes`, `appendfsync everysec`) agar antrean tidak hilang saat restart. **Ada (3.1)** |

## Lingkungan

| Lingkungan | Isi | Domain |
|---|---|---|
| development (native) | `fredd-infra/docker-compose.yml` (Postgres + Redis); api dan web jalan native | `localhost` |
| development (Docker) | `fredd-infra/docker-compose.yml --profile app`: + migrate, api, web, Caddy | `localhost:8080` |
| staging | Compose produksi + seed `demo` | `staging.<domain>` |
| production | Compose produksi | `<domain>` |

## Development lokal

| Layanan | Port host | Alasan |
|---|---|---|
| Postgres | 5433 | 5432 sering dipakai Postgres native |
| Redis | 6380 | 6379 sering dipakai Redis native |
| App (profile `app`, lewat Caddy) | 8080 | Tidak bentrok dengan 3000/8000 yang sering dipakai |

Semua port bisa diubah lewat `fredd-infra/.env` (lihat `.env.example`). Port hanya di-bind ke `127.0.0.1`. Di mode Docker, `api` dan `web` tidak membuka port host; semua lewat Caddy seperti produksi. Nama project compose dikunci `fluctuz` agar nama container dan volume tidak tergantung nama folder.
