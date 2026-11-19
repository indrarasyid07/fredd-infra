# Decision Log

| No | Tanggal | Keputusan | Alasan | Status |
|---|---|---|---|---|
| I-001 | 2026-11-13 | Folder `infra/` terpisah untuk database, Redis, proxy, dan deploy | Layanan pendukung dipakai bersama backend dan frontend | Diterima |
| I-002 | 2026-11-13 | Migrasi Alembic tetap di `backend/` | Migrasi berubah bersama model SQLAlchemy | Diterima |
| I-003 | 2026-11-13 | Development: hanya Postgres dan Redis di Docker; api dan web jalan native | Hot reload cepat, debug langsung | Diterima |
| I-004 | 2026-11-13 | Port host dev 5433 dan 6380, bind `127.0.0.1` | Hindari bentrok dengan Postgres/Redis native | Diterima |
| I-005 | 2026-11-13 | Nama project compose dikunci `fluctuz` | Nama container dan volume tidak berubah bila folder dipindah | Diterima |
| I-006 | 2026-11-13 | Caddy sebagai reverse proxy | TLS otomatis, konfigurasi singkat, SSE mudah | Diusulkan |
| I-007 | 2026-11-13 | Redis dengan AOF dan `noeviction` di staging/produksi | Antrean job tidak boleh hilang | Diusulkan |
| I-008 | 2026-11-13 | Dua mode lokal: native (hot reload) dan Docker (profile `app`) | Developer tetap cepat; anggota tim lain bisa menjalankan semua hanya dengan Docker | Diterima |
| I-009 | 2026-11-13 | Mode Docker memakai image produksi di belakang Caddy, tanpa bind mount | Perilaku sama dengan produksi; hot reload lewat bind mount lambat dan rapuh di Windows | Diterima |
| I-010 | 2026-11-13 | Port host lewat `infra/.env` (default 5433, 6380, 8080) | Mesin developer sering sudah memakai 3000/8000/5432/6379 | Diterima |
| I-011 | 2026-11-14 | Pesan commit mengikuti Conventional Commits dalam Bahasa Inggris, tanpa baris atribusi AI/alat dan tanpa referensi ke file desain ([commit-conventions](../00-governance/commit-conventions.md)) | Riwayat yang seragam dan bermakna tanpa bergantung pada alat yang dipakai | Diterima |
| I-012 | 2026-11-15 | `development` jadi cabang utama dan default di GitLab; `main` hanya berisi commit awal dan diperbarui lewat merge dari `development` | Sama dengan backend (B-032) | Diterima |
| I-XXX | 2026-11-19 | Target deploy (PRD D3): **VPS + Docker Compose** (`caddy`, `web`, `api`, `worker`, `scheduler`, `redis`; database Neon atau `postgres`). Worker antrean memakai **Taskiq** (backend B-XXX): service `worker` dan `scheduler` (tepat satu). Redis memakai AOF + volume `redis-data`. | Worker dan cron butuh proses yang terus hidup, yang tidak tersedia di hosting serverless; satu VPS paling sederhana dioperasikan. Keputusan pemilik produk, 19 November 2026. | Diterima |
