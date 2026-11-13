# Local Development

## Menjalankan layanan

```bash
docker compose -f infra/docker-compose.yml up -d --wait
```

Lalu jalankan backend dan frontend sesuai README masing-masing.

| Layanan | Alamat | Login |
|---|---|---|
| PostgreSQL | `127.0.0.1:5433`, database `fredd` | `fredd` / `fredd` |
| Redis | `127.0.0.1:6380` | – |

## Catatan Windows

- Pakai `127.0.0.1`, bukan `localhost`. Windows mendahulukan IPv6 (`::1`), sedangkan container hanya mendengarkan IPv4; koneksi Redis akan timeout.
- Bila port 5433/6380 juga terpakai, ubah sisi kiri pemetaan port di compose dan sesuaikan `backend/.env`. Cek dengan `netstat -ano | findstr :5433`.
- Port aplikasi bawaan 8000 (API) dan 3000 (web) sering dipakai proyek lain; jalankan dengan `--port` lain dan set `API_INTERNAL_URL` di `frontend/.env.local`.

## Perintah berguna

```bash
# lihat status dan log
docker compose -f infra/docker-compose.yml ps
docker compose -f infra/docker-compose.yml logs -f postgres

# psql ke database dev
docker compose -f infra/docker-compose.yml exec postgres psql -U fredd

# redis-cli
docker compose -f infra/docker-compose.yml exec redis redis-cli

# hentikan; tambahkan -v untuk menghapus data
docker compose -f infra/docker-compose.yml down
```
