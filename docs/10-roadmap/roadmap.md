# Roadmap

Disejajarkan dengan [roadmap backend](https://gitlab.com/databiota-fredd/backend/-/blob/main/docs/10-roadmap/roadmap.md).

| Fase | Infra | Selesai bila |
|---|---|---|
| 0. Development | Compose dev Postgres + Redis | Sudah berjalan |
| 1. CI | Service container di CI, validasi compose | Tes backend jalan di CI |
| 2. Staging | Pilih hosting, compose produksi, Caddyfile, Dockerfile api/web, domain staging | Staging dapat diakses dengan TLS dan seed demo |
| 3. Kanal | URL webhook publik stabil untuk Telegram dan Meta | Webhook staging terverifikasi |
| 4. Produksi | Role database terpisah, backup terenkripsi, uji restore, error tracking, uptime check | Restore pertama berhasil diuji |

Fase 3 perlu staging lebih dulu karena WhatsApp Cloud API dan Telegram butuh URL HTTPS publik untuk webhook.
