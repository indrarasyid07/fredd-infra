# Decision Log

| No | Tanggal | Keputusan | Alasan | Status |
|---|---|---|---|---|
| I-001 | 2026-11-13 | Folder `infra/` terpisah untuk database, Redis, proxy, dan deploy | Layanan pendukung dipakai bersama backend dan frontend | Diterima |
| I-002 | 2026-11-13 | Migrasi Alembic tetap di `backend/` | Migrasi berubah bersama model SQLAlchemy | Diterima |
| I-003 | 2026-11-13 | Development: hanya Postgres dan Redis di Docker; api dan web jalan native | Hot reload cepat, debug langsung | Diterima |
| I-004 | 2026-11-13 | Port host dev 5433 dan 6380, bind `127.0.0.1` | Hindari bentrok dengan Postgres/Redis native | Diterima |
| I-005 | 2026-11-13 | Nama project compose dikunci `fredd` | Nama container dan volume tidak berubah bila folder dipindah | Diterima |
| I-006 | 2026-11-13 | Caddy sebagai reverse proxy | TLS otomatis, konfigurasi singkat, SSE mudah | Diusulkan |
| I-007 | 2026-11-13 | Redis dengan AOF dan `noeviction` di staging/produksi | Antrean job tidak boleh hilang | Diusulkan |
