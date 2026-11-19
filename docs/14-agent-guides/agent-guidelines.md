# Agent Guidelines (Infra)

Untuk AI coding agent yang bekerja di `infra/`.

- Baca [infrastructure-architecture.md](../02-architecture/infrastructure-architecture.md) dan [infra-security.md](../05-security-and-access/infra-security.md) dulu.
- Jangan menulis rahasia ke compose, Caddyfile, atau dokumen; pakai nama variabel env.
- Jangan membuka port Postgres atau Redis ke publik; di dev bind ke `127.0.0.1`.
- Pin versi image (`postgis/postgis:17-3.5`, bukan `latest`).
- Jangan menjalankan `docker compose down -v` atau menghapus volume tanpa persetujuan eksplisit pengguna.
- Migrasi skema ditulis di `backend/migrations`, bukan di `infra/`.
- Setelah mengubah compose: `docker compose -f infra/docker-compose.yml config --quiet`.
- Catat perubahan port, versi, atau volume di [decision log](../11-decisions/decision-log.md).
