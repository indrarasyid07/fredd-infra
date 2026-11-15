# Commit Conventions

Aturan lengkap (format, type, subject, body, footer, larangan, contoh) ada di backend: [commit-conventions.md](https://gitlab.com/databiota-fredd/backend/-/blob/development/docs/00-governance/commit-conventions.md). Ringkasnya:

```
<type>(<scope>): <subject>     ← Bahasa Inggris, kalimat perintah, huruf kecil, tanpa titik, ≤ 72 karakter

<body>                          ← apa dan kenapa, dibungkus 72 karakter

<footer>                        ← BREAKING CHANGE:, Refs:, Closes:
```

Type: `feat`, `fix`, `docs`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `style`, `revert`.

Dilarang di pesan commit: baris atribusi AI/alat (`Co-Authored-By: Claude ...`, `Generated with ...`), referensi ke file atau halaman desain (artifact, canvas, artboard, label versi desain seperti "V.1"), rahasia, dan data pribadi.

## Cabang

`development` adalah cabang utama (default di GitLab); semua commit harian masuk ke sana. `main` adalah cabang rilis, berisi commit awal, dan hanya diperbarui lewat merge dari `development`. Jangan commit langsung ke `main`. Aturan lengkap: [backend](https://gitlab.com/databiota-fredd/backend/-/blob/development/docs/00-governance/commit-conventions.md#cabang).

## Scope infra

| Scope | Area |
|---|---|
| `compose` | `docker-compose.yml`: layanan, profile, volume, healthcheck |
| `caddy` | `caddy/Caddyfile`: routing dan header |
| `postgres`, `redis` | Konfigurasi atau versi layanan tersebut |
| `env` | `.env.example` dan nama variabel lingkungan |

## Khusus infra

- Perubahan port, versi image, atau volume ditulis di body dan dicatat di [decision log](../11-decisions/decision-log.md).
- Variabel env yang diganti namanya atau dihapus memakai footer `BREAKING CHANGE:` karena `.env` lokal setiap orang ikut rusak.
- Sebelum commit: `docker compose config` lolos, dan `docker compose --profile app up` berjalan bila layanan aplikasi berubah.
- Isi `.env` tidak pernah di-commit; hanya `.env.example` tanpa nilai rahasia.

Contoh: `fix(compose): pass app origin and internal API URL to containers`, `feat(compose): run the full stack with an app profile`.
