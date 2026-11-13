# Database Operations

Model data dan konvensi skema: [backend/docs/04-database/data-model.md](https://gitlab.com/databiota-fredd/backend/-/blob/main/docs/04-database/data-model.md). Dokumen ini tentang menjalankan databasenya.

## PostgreSQL

| Hal | Nilai |
|---|---|
| Versi | 17 |
| Encoding / zona waktu server | UTF-8 / UTC |
| Ekstensi | belum ada; `postgis` bila nanti butuh kueri spasial |
| Koneksi aplikasi | `postgresql+asyncpg://…`, pool dari SQLAlchemy |

### Role

| Role | Hak | Dipakai oleh |
|---|---|---|
| `fredd_owner` | Pemilik skema, DDL | Job `migrate` saja |
| `fredd_app` | `SELECT/INSERT/UPDATE/DELETE` pada tabel aplikasi | `api`, `worker` |
| `fredd_readonly` | `SELECT` | Analitik ad hoc, debugging |

Development memakai satu user `fredd` (superuser container) demi kesederhanaan; pemisahan role berlaku di staging dan produksi.

### Backup

- `pg_dump -Fc` harian pukul 02.00 WIB ke object storage, simpan 30 hari; mingguan disimpan 12 minggu.
- File backup dienkripsi sebelum diunggah.
- Uji restore tiap bulan ke database terpisah, catat hasilnya di [changelog](../12-phase-history/changelog.md).
- Bila memakai managed Postgres: aktifkan point-in-time recovery dan tetap simpan dump harian di luar penyedia.

### Restore

```bash
pg_restore --clean --if-exists --no-owner -d "$DATABASE_URL" backup.dump
```

Hentikan `api` dan `worker` sebelum restore ke produksi; jalankan `alembic upgrade head` setelahnya bila backup lebih lama dari kode.

## Redis

| Hal | Nilai |
|---|---|
| Versi | 8 |
| Kegunaan | Antrean dan cron arq, pub/sub event SSE, rate limit |
| Persistensi | AOF `appendfsync everysec` di staging/produksi agar job antrean tidak hilang saat restart |
| Memori | `maxmemory` disetel; kebijakan `noeviction` (antrean tidak boleh dibuang diam-diam) |

Redis bukan sumber kebenaran data. Hilangnya Redis hanya menunda job; pesan masuk sudah tersimpan di Postgres dan bisa diantrekan ulang.

## Retensi data

Penghapusan data lama (percakapan 12 bulan, foto 24 bulan) dijalankan oleh cron aplikasi, bukan oleh infra. Backup lama mengikuti jadwal di atas sehingga data yang dihapus aplikasi ikut hilang dari backup setelah 30 hari / 12 minggu.
