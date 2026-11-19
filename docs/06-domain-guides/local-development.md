# Local Development

Semua perintah dijalankan dari folder induk yang berisi `fredd-backend/`, `fredd-frontend/`, dan `fredd-infra/`.

## Dua mode

| | Native | Docker |
|---|---|---|
| Kebutuhan | Docker, uv, Node.js 22 | Docker saja |
| Yang jalan di Docker | Postgres, Redis | Postgres, Redis, migrate, api, web, Caddy |
| Hot reload | Ya | Tidak (image produksi, rebuild dengan `--build`) |
| Alamat aplikasi | web `http://localhost:3000`, api `http://127.0.0.1:8000` | `http://localhost:8080` (web dan `/api` lewat Caddy) |
| Cocok untuk | Menulis kode sehari-hari | Mencoba seluruh aplikasi, cek perilaku mirip produksi, anggota tim non-developer |

### Native

```bash
docker compose -f fredd-infra/docker-compose.yml up -d --wait
```

Lalu jalankan backend (`uv run uvicorn …`) dan frontend (`npm run dev`) sesuai README masing-masing.

| Layanan | Alamat | Login |
|---|---|---|
| PostgreSQL | `127.0.0.1:5433`, database `fluctuz` | `fluctuz` / `fluctuz` |
| Redis | `127.0.0.1:6380` | – |

### Docker

```bash
docker compose -f fredd-infra/docker-compose.yml --profile app up -d --build --wait
```

Urutan start: `postgres` dan `redis` sehat → `migrate` menjalankan `alembic upgrade head` lalu keluar → `api` dan `web` sehat → `caddy` membuka port 8080.

Jangan menjalankan kedua mode sekaligus dengan port yang sama: Postgres dan Redis dipakai bersama, tetapi `npm run dev` dan `uvicorn` native tidak bentrok dengan mode Docker karena api dan web Docker tidak membuka port host (hanya Caddy di 8080).

## Mengubah port

Salin `fredd-infra/.env.example` menjadi `fredd-infra/.env`, lalu ubah `POSTGRES_PORT`, `REDIS_PORT`, atau `APP_PORT`. Bila port Postgres/Redis diubah, sesuaikan juga `fredd-backend/.env`.

## Catatan Windows

- Pakai `127.0.0.1`, bukan `localhost`, untuk Postgres dan Redis. Windows mendahulukan IPv6 (`::1`), sedangkan container hanya mendengarkan IPv4; koneksi Redis akan timeout.
- Bila port masih terpakai, cek dengan `netstat -ano | findstr :5433`.
- Port aplikasi native 8000 (API) dan 3000 (web) sering dipakai proyek lain; jalankan dengan `--port` lain dan set `API_INTERNAL_URL` di `fredd-frontend/.env.local`, atau pakai mode Docker.

## Perintah berguna

```bash
# status dan log
docker compose -f fredd-infra/docker-compose.yml --profile app ps
docker compose -f fredd-infra/docker-compose.yml --profile app logs -f api

# psql ke database dev
docker compose -f fredd-infra/docker-compose.yml exec postgres psql -U fluctuz

# redis-cli
docker compose -f fredd-infra/docker-compose.yml exec redis redis-cli

# bangun ulang satu image setelah kode berubah
docker compose -f fredd-infra/docker-compose.yml --profile app up -d --build web

# hentikan; tambahkan -v untuk menghapus data
docker compose -f fredd-infra/docker-compose.yml --profile app down
```

`--profile app` pada `down` diperlukan agar container mode Docker ikut dihentikan.
