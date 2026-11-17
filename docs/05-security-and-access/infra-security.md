# Infra Security

Model keamanan aplikasi: [backend/docs/05-security-and-access/security-model.md](https://gitlab.com/databiota-fredd/backend/-/blob/development/docs/05-security-and-access/security-model.md).

## Eksposur jaringan

- Publik hanya port 80/443 (Caddy). Firewall menolak port lain, termasuk SSH dari luar IP yang diizinkan.
- Postgres dan Redis hanya di jaringan internal Docker. Di development port dibind ke `127.0.0.1`.
- Redis diberi password (`requirepass`) di staging/produksi meski internal.

## TLS

- Caddy mengurus sertifikat Let's Encrypt otomatis; HTTP dialihkan ke HTTPS.
- HSTS aktif di produksi.
- Header keamanan (CSP, X-Frame-Options, dll.) diatur di Next.js; Caddy tidak menimpanya.

## Rahasia

- Tidak ada rahasia di repo. `.env` diabaikan git; hanya `.env.example` tanpa nilai rahasia yang di-commit.
- Produksi: rahasia disuntikkan lewat env file di server dengan izin `600`, atau secret manager penyedia hosting.
- Kunci enkripsi aplikasi (`ENCRYPTION_KEYS`), password database, token Meta/Telegram dirotasi bila ada indikasi bocor; prosedur rotasi kunci ada di security model backend.

## Akses

- Akses server lewat SSH key, tanpa login password, tanpa root langsung.
- Akses database produksi hanya lewat role `fluctuz_readonly` untuk investigasi; perubahan data lewat aplikasi atau migrasi, bukan query manual.
- Backup terenkripsi; kunci dekripsi disimpan terpisah dari bucket backup.

## Pembaruan

- Image dasar (`postgres`, `redis`, `caddy`, `python`, `node`) dipin ke versi minor dan diperbarui bulanan.
- Patch keamanan Next.js dan FastAPI diterapkan begitu rilis.
