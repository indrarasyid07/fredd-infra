# Deployment

Konfigurasi khusus aplikasi (env, migrasi, zona waktu) ada di [backend deployment](https://github.com/indrarasyid07/fredd-backend/blob/development/docs/07-operations/deployment.md) dan [frontend deployment](https://github.com/indrarasyid07/fredd-frontend/blob/development/docs/07-operations/deployment.md).

## Berkas

```
fredd-infra/
├── docker-compose.yml        # development: native (postgres, redis) + profile app (migrate, api, web, caddy)   [ada]
├── caddy/Caddyfile           # routing lokal; produksi menambah domain dan TLS                                  [ada]
├── .env.example              # port host lokal                                                                   [ada]
├── docker-compose.prod.yml   # + worker, role DB terpisah, Redis AOF, secrets                                    [fase deploy]
└── scripts/backup.sh         # pg_dump terenkripsi ke object storage                                             [fase deploy]
```

Image aplikasi dibangun dari `fredd-backend/Dockerfile` dan `fredd-frontend/Dockerfile`; keduanya sudah dipakai mode Docker lokal, jadi compose produksi cukup memakai image yang sama dengan env produksi.

## Urutan deploy

1. Build image `api` (dari `fredd-backend/`) dan `web` (dari `fredd-frontend/`), beri tag commit.
2. `docker compose -f fredd-infra/docker-compose.prod.yml pull` / `build`.
3. Jalankan job `migrate` (sekali, sebelum replika lain).
4. `up -d` untuk `api`, `worker`, `web`; Caddy tetap jalan.
5. Cek `GET /api/v1/health` dan halaman utama.

Rollback: jalankan ulang dengan tag image sebelumnya. Migrasi yang tidak bisa dibalik harus ditulis dua tahap (tambah dulu, hapus di rilis berikutnya) agar rollback aplikasi aman.

## Caddy

- TLS otomatis, redirect HTTP → HTTPS.
- Routing sesuai [03-api](../03-api/README.md).
- Kompresi `zstd gzip` untuk web; tidak untuk `/api/v1/events` (SSE).
- Log akses JSON ke stdout.

## Observabilitas

| Hal | Cara |
|---|---|
| Log | Semua layanan log JSON ke stdout; dikumpulkan driver log Docker atau agen penyedia |
| Error | Error tracking (Sentry atau sejenis) di api, worker, web |
| Health | `GET /api/v1/health` (DB + Redis), dipantau uptime checker eksternal tiap menit |
| Metrik antrean | Panjang antrean Taskiq, umur job tertua, pesan keluar gagal per jam; alarm bila job tertua > 5 menit |
| Disk | Alarm bila volume Postgres > 80% |

## Jadwal

| Tugas | Waktu (WIB) |
|---|---|
| Backup database | Harian 02.00 |
| Uji restore | Bulanan |
| Update image dasar | Bulanan |

## Server development

Cabang `development` di ketiga repo otomatis ter-deploy ke VPS development (`139.162.58.173`, dipakai bersama proyek lain) di **http://139.162.58.173:8095**. Belum ada domain/TLS, jadi `ENVIRONMENT=development` (cookie tanpa `Secure`, email dicatat di log bila `SMTP_HOST` kosong, `/api/docs` terbuka).

Setiap repo memicu deploy-nya sendiri dan hanya mengurus miliknya: repo aplikasi mengurus image, `fredd-infra` mengurus server.

| Pemicu | Workflow | Yang terjadi |
|---|---|---|
| `ci` lulus pada push ke `development` di fredd-backend | `deploy-development.yml` | build image `ghcr.io/indrarasyid07/fredd-api:{development,<sha>}`, lalu SSH `deploy.sh api` (pull, `alembic upgrade head`, restart api/worker/scheduler) |
| `ci` lulus pada push ke `development` di fredd-frontend | `deploy-development.yml` | build image `ghcr.io/indrarasyid07/fredd-web:{development,<sha>}` dengan `NEXT_PUBLIC_SITE_URL` = variable `DEPLOY_SITE_URL`, lalu SSH `deploy.sh web` |
| push ke `development` di fredd-infra yang mengubah `deploy/development/**` atau `caddy/Caddyfile` | `deploy-development.yml` | validasi compose, salin `docker-compose-dev.yml`, `deploy.sh`, `.env.example`, `Caddyfile` ke `/opt/fluctuz`, lalu `deploy.sh` tanpa pull. **Hanya workflow ini yang menyalin file ke server.** |

Semua workflow juga bisa dijalankan manual (`workflow_dispatch`).

**Di server** (`/opt/fluctuz`, milik user `deploy`): `docker-compose-dev.yml`, `deploy.sh`, `Caddyfile` disalin oleh workflow fredd-infra; `.env` (salinan [`.env.example`](../../deploy/development/.env.example), berisi `POSTGRES_PASSWORD` dll.) dibuat sekali dengan tangan dan tidak pernah ditimpa. Nama project compose `fluctuz-dev`; Postgres dan Redis tidak membuka port ke host. Login GHCR memakai `DOCKER_CONFIG=/opt/fluctuz/.docker` dan di-logout setelah pull, jadi login registry proyek lain di host tidak terganggu.

**GitHub** (sama di ketiga repo): secret `DEPLOY_SSH_KEY` (key ed25519 khusus, `github-actions-fluctuz-dev`) dan `DEPLOY_KNOWN_HOSTS`; variable `DEPLOY_HOST`, `DEPLOY_USER`; fredd-frontend juga `DEPLOY_SITE_URL`. `DEPLOY_SITE_URL` harus sama dengan `APP_BASE_URL` di `.env` server.

**Env var baru dari backend** tidak butuh PR ke fredd-infra: api, worker, scheduler, dan migrate membaca seluruh `/opt/fluctuz/.env` (`env_file`). Tambahkan variabelnya ke `fredd-backend/.env.example` dan ke `.env` server sebelum PR backend di-merge. Hanya `DATABASE_URL`, `REDIS_URL`, `MEDIA_DIR`, `ENVIRONMENT`, dan `APP_BASE_URL` yang disusun oleh compose.

**Bot Telegram (sementara):** server belum punya domain/TLS, sedangkan Telegram hanya memanggil webhook https. Service `telegram-poll` menjalankan `scripts.telegram_poll` (long-poll `getUpdates`), cukup `TELEGRAM_BOT_TOKEN` di `.env`. Tepat satu instance, dan hanya untuk bot development. Setelah ada domain: hapus service ini, lalu `setWebhook` ke `https://<domain>/webhooks/telegram` dengan `secret_token` = `TELEGRAM_WEBHOOK_SECRET`.

**Rollback** satu layanan: isi `API_TAG=<sha>` atau `WEB_TAG=<sha>` di `/opt/fluctuz/.env`, lalu `bash /opt/fluctuz/deploy.sh`. Hapus lagi baris itu agar deploy berikutnya kembali ke `development`.

**Operasional:**

```bash
cd /opt/fluctuz
docker compose -f docker-compose-dev.yml logs -f api worker
docker compose -f docker-compose-dev.yml run --rm -T migrate python -m scripts.seed reference   # data rujukan wilayah
```
