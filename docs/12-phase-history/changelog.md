# Changelog

Catatan per fase, terbaru di atas.

## 2026-11-15 · Cabang

- `development` menjadi cabang utama dan default di GitLab; `main` berisi commit awal dan diperbarui lewat merge dari `development` ([commit-conventions](../00-governance/commit-conventions.md#cabang)). Semua tautan lintas repo kini mengarah ke `development`.

## 2026-11-14 · Standar commit

- `00-governance/commit-conventions.md`: format, type, scope, aturan subject/body/footer, larangan (atribusi AI, referensi file desain, rahasia, data pribadi), dan contoh.

## 2026-11-14 · Env untuk login

- `api`/`migrate` mendapat `APP_BASE_URL=http://localhost:${APP_PORT}` agar cek CSRF menerima asal Caddy; `web` mendapat `API_INTERNAL_URL=http://api:8000` untuk validasi sesi di server.

## 2026-11-14 · Path backend

- Perintah worker dan seed mengikuti struktur backend baru (`app.worker`, `scripts/seed.py`).

## 2026-11-13 · Paket berbayar

- Desain Upgrade menambah webhook penyedia pembayaran di `/webhooks/payments/{provider}`; sudah tercakup routing `/webhooks/*` di Caddy.

## 2026-11-13 · Mode Docker

- `docker-compose.yml` mendapat profile `app`: `migrate`, `api`, `web`, `caddy`; aplikasi di `http://localhost:8080`.
- `caddy/Caddyfile` untuk routing lokal (SSE tanpa buffer); `.env.example` untuk port host.
- Diuji: health 200 lewat Caddy, `/app` redirect ke `/login`, migrasi sukses, container berjalan sebagai non-root.

## 2026-11-13 · Folder infra

- `docker-compose.yml` dipindah dari root ke `infra/`; nama project dikunci `fluctuz`.
- Dokumentasi infra disusun dalam struktur folder bernomor yang sama dengan backend dan frontend.
- Bagian deploy, Caddy, backup, dan observabilitas dipindah dari `backend/docs/07-operations` ke sini.
