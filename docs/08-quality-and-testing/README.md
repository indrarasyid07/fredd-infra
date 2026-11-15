# Quality and Testing

- **CI backend** butuh Postgres 17 dan Redis 8 sebagai service container (versi sama dengan `infra/docker-compose.yml`), memakai port bawaan di dalam runner.
- **Validasi compose**: `docker compose -f infra/docker-compose.yml config --quiet` di CI agar compose yang rusak ketahuan sebelum dipakai.
- **Health check**: setiap layanan compose punya `healthcheck`; `up --wait` gagal bila layanan tidak sehat.
- **Uji restore** bulanan dicatat di [changelog](../12-phase-history/changelog.md).

Strategi tes aplikasi: [backend](https://gitlab.com/databiota-fredd/backend/-/blob/development/docs/08-quality-and-testing/testing-strategy.md), [frontend](https://gitlab.com/databiota-fredd/frontend/-/blob/development/docs/08-quality-and-testing/testing-strategy.md).
