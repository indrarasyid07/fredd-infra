# Fredd Infra Docs

Dokumentasi infrastruktur pendukung Fredd: database, Redis, reverse proxy, deploy, backup, dan observabilitas. Isi Bahasa Indonesia; nama file dan konfigurasi Bahasa Inggris.

| Folder | Isi |
|---|---|
| [00-governance](00-governance/README.md) | Aturan dokumentasi (sama dengan backend); [standar pesan commit](00-governance/commit-conventions.md) |
| [01-product-and-scope](01-product-and-scope/infra-scope.md) | Apa yang diurus folder `infra/` dan apa yang tidak |
| [02-architecture](02-architecture/infrastructure-architecture.md) | Topologi layanan, jaringan, volume, lingkungan |
| [03-api](03-api/README.md) | Aturan routing reverse proxy |
| [04-database](04-database/database-operations.md) | PostgreSQL dan Redis: versi, role, konfigurasi, backup, restore |
| [05-security-and-access](05-security-and-access/infra-security.md) | Rahasia, eksposur jaringan, TLS, hak akses |
| [06-domain-guides](06-domain-guides/local-development.md) | Panduan development lokal |
| [07-operations](07-operations/deployment.md) | Deploy produksi, Caddy, observabilitas |
| [08-quality-and-testing](08-quality-and-testing/README.md) | Layanan untuk CI dan health check |
| [09-seeding](09-seeding/README.md) | Reset dan isi ulang database dev |
| [10-roadmap](10-roadmap/roadmap.md) | Urutan pengerjaan infra |
| [11-decisions](11-decisions/decision-log.md) | Catatan keputusan |
| [12-phase-history](12-phase-history/changelog.md) | Riwayat fase |
| [13-diagrams](13-diagrams/infrastructure-diagrams.md) | Diagram deploy |
| [14-agent-guides](14-agent-guides/agent-guidelines.md) | Panduan AI coding agent |
| [99-archive](99-archive/README.md) | Dokumen lama |

Dokumentasi aplikasi: [backend/docs](https://gitlab.com/databiota-fredd/backend/-/blob/development/docs/README.md), [frontend/docs](https://gitlab.com/databiota-fredd/frontend/-/blob/development/docs/README.md).
