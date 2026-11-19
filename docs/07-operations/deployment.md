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
