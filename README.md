# Fluctuz Infra

Infrastruktur Fluctuz: PostgreSQL, Redis, Caddy, dan Docker Compose untuk menjalankan seluruh aplikasi.

- [Tentang Fluctuz](#tentang-fluctuz)
- [Gambaran teknis](#gambaran-teknis)
- [Repo ini: infra](#repo-ini-infra)

## Tentang Fluctuz

Fluctuz adalah **asisten AI untuk pengumpulan data lapangan**. Penyuluh pertanian cukup melapor lewat chat WhatsApp atau Telegram yang sudah mereka pakai setiap hari; Fluctuz menanyakan isian satu per satu, memeriksa jawabannya, lalu menyimpannya sebagai data rapi yang langsung tampil di dashboard instansi.

### Masalah yang diselesaikan

Laporan lapangan (kondisi tanaman, serangan hama, luas tanam, hasil panen) umumnya dikumpulkan lewat formulir kertas, spreadsheet, atau pesan chat bebas. Akibatnya:

- Data datang terlambat dan harus diketik ulang sebelum bisa dianalisis.
- Isian sering tidak lengkap atau salah format (luas tanpa satuan, lokasi tidak jelas, foto tidak ada).
- Penyuluh harus memasang dan belajar aplikasi baru, yang sering tidak jalan di ponsel lama atau sinyal lemah.
- Admin tidak bisa melihat kondisi lapangan secara langsung.

### Cara kerja

1. **Rancang.** Admin menyusun *struktur data* (daftar isian dan aturannya: teks, angka, pilihan, foto, lokasi, tanggal) di dashboard, dibantu Agen AI.
2. **Lapor lewat chat.** Fluctuz menghubungi penyuluh di WhatsApp atau Telegram, menanyakan isian satu pesan per pertanyaan, mengoreksi jawaban yang tidak valid dengan contoh, dan meminta foto atau lokasi. Bila sinyal hilang, jawaban disimpan sebagai draf dan Fluctuz mengingatkan nanti.
3. **Pantau.** Laporan masuk ke dashboard secara real-time: tabel, peta sebaran, foto bukti, grafik tren, dan ekspor Excel. Admin bisa meninjau laporan dan mengambil alih percakapan bila perlu.

### Pengguna

| Pengguna | Lewat | Yang dilakukan |
|---|---|---|
| Admin, editor struktur, peninjau | Dashboard web | Menyusun struktur data, mengundang penyuluh, menghubungkan kanal, meninjau laporan, mengambil alih percakapan |
| Penyuluh lapangan | WhatsApp / Telegram | Mengisi laporan; tidak perlu memasang aplikasi apa pun |
| Fluctuz (agen AI) | Server | Menjalankan percakapan, validasi, pengingat, dan ringkasan |
| Pengunjung | Website publik | Membaca landing page dan mendaftar |

### Model bisnis

Fluctuz dijual sebagai SaaS berlangganan dengan dua jenis workspace:

| Jenis | Paket |
|---|---|
| Perorangan | Gratis, Plus |
| Organisasi | Starter, Growth, Enterprise |

Paket membatasi jumlah anggota, struktur data aktif, dan laporan per bulan; tagihan bulanan atau tahunan. Rincian: [billing-and-plans.md](https://github.com/indrarasyid07/fredd-backend/blob/development/docs/06-domain-guides/billing-and-plans.md).

### Status pengembangan (14 November 2026)

| Bagian | Status |
|---|---|
| Fondasi backend, frontend, dan infra; Docker Compose | Selesai |
| Format respons API standar, request ID, proteksi CSRF | Selesai |
| Masuk dengan email + kata sandi, keluar, cek sesi | Selesai |
| Website publik dengan SEO: landing, Tentang Kami, Harga, Terra, Nexus, API, Blog, Dokumentasi, Keamanan, Kontak | Selesai (Blog berisi artikel contoh; formulir Kontak belum aktif) |
| Daftar akun, verifikasi email, lupa kata sandi, masuk dengan Google | Backend selesai (email lewat SMTP, Google perlu client OAuth); layar webnya menyusul |
| Workspace, anggota, dan peran | Belum |
| Kanal Telegram dan mesin percakapan | Belum |
| Penyusun struktur data, data lapangan, peta, ekspor | Belum |
| WhatsApp Cloud API | Belum (menunggu verifikasi bisnis Meta) |
| Paket dan tagihan | Belum |

Urutan lengkap: [roadmap backend](https://github.com/indrarasyid07/fredd-backend/blob/development/docs/10-roadmap/roadmap.md) dan [roadmap frontend](https://github.com/indrarasyid07/fredd-frontend/blob/development/docs/10-roadmap/roadmap.md).

## Gambaran teknis

### Arsitektur

```
Browser ──► Caddy (satu domain)
              ├── /api/*       → FastAPI (api)
              ├── /webhooks/*  → FastAPI (api)   ← WhatsApp, Telegram, pembayaran
              └── /*           → Next.js (website publik + dashboard)

FastAPI ──► PostgreSQL   (data utama)
        ──► Redis        (rate limit, antrean Taskiq, event real-time)
        ──► S3-compatible (foto dan suara, menyusul)
Worker Taskiq ──► WhatsApp Cloud API, Telegram Bot API, LLM (menyusul)
```

Prinsip utama:

- **Satu domain, routing per path.** Cookie sesi dipakai bersama oleh Next.js dan FastAPI tanpa CORS.
- **Next.js tidak pernah mengakses database.** Semua data lewat API FastAPI; tipe TypeScript klien di-generate dari OpenAPI backend.
- **Satu format respons** untuk semua endpoint: `{success, message, data, errors, meta}`.
- **Endpoint dan kode dalam Bahasa Inggris**, teks UI dan pesan ke penyuluh dalam Bahasa Indonesia.

### Repositori

Fluctuz terdiri dari tiga repo GitHub yang di-clone berdampingan dalam satu folder:

| Repo | Isi |
|---|---|
| [fredd-backend](https://github.com/indrarasyid07/fredd-backend) | API FastAPI, worker, migrasi database, tes |
| [fredd-frontend](https://github.com/indrarasyid07/fredd-frontend) | Next.js: website publik (SEO) dan dashboard `/app` |
| [fredd-infra](https://github.com/indrarasyid07/fredd-infra) | Docker Compose, PostgreSQL, Redis, Caddy; nanti deploy dan backup |

```bash
mkdir fluctuz && cd fluctuz
git clone -b development https://github.com/indrarasyid07/fredd-backend.git
git clone -b development https://github.com/indrarasyid07/fredd-frontend.git
git clone -b development https://github.com/indrarasyid07/fredd-infra.git
```

Nama folder harus sama dengan nama repo: compose membangun image dari `../fredd-backend` dan `../fredd-frontend`, dan `npm run api:types` membaca `../fredd-backend/openapi.json`. Clone dengan `-b development` karena semua pekerjaan ada di cabang itu.

### Tech stack

| Lapisan | Teknologi |
|---|---|
| Backend | Python 3.14, FastAPI, Pydantic v2, SQLAlchemy 2 async + asyncpg, Alembic, uv |
| Frontend | Next.js 16 (App Router), React 19, TypeScript, Tailwind CSS 4, openapi-fetch |
| Data | PostgreSQL 17, Redis 8 |
| Auth | Sesi opaque di cookie HttpOnly, hash argon2 untuk kata sandi; Google OAuth (kode otorisasi + PKCE) |
| Kualitas | ruff, pyright, pytest (backend); ESLint, TypeScript strict (frontend) |
| Jalankan dan deploy | Docker Compose, Caddy |
| Kanal chat | Telegram Bot API, WhatsApp Cloud API (menyusul) |

Alasan setiap pilihan tercatat di decision log masing-masing repo.

### Menjalankan

Dua cara, keduanya dari folder induk yang berisi ketiga repo:

| Cara | Untuk | Perintah |
|---|---|---|
| **Native** | Coding sehari-hari dengan hot reload | `docker compose -f fredd-infra/docker-compose.yml up -d --wait`, lalu jalankan backend dan frontend dengan perintah di README masing-masing |
| **Docker** | Mencoba seluruh aplikasi tanpa memasang Python/Node | `docker compose -f fredd-infra/docker-compose.yml --profile app up -d --build --wait`, lalu buka http://localhost:8080 |

### Kontribusi

- Pesan commit mengikuti [commit-conventions.md](https://github.com/indrarasyid07/fredd-backend/blob/development/docs/00-governance/commit-conventions.md) (Conventional Commits, Bahasa Inggris).
- Dokumentasi mengikuti [documentation-guidelines.md](https://github.com/indrarasyid07/fredd-backend/blob/development/docs/00-governance/documentation-guidelines.md).
- File `.env`, hasil build, dan data lapangan tidak pernah di-commit.
- Cabang utama adalah `development` (default di GitHub); semua pekerjaan masuk ke sana. `main` berisi commit awal dan hanya diperbarui lewat merge dari `development` ([aturan cabang](https://github.com/indrarasyid07/fredd-backend/blob/development/docs/00-governance/commit-conventions.md#cabang)).

## Repo ini: infra

Layanan pendukung yang dipakai bersama backend dan frontend: PostgreSQL, Redis, reverse proxy Caddy, dan Docker Compose untuk menjalankan semuanya di lokal. Compose production dan backup menyusul.

Semua perintah dijalankan dari folder induk yang berisi `fredd-backend/`, `fredd-frontend/`, dan `fredd-infra/`.

### Mode native

Hanya menyalakan PostgreSQL dan Redis; backend dan frontend dijalankan dengan perintah di README masing-masing.

```bash
docker compose -f fredd-infra/docker-compose.yml up -d --wait
```

| Layanan | Alamat host | Kredensial |
|---|---|---|
| PostgreSQL 17 | `127.0.0.1:5433` | `fluctuz` / `fluctuz`, database `fluctuz` (hanya untuk lokal) |
| Redis 8 | `127.0.0.1:6380` | tanpa kata sandi |

### Mode Docker

Membangun image backend dan frontend, menjalankan migrasi, dan menyajikan semuanya di belakang Caddy.

```bash
docker compose -f fredd-infra/docker-compose.yml --profile app up -d --build --wait
```

- Aplikasi: http://localhost:8080
- Health API: http://localhost:8080/api/v1/health

| Layanan | Fungsi |
|---|---|
| `postgres`, `redis` | Sama seperti mode native |
| `migrate` | Menjalankan `alembic upgrade head` sekali lalu berhenti |
| `api` | Image FastAPI dari `fredd-backend/Dockerfile` |
| `web` | Image Next.js standalone dari `fredd-frontend/Dockerfile` |
| `caddy` | `/api` dan `/webhooks` ke `api`, sisanya ke `web` ([caddy/Caddyfile](caddy/Caddyfile)) |

Image adalah build produksi: perubahan kode butuh `--build` lagi. Pakai mode native untuk hot reload.

### Perintah umum

```bash
docker compose -f fredd-infra/docker-compose.yml --profile app ps          # status
docker compose -f fredd-infra/docker-compose.yml --profile app logs -f api # log satu layanan
docker compose -f fredd-infra/docker-compose.yml --profile app down        # hentikan semua
docker compose -f fredd-infra/docker-compose.yml --profile app down -v     # hentikan dan hapus data database
```

### Port

Default: PostgreSQL 5433, Redis 6380, aplikasi 8080, semuanya hanya di `127.0.0.1`. Untuk mengubah, salin `fredd-infra/.env.example` ke `fredd-infra/.env` lalu ubah nilainya. Dari Windows pakai `127.0.0.1`, bukan `localhost`.

Migrasi database ada di `fredd-backend/alembic`, bersebelahan dengan model yang dijelaskannya.

### Isi repo

```
docker-compose.yml   layanan, profile app, volume, healthcheck
caddy/Caddyfile      routing satu domain; /api/v1/events tanpa buffering untuk SSE
.env.example         port host dan URL publik
docs/                dokumentasi infra (Bahasa Indonesia): deployment, keamanan, operasional
```

### Dokumentasi

[docs/README.md](docs/README.md) berisi peta dokumen: deployment, keamanan infra, backup, dan keputusan teknis ([decision log](docs/11-decisions/decision-log.md)).
