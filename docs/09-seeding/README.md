# Seeding

Isi data ada di [backend seed-data.md](https://gitlab.com/databiota-fredd/backend/-/blob/development/docs/09-seeding/seed-data.md). Dari sisi infra, reset database dev:

```bash
docker compose -f infra/docker-compose.yml down -v
docker compose -f infra/docker-compose.yml up -d --wait
cd backend && uv run alembic upgrade head
```

Lalu jalankan seed dari backend. Jangan pernah menjalankan `down -v` terhadap compose produksi.
